#! /bin/bash -x





# General Commands
LISTIPS=`grep \"public_ip\" terraform.tfstate | awk -F: '{print $2}' | sed  's/\"//g' | sed  's/\,//g'`

# Pick an valid AWS IP
VAULTIP=`echo $LISTIPS | awk '{print $1}'`

echo "Using Detected AWS IP $VAULTIP"


echo "Enter KeyID"
read KEY

echo "Enter Value"
read VALUE

KEY=$KEY
VALUE=$VALUE

echo $KEY=$VALUE
# Initialize Vault
echo "Initializing Vault.... can only be run once"
if [ ! -f init.response ]; then
	curl -X PUT -d "{\"secret_shares\":1, \"secret_threshold\":1}" http://$VAULTIP:8200/v1/sys/init | jq . > init.response
	FIRSTPASS="yes"
else
	echo "Already Initialized.... moving to next steps"
	FIRSTPASS="no"
fi


VAULT_TOKEN=$(jq -r  .root_token init.response)
VAULT_KEYS=$(jq  .keys_base64[0] init.response)


if [ $FIRSTPASS = "yes"  ]; then
	curl -X PUT -d "{\"key\": $VAULT_KEYS}" http://$VAULTIP:8200/v1/sys/unseal
	curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" -d '{"type":"approle"}' http://$VAULTIP:8200/v1/sys/auth/approle
	curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" -d '{"policies":"dev-policy,test-policy"}' http://$VAULTIP:8200/v1/auth/approle/role/testrole
	curl -X GET -H "X-Vault-Token:$VAULT_TOKEN" http://$VAULTIP:8200/v1/auth/approle/role/testrole/role-id 
else
	curl -X POST -H "X-Vault-Token:$VAULT_TOKEN" -d "{\"$KEY\":\"$VALUE\"}" http://$VAULTIP:8200/v1/secret/vaultdemo
	curl -X GET -H "X-Vault-Token:$VAULT_TOKEN" http://$VAULTIP:8200/v1/secret/vaultdemo | jq .
fi
