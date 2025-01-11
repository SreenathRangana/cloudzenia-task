# EC2 Instance with Domain Mapping, NGINX, and Docker

This guide explains how to set up EC2 instances in a private subnet, map them to domain names, configure NGINX and Docker, and secure the setup with SSL using Let's Encrypt.

---

## Infrastructure Requirements

### EC2 Instance
1. **Deploy EC2 Instances**:
   - Launch 2 EC2 instances in a **private subnet**.
   - Attach Elastic IPs to these instances for static public IPs required for domain mapping.

### Domain Mapping
1. **Assign Subdomains**:
   - Map each EC2 instance to unique subdomains:
     - `ec2-docker1.<domain-name>` and `ec2-instance1.<domain-name>`
     - `ec2-docker2.<domain-name>` and `ec2-instance2.<domain-name>`

### Application Load Balancer (ALB)
1. **Set Up ALB**:
   - Deploy an ALB in public subnets to handle HTTP/HTTPS traffic.
   - Map ALB to additional subdomains:
     - `ec2-alb-docker.<domain-name>`
     - `ec2-alb-instance.<domain-name>`
2. **SSL Configuration**:
   - Obtain an SSL certificate (e.g., Let's Encrypt).
   - Redirect all HTTP traffic to HTTPS.

### Docker Configuration
1. **Install Docker**:
   - Install Docker on each EC2 instance.
2. **Run a Docker Container**:
   - Create a container that serves the text `Namaste from Container` on an internal port (e.g., 8080).

### NGINX Configuration
1. **Install NGINX**:
   - Use NGINX for reverse proxy and content serving.
2. **Domain-Based Serving**:
   - Map subdomains to respective content:
     - `ec2-instance.<domain-name>` serves the text `Hello from Instance`.
     - `ec2-docker.<domain-name>` forwards requests to the Docker container.
3. **SSL with Let's Encrypt**:
   - Configure NGINX with SSL certificates for HTTPS access.
   - Redirect HTTP traffic to HTTPS.

---

## Step-by-Step Instructions

### Step 1: Launch EC2 Instances
1. **Create Key Pair**:
   - Generate and download an SSH key pair in the AWS console.
2. **Launch Instances**:
   - Launch 2 Ubuntu instances in a private subnet.
   - Assign Elastic IPs to ensure they have static public IPs.
3. **Update Security Groups**:
   - Allow inbound traffic for SSH (port 22), HTTP (port 80), and HTTPS (port 443).
   - Allow inbound traffic for Docker (port 8080).

### Step 2: Set Up Docker
1. **Install Docker**:
   ```bash
   sudo apt update
   sudo apt install -y docker.io
   ```
2. **Run a Docker Container**:
   ```bash
   sudo docker run -d -p 8080:80 --name container1 nginx:latest
   sudo docker exec -it container1 bash -c "echo 'Namaste from Container' > /usr/share/nginx/html/index.html"
   ```

### Step 3: Install and Configure NGINX
1. **Install NGINX**:
   ```bash
   sudo apt install -y nginx
   ```
2. **Configure NGINX**:
   - Update `/etc/nginx/sites-available/default`:
     ```nginx
     server {
         listen 80;
         server_name ec2-instance.<domain-name>;

         location / {
             return 200 'Hello from Instance';
             add_header Content-Type text/plain;
         }
     }

     server {
         listen 80;
         server_name ec2-docker.<domain-name>;

         location / {
             proxy_pass http://localhost:8080;
         }
     }
     ```
   - Test and reload NGINX:
     ```bash
     sudo nginx -t
     sudo systemctl reload nginx
     ```

### Step 4: Set Up Let's Encrypt SSL
1. **Install Certbot**:
   ```bash
   sudo apt install -y certbot python3-certbot-nginx
   ```
2. **Obtain SSL Certificates**:
   ```bash
   sudo certbot --nginx -d ec2-instance.<domain-name> -d ec2-docker.<domain-name>
   ```
3. **Auto-Renew Certificates**:
   - Test auto-renewal:
     ```bash
     sudo certbot renew --dry-run
     ```

### Step 5: Set Up Application Load Balancer (ALB)
1. **Create ALB**:
   - Deploy an ALB in public subnets.
   - Configure listeners for HTTP (redirect to HTTPS) and HTTPS traffic.
2. **Map ALB to Subdomains**:
   - Assign `ec2-alb-docker.<domain-name>` and `ec2-alb-instance.<domain-name>` to the ALB.

---

## Testing
1. **Access Subdomains**:
   - Verify `ec2-instance.<domain-name>` displays `Hello from Instance`.
   - Verify `ec2-docker.<domain-name>` displays `Namaste from Container`.
   - Verify ALB subdomains serve the respective content.
2. **Check HTTPS**:
   - Ensure HTTP traffic redirects to HTTPS.

---

## Cleanup
1. **Stop and Remove Docker Containers**:
   ```bash
   sudo docker stop container1
   sudo docker rm container1
   ```
2. **Terminate EC2 Instances**:
   - In the AWS EC2 Console, terminate the instances to avoid charges.






-----------------------------------------------------------------------------------------------------

Here’s how to set up **Docker Compose for production** and integrate it into your AWS infrastructure, including considerations for security, networking, and scalability.

---

### **Production Docker Compose Setup**

#### **Step 1: Create a Production-Ready `docker-compose.yml` File**
This file will configure the containers for **WordPress**, **Custom Microservice**, and the **MySQL database** while following production standards.

```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: ${DB_NAME}
    ports:
      - "8081:80"
    networks:
      - app-network
    depends_on:
      - db

  db:
    image: mysql:5.7
    container_name: wordpress-db
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - app-network

  microservice:
    build:
      context: ./custom-microservice
    container_name: custom-microservice
    environment:
      NODE_ENV: production
    ports:
      - "8080:8080"
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  db_data:
```

---

#### **Step 2: Use an `.env` File**
Create a `.env` file in the same directory to store environment variables securely:

```env
DB_ROOT_PASSWORD=rootpassword
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpresspassword
```

---

#### **Step 3: Deploy on an AWS EC2 Instance**
1. **Launch an EC2 Instance**:
   - Use an **Amazon Linux 2** or **Ubuntu** AMI.
   - Ensure you assign a security group with the following rules:
     - Allow SSH (port 22) from your IP.
     - Allow HTTP/HTTPS traffic (ports 80, 443) from the public.
   
2. **Install Docker and Docker Compose**:
   SSH into the instance and run:
   ```bash
   sudo yum update -y          # For Amazon Linux 2
   sudo yum install docker -y  # Install Docker
   sudo systemctl start docker
   sudo systemctl enable docker

   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Copy Files to the Instance**:
   - Use SCP or a Git repository to transfer the following files to the EC2 instance:
     - `docker-compose.yml`
     - `.env`
     - The `custom-microservice` folder.

   Example SCP command:
   ```bash
   scp -i <your-key.pem> -r ./project/ ec2-user@<your-ec2-public-ip>:/home/ec2-user/
   ```

4. **Run Docker Compose**:
   Navigate to the project directory and start the services:
   ```bash
   cd /home/ec2-user/project
   docker-compose up -d --build
   ```

5. **Test Your Deployment**:
   - Visit the WordPress service: `http://<your-ec2-public-ip>:8081`
   - Visit the Microservice: `http://<your-ec2-public-ip>:8080`

---

### **Step 4: Set Up HTTPS with NGINX and Let's Encrypt**

#### **1. Install NGINX**:
   ```bash
   sudo amazon-linux-extras enable nginx1
   sudo yum install nginx -y
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```

#### **2. Set Up Reverse Proxy**:
Edit the NGINX configuration to route traffic to your Docker containers. Create a new file in `/etc/nginx/conf.d/` (e.g., `wordpress_microservice.conf`):

```nginx
server {
    listen 80;
    server_name wordpress.<your-domain>;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 80;
    server_name microservice.<your-domain>;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Reload NGINX:
```bash
sudo systemctl restart nginx
```

#### **3. Obtain SSL Certificates with Let's Encrypt**:
Install Certbot and generate certificates:
```bash
sudo yum install certbot python3-certbot-nginx -y
sudo certbot --nginx -d wordpress.<your-domain> -d microservice.<your-domain>
```

#### **4. Verify HTTPS**:
Visit:
- `https://wordpress.<your-domain>`
- `https://microservice.<your-domain>`

---

### **Step 5: Auto-Scaling and Load Balancing (Optional for ECS Integration)**

If you wish to migrate these services to **AWS ECS** for better scalability:
1. Push the **Docker images** to **ECR**.
2. Create ECS services for **WordPress** and the **microservice**.
3. Attach an **Application Load Balancer** to ECS services and configure HTTPS using **ACM**.

---

Let me know if you'd like help with ECS migration or CI/CD setup for this workflow!