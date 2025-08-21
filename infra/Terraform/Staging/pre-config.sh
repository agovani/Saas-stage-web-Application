#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1

# --- Base OS & tools ---
dnf -y update
dnf -y install docker docker-compose-plugin git awscli
systemctl enable --now docker

# Optional: let ec2-user run docker interactively later
id ec2-user && usermod -aG docker ec2-user || true

# --- App checkout ---
mkdir -p /opt/app
cd /opt/app
# Pull your repo (adjust URL if private -> use deploy key or SSM/S3 artifact)
git clone https://github.com/agogovani/Saas-stage-web-Application.git .
# If you keep compose at root, we’re good. Otherwise cd into correct dir.

# Provide env (replace with SSM fetch if you stored secrets there)
if [ ! -f .env ]; then
  cp .env.example .env
  # Optionally template in values:
  sed -i "s/^BASIC_AUTH_USER=.*/BASIC_AUTH_USER=admin/" .env
  sed -i "s/^BASIC_AUTH_PASS=.*/BASIC_AUTH_PASS=changeme/" .env
  # For Traefik/LE:
  # sed -i "s/^LETSENCRYPT_EMAIL=.*/LETSENCRYPT_EMAIL=you@example.com/" .env
  # sed -i "s/^WEB_HOST=.*/WEB_HOST=your.domain.tld/" .env
  # sed -i "s/^API_HOST=.*/API_HOST=your.domain.tld/" .env
fi

echo ECS_CLUSTER=${aws_ecs_cluster.Spark_rock_demo_cluster.name} >> /etc/ecs/ecs.config

# --- Systemd unit to manage the stack ---
cat >/etc/systemd/system/app-compose.service <<'EOF'
[Unit]
Description=Docker Compose App
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=/opt/app
Environment="COMPOSE_FILE=/opt/app/docker-compose.yml"
ExecStartPre=/usr/bin/docker compose pull
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now app-compose

# --- Basic smoke checks (don’t fail the whole bootstrap if they error) ---
sleep 10 || true
docker ps || true
curl -fsS http://127.0.0.1/healthz || true
