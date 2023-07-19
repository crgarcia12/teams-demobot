hello

Configure Github Actions credentials
https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md
```
   az ad sp create-for-rbac --name "myApp" --role owner \
                            --scopes /subscriptions/{subscription-id} \
                            --sdk-auth