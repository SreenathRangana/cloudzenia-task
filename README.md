# cloudzenia-task

Let me refine and enhance the documentation to ensure it is complete and easy to follow. Here's an updated version with improved clarity and added details:

---

## **AWS Infrastructure Deployment Documentation**

### **1. Overview**
This document provides a step-by-step guide to deploying an AWS infrastructure using Terraform. The setup includes:

1. ECS with ALB, RDS, and SecretsManager.
2. EC2 Instances with NGINX and Docker.
3. S3 Static Website Hosting with CloudFront and SSL.
4. GitHub Actions Workflow for CI/CD.
5. Observability with CloudWatch.

---

### **2. Prerequisites**

Before proceeding, ensure the following prerequisites are met:

1. **AWS Account**:
   - Free Tier account with Administrator access.

2. **Domain Name**:
   - A domain name (e.g., `example.com`) managed in Route 53 or with DNS access.

3. **Tools Installed**:
   - **Terraform**: Download [here](https://www.terraform.io/downloads.html).
   - **AWS CLI**: Set up AWS CLI with credentials using:
     ```bash
     aws configure
     ```
   - **Git**: For source control and GitHub Actions integration.
   - **SSH Client**: To connect to EC2 instances.
   - **Node.js and Docker** (optional): For testing custom microservices locally.

4. **DNS Validation**:
   - Access to DNS settings for domain name validation (for SSL certificates).

---

### **3. Terraform Module Directory Structure**

The Terraform directory structure organizes reusable modules for deploying infrastructure:

```plaintext
project/
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Outputs for endpoints and resources
│   ├── modules/
│   │   ├── ecs_with_alb/        # ECS Cluster, ALB, and Services
│   │   ├── ec2_with_nginx/      # EC2 Instances with NGINX
│   │   ├── s3_static_website/   # S3 Static Website Hosting
│   │   └── rds_secretsmanager/  # RDS and SecretsManager
│   └── backend.tf              # Terraform state backend configuration
├── custom_microservice/         # Custom Node.js microservice
│   ├── app.js
│   ├── Dockerfile
│   ├── package.json
│   └── README.md
└── .github/
    └── workflows/
        └── deploy_microservice.yml  # GitHub Actions workflow for CI/CD
```

---

### **4. Deployment Steps**

#### **4.1 Deploy ECS with ALB, RDS, and SecretsManager**

1. **Navigate to the Terraform Directory**:
   ```bash
   cd terraform
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Update Variables**:
   - Edit `variables.tf` and provide the required values:
     - Domain name (e.g., `example.com`).
     - Instance types and scaling limits.
     - VPC CIDR ranges.

4. **Deploy ECS Infrastructure**:
   ```bash
   terraform apply -target=module.ecs_with_alb -auto-approve
   ```

5. **Verify Outputs**:
   - Note the ALB endpoints for:
     - WordPress: `https://wordpress.<domain-name>`
     - Microservice: `https://microservice.<domain-name>`

---

#### **4.2 Deploy EC2 Instances with NGINX and Docker**

1. **Deploy EC2 Instances**:
   ```bash
   terraform apply -target=module.ec2_with_nginx -auto-approve
   ```

2. **SSH into EC2 Instances**:
   - Find the Elastic IPs from the Terraform output.
   - Connect to the instance:
     ```bash
     ssh -i <key.pem> ec2-user@<elastic-ip>
     ```

3. **Test Services**:
   - Visit:
     - `https://ec2-instance.<domain-name>`: Displays "Hello from Instance".
     - `https://ec2-docker.<domain-name>`: Proxies to Docker container responding with "Namaste from Container".

---

#### **4.3 Deploy S3 Static Website Hosting with CloudFront**

1. **Deploy S3 and CloudFront**:
   ```bash
   terraform apply -target=module.s3_static_website -auto-approve
   ```

2. **Upload HTML Files**:
   - Upload `index.html` and `error.html` to the S3 bucket:
     ```bash
     aws s3 cp ./index.html s3://static-s3.<domain-name>/
     aws s3 cp ./error.html s3://static-s3.<domain-name>/
     ```

3. **Verify Static Website**:
   - Open the CloudFront URL (from Terraform output) in a browser:
     ```plaintext
     https://<cloudfront-domain-name>
     ```

---

#### **4.4 Configure SSL/TLS Certificates**

1. **For ALB**:
   - Request and validate an ACM certificate for your domain.
   - Update Terraform to include the ACM ARN in the ALB configuration.
   - Redeploy the ALB:
     ```bash
     terraform apply -target=module.ecs_with_alb -auto-approve
     ```

2. **For EC2 Instances**:
   - Install Let’s Encrypt:
     ```bash
     sudo certbot --nginx
     ```
   - Test HTTPS redirection for:
     - `https://ec2-instance.<domain-name>`
     - `https://ec2-docker.<domain-name>`

---

#### **4.5 Set Up GitHub Actions Workflow**

1. **Push Microservice Code to GitHub**:
   - Initialize Git and push the `custom_microservice/` folder:
     ```bash
     git init
     git add .
     git commit -m "Initial commit"
     git branch -M main
     git remote add origin <github-repo-url>
     git push -u origin main
     ```

2. **Add GitHub Secrets**:
   - Go to **Repository Settings → Secrets → Actions**.
   - Add:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`

3. **Trigger Workflow**:
   - Push a code change to trigger the GitHub Actions pipeline.
   - Verify:
     - Docker image is built and pushed to ECR.
     - ECS service is updated with the new deployment.

---

### **5. Observability with CloudWatch**

1. **View Logs for NGINX**:
   - Access CloudWatch to see NGINX access logs.

2. **Monitor EC2 Metrics**:
   - Verify that RAM and other custom metrics are visible in CloudWatch.

---

### **6. Cleanup**

To avoid incurring unnecessary charges, destroy all resources after testing:

```bash
terraform destroy -auto-approve
```

---

### **7. Output Summary**

| **Service**        | **URL**                              | **Description**                          |
|---------------------|--------------------------------------|------------------------------------------|
| WordPress           | `https://wordpress.<domain-name>`    | WordPress site hosted on ECS.            |
| Microservice        | `https://microservice.<domain-name>` | Node.js microservice hosted on ECS.      |
| EC2 Instance        | `https://ec2-instance.<domain-name>` | Static text from NGINX.                  |
| EC2 Docker          | `https://ec2-docker.<domain-name>`   | Proxies to Docker container response.    |
| S3 Static Website   | `https://static-s3.<domain-name>`    | Static website hosted on S3 with CDN.    |

---