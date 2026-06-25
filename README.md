# Azure Three-Tier Deployment — Terraform
### we are deploying this application on plura sight so we are used data bloks 
- change the subscription and resource group details on ```env/dev/terraform.tfvars```

### AZure login 

```
az login --use-device-code
````
### Apply the  network, frontend-vm, backend-vm, bastionhost, database, backend-lb, frontend-lb 
```
terraform apply -target="module.network"

terraform apply -target="module.frontend_vm"

terraform apply -target="module.backend_vm"

terraform apply -target="module.bastion"

terraform apply -target="module.database"

terraform apply -target="module.backend_lb"

terraform apply -target="module.frontend_lb"
```


# Backend 

- connect to backend server using bastion host procress
- clone the git repo 
```
git clone https://github.com/CloudTechDevOps/2nd10WeeksofCloudOps-main.git

cd 2nd10WeeksofCloudOps-main/backend
```
### chnage the datbase details on ```.env file ``` 

- run the test.sql
```
mysql -h azure-hostname -u <username> -p<password> < test.sql
```

- run the npm commnds 
```
npm install 

npm install dotenv

sudo pm2 start index.js --name books

pm2 startup

sudo systemctl enable pm2-root

pm2 save
```
- check the backend status 
```
curl localhost
curl localhost/api/books        # important if database is connected mens it will show books 
```

# Frontend

- connect to backend server using bastion host procress
- clone the git repo 
```
git clone https://github.com/CloudTechDevOps/2nd10WeeksofCloudOps-main.git

cd 2nd10WeeksofCloudOps-main/client
```

### change the backend loadbalncer ip on ```nginx.conf```
- copy nginx file to conf.d path
```
sudo rm /etc/nginx/sites-enabled/default
sudo cp nginx.conf /etc/nginx/conf.d/
```
- Run the npm comands on frontend 

```
npm install

npm run build 

sudo cp -r build/* /usr/share/nginx/html/
```

- restart and chek nginx 

```
nginx -t

sudo systemctl restart nginx

sudo systemctl enable nginx
```

- check the curl responce it will show book self pro some thing '

```
curl localhost
```
- if everhing is fine take the both images 
- capture the both vms images 

# terraform again

- change the image id on terraform.tfvars
- both frontend and backend 
- change subscriptionid,resourcegrop, gallery, image defination, version on both frontned and backend ids 

# then run vmsss
```
terraform apply -target="module.frontend_vmss"

terraform apply -target="module.backend_vmss"
```
