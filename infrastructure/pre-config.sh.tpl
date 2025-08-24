#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/user-data.log) 2>&1

# --- System Update ---
sudo apt-get update -y

# --- Install prerequisites and tools (successfully tested) ---
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


# Add the repository to Apt sources:
echo \
  "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $$(./etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update



# --- Add Docker official repo (to fix conflicts you hit earlier) ---
sudo apt-get install  -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Enable Docker ---
systemctl enable --now docker

# --- Install AWS CLI ---
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt install unzip

unzip awscliv2.zip

sudo ./aws/install

systemctl daemon-reload
systemctl enable --now app-compose


# --- Install CloudWatch Agent ---
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
dpkg -i /tmp/amazon-cloudwatch-agent.deb

# --- CloudWatch Agent config (basic CPU/memory/disk monitoring) ---
cat >/opt/aws/amazon-cloudwatch-agent/bin/config.json <<'EOF'
{
  "metrics": {
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    },
    "metrics_collected": {
      "CPU": {
        "measurement": [
          {"name": "cpu_usage_active", "rename": "CPU_Usage", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "Memory": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "Memory_Usage", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "Disk": {
        "measurement": [
          {"name": "disk_used_percent", "rename": "Disk_Usage", "unit": "Percent"}
        ],
        "resources": [
          "/"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}

EOF

# --- Start CloudWatch Agent ---
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

# --- Basic smoke checks (don’t fail the whole bootstrap if they error) ---
sleep 10 || true
docker ps || true
curl -fsS http://127.0.0.1/healthz || true

  # --- GitHub Runners ---

  # Create a folder
mkdir /etc/actions-runner && cd /etc/actions-runner
# Download the latest runner package
curl -o actions-runner-linux-x64-2.328.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz
# Optional: Validate the hash
echo "01066fad3a2893e63e6ca880ae3a1fad5bf9329d60e77ee15f2b97c148c3cd4e  actions-runner-linux-x64-2.328.0.tar.gz" | shasum -a 256 -c

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.328.0.tar.gz
# Create the runner and start the configuration experience
./config.sh --url https://github.com/agovani/Saas-stage-web-Application --token <token>
# Last step, run it!
./run.sh &

# --- Connect with ECR ---

aws ecr get-login-password --region us-east-1   | sudo docker login --username AWS --password-stdin 606010181709.dkr.ecr.us-east-1.amazonaws.com

docker run -d --name saas-app -p 80:80 606010181709.dkr.ecr.us-east-1.amazonaws.com/saas-stage-web-application:latest
