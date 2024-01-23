# Uptime-Kuma on AKS with Terraform

This repository contains the necessary Terraform configurations to deploy Uptime-Kuma, a self-hosted monitoring tool, on an Azure Kubernetes Service (AKS) cluster.

## Structure

- `main.tf` - Contains the main set of Terraform configurations to set up the AKS cluster and deploy Uptime-Kuma.
- `variables.tf` - Defines the variables used across the Terraform configurations.
- `outputs.tf` - Specifies the outputs after the Terraform apply.
- `providers.tf` - Configures the Terraform providers.

## Prerequisites

- Azure CLI
- Terraform
- An Azure account with permissions to create resources

## Usage

1. Clone this repository.
2. Navigate to the repository directory.
3. Initialize the Terraform environment.

 ```sh
   terraform init
```

4. Create a `terraform.tfvars` file or export the necessary environment variables to provide values for the required variables.

   Example `terraform.tfvars`:

   ```sh
   resource_group_name = "myAKSResourceGroup"
   location            = "East US"
   cluster_name        = "myAKSCluster"
   dns_prefix          = "myaksclusterdns"
   node_count          = 1
   vm_size             = "Standard_DS2_v2"
   client_id           = "your-service-principal-client-id"
   client_secret       = "your-service-principal-client-secret"
   ```

5. Plan the Terraform execution to see the changes that will be made.

   ```sh
   terraform plan
   ```

6. Apply the Terraform configuration to create the infrastructure.

   ```sh
   terraform apply
   ```

7. Once the deployment is complete, use the outputted external IP to access Uptime-Kuma