#!/bin/bash

# Echo statement to indicate the start of the update and upgrade process
echo "[UPDATE & UPGRADE PACKAGES]"

# Update package list
echo "Updating package list..."
sudo apt-get update -y

# Upgrade all installed packages
echo "Upgrading installed packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y


echo "[DOCKER]: Installing Docker"
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker.io  docker-compose -y

echo "[DOCKER]: Enabling Docker"
sudo systemctl enable docker
echo "[DOCKER]: Provisioning Complete."
sudo docker --version

mkdir /home/ubuntu/app

cd /home/ubuntu/app

sudo tee ./docker-compose.yml <<EOF
${DOCKER_COMPOSE_YML}
EOF

sudo tee ./library.sql <<EOF
${DATABASE_SEED_SQL}
EOF

sudo usermod -aG docker ubuntu

sudo -u ubuntu -i bash <<'EOF'
cd /home/ubuntu/app
docker-compose down
docker-compose up -d

EOF