# Saas-stage-web-Application
Saas-Escalation-Engineer-Real-work-Challange

---

## Infrastructure Design Overview

1. **VPC & Subnets**
   - Uses the AWS default VPC (`aws_default_vpc`).
   - Three default subnets are defined for different availability zones.

2. **Security Groups**
   - **ALB Security Group**: Allows HTTP (80) and HTTPS (443) from anywhere.
   - **Web Security Group**: Allows HTTP/HTTPS from anywhere.
   - **EC2 Security Group**: Allows SSH (22) from anywhere.
   - **DB Security Group**: Allows PostgreSQL (5432) from web instances.

3. **Compute**
   - **EC2 Auto Scaling Group**:
     - Launches Ubuntu Noble 24.04 instances using a launch template.
     - Uses a custom IAM role (`EC2-CICD-role`) for ECR access.
     - Instances run a bootstrap script to install Docker, AWS CLI, CloudWatch agent, and GitHub Actions runner.
     - Security group attached for web access.
     - Desired capacity: **2 instances** (scales between 1 and 3).

4. **Load Balancer**
   - **Application Load Balancer (ALB)**:
     - Public-facing, distributes traffic to EC2 instances.
     - Listeners for HTTP (redirects to HTTPS) and HTTPS (uses ACM certificate).
     - Target group uses **instance mode** for EC2 registration.
     - Health checks on `/healthz`.

5. **Storage**
   - **S3 Bucket**:
     - Stores application files.
     - Bucket policy enforces secure transport.

6. **Database**
   - **RDS PostgreSQL Instance**:
     - Private, not publicly accessible.
     - Uses DB subnet group and DB security group.

7. **IAM**
   - **EC2 Instance Role**: `EC2-CICD-role` with full ECR access.
   - **Instance profile** attached to EC2s.
   - **ECS Task Execution Role & S3 Policy**: Present but not actively used (legacy from ECS setup).

8. **Monitoring**
   - **CloudWatch Log Groups**: For EC2, ALB, API, and web logs.
   - **CloudWatch Alarms**: EC2 CPU utilization alarm (>70% triggers alert).

9. **Secrets**
   - **AWS Secrets Manager**:
     - Stores DB password and DB URL.

10. **CI/CD**
    - **GitHub Actions Runner**: Installed on EC2 instances for CI/CD automation.
    - **Docker & ECR**: EC2 instances can pull images from ECR.

11. **Certificate Management**
    - **ACM Certificate**: Used for HTTPS on ALB.

---

## Diagram

![alt text](docs/Sparkrock-diagram.svg)
---

## 🚀 Deployment Instructions

### Step 1 – Prepare AWS
- Ensure you have:
  - An **ECR repo** created (`saas-stage-web-application`).
  - An **EC2 instance** with Docker installed and configured as a **self-hosted GitHub Actions runner**.
  - Runner must have IAM credentials (via instance profile or GitHub secrets).

### Step 2 – Configure GitHub Secrets
In your GitHub repo → **Settings → Secrets and variables → Actions**, add:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`

These are used by **`CI.yml`** and **`Deploy to EC2.yml`**.

### Step 3 – Push Code to Main
- When you push changes to the `main` branch:
  - **CI.yml** runs:
    - Logs into ECR.
    - Builds Docker image from `./web`.
    - Tags image with both `:sha` and `:latest`.
    - Pushes to ECR.
  - On success, **Deploy to EC2.yml** runs:
    - Pulls the new `:latest` image from ECR.
    - Stops and removes old container.
    - Runs new container with the latest image.

### Step 4 – Verify Deployment
SSH into your EC2:
```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
docker ps
You should see your container running with ports exposed (`80:80`).

---

## CI/CD Pipeline Explanation

### 1. CI (Continuous Integration) — `CI.yml`
Runs on every push to **main**.

- **Checkout code** → Pulls latest repo.
- **Setup Node.js** → Prepares build environment.
- **Login to ECR** → Authenticates Docker to push images.
- **Build Docker image** → Builds image from `./web`.
- **Tag Docker image** → Tags with:
  - Commit SHA (`:sha`) → traceability.
  - `latest` → easy deployment.
- **Push to ECR** → Uploads to AWS ECR.

💡 *This is your “build & package” stage.*

---

### 2. CD (Continuous Deployment) — `Deploy to EC2.yml`
Runs after **CI.yml** finishes.

- **Pull Docker image** → Fetches new image from ECR.
- **Stop old container** → Removes previous deployment.
- **Run new container** → Launches updated container with AWS environment variables.

💡 *This is your “release & deploy” stage.*

---

### 🚦 Flow in One Sentence
`Push to main → GitHub Actions builds image & pushes to ECR → Deployment job pulls & redeploys container on EC2`.

---

## CloudWatch Monitoring

### Log Groups
- **API** → `/ecs/${var.project}-api` (14 days retention)  
- **Web** → `/ecs/${var.project}-web` (14 days retention)  
- **EC2** → `/ec2/${var.project}-instances` (14 days retention)  
- **ALB** → `/alb/${var.project}-alb` (14 days retention)  

These log groups collect logs from your API, web, EC2 instances, and Application Load Balancer.

### Metric Alarm
**EC2 CPU Utilization Alarm**  
- Monitors average CPU usage for your EC2 Auto Scaling Group.  
- Triggers if CPU >70% for **two consecutive 60-second periods**.  
- Alarm description: *"EC2 CPU utilization is above 70%"*.  
- Missing data is treated as *not breaching*.  

---
