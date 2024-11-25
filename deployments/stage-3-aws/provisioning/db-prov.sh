#!/bin/bash

# Echo statement to indicate the start of the update and upgrade process
echo "[UPDATE & UPGRADE PACKAGES]"

# Update package list
echo "Updating package list..."
sudo apt-get update -y

# Upgrade all installed packages
echo "Upgrading installed packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install MySQL server (using Java 17 in the comment for clarity)
echo "Installing MySQL server..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y

# Start the MySQL service
echo "Starting MySQL service..."
sudo systemctl start mysql.service

# Create a MySQL user and grant privileges on the 'library' database
echo "Creating MySQL user 'java-app' and granting privileges on the 'library' database..."
sudo mysql -ppassword -e "CREATE USER 'java-app'@'%' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON library.* TO 'java-app'@'%'; FLUSH PRIVILEGES;"

# Echo statement to indicate that the SQL seed file is being created
echo "Creating the SQL seed file..."

# Generate SQL file from variable DATABASE_SEED_SQL (assuming this is set elsewhere in the script or environment)
sudo tee ./library.sql <<EOF
${DATABASE_SEED_SQL}
EOF

# Execute the SQL file to populate the database
echo "Populating database with seed data from './library.sql'..."
sudo mysql -ppassword -e "SOURCE ./library.sql"

# Verify data in the authors table
echo "Verifying data in 'authors' table..."
sudo mysql -ppassword library -e "SELECT * FROM authors;"

# Change MySQL bind-address to allow remote connections
echo "Changing MySQL bind-address to allow remote connections..."
sudo sed -i 's/\s*bind-address\s*=\s*127.0.0.1\s*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL service to apply the changes
echo "Restarting MySQL service to apply changes..."
sudo systemctl restart mysql.service

# Final message indicating script completion
echo "[PROCESS COMPLETED] MySQL setup and configuration finished."
