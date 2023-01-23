# YADA - Bicep Deployment on Azure Container Apps

In the README files for each tier ([web/README.md](../../web/README.md) and [api/README.md](../../api/README.md)) you can find additional information about YADA web and API components.

## File strucure

- `main.bicep`: main entry point for deployment that creates resource group, SQL database and Container Apps
- `modules/db.bicep`: submodule for SQL server and database
- `modules/aca.bicep`: submodule for Container Apps Environment, API and Web containers

## Deployment

In the following example you can find a Bicep deployment of the YADA app using Azure Container Apps with public ingresses for the web and API tiers, and Azure SQL Database for the data tier:

```bash
# Create password
sql_password=$(openssl rand -base64 10)  # 10-character random password

# Do deployment
az deployment sub create -n "yada-$(date -u +%Y%m%dT%H%M%S)" -l norwayeast -f ./main.bicep -p serverPassword=$sql_password
```
