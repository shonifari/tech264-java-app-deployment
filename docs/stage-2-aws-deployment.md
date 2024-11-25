# AWS Deployment

- [AWS Deployment](#aws-deployment)
  - [Infrastructure](#infrastructure)
    - [**Application Server (EC2 Instance)**](#application-server-ec2-instance)
    - [**2. Database Server (EC2 Instance)**](#2-database-server-ec2-instance)
    - [**3. Networking and Security**](#3-networking-and-security)
    - [**4. Variables and Parameters**](#4-variables-and-parameters)
  - [Application](#application)
    - [**App Provisioning Script**](#app-provisioning-script)
      - [**1. Set the GitHub Repository URL**](#1-set-the-github-repository-url)
      - [**2. Package Update and Upgrade**](#2-package-update-and-upgrade)
      - [**3. Install Java 17**](#3-install-java-17)
      - [**4. Set Java Home Environment Variable**](#4-set-java-home-environment-variable)
      - [**5. Install Maven**](#5-install-maven)
      - [**6. Configure Maven Environment Variables**](#6-configure-maven-environment-variables)
      - [**7. Check Maven Installation**](#7-check-maven-installation)
      - [**8. Clean Up Maven Download**](#8-clean-up-maven-download)
      - [**9. Set Database Connection Variables**](#9-set-database-connection-variables)
      - [**10. Clone the GitHub Repository**](#10-clone-the-github-repository)
      - [**11. Navigate to the Project Directory**](#11-navigate-to-the-project-directory)
      - [**12. Wait for Database to Be Ready**](#12-wait-for-database-to-be-ready)
      - [**13. Build the Project**](#13-build-the-project)
      - [**14. Start the Spring Boot Application**](#14-start-the-spring-boot-application)
      - [**15. Final Message**](#15-final-message)
    - [**Summary**](#summary)
  - [Database](#database)
    - [**Database Provisioning Script**](#database-provisioning-script)
      - [**1. Echo Statement - Start Update and Upgrade Process**](#1-echo-statement---start-update-and-upgrade-process)
      - [**2. Update Package List**](#2-update-package-list)
      - [**3. Upgrade Installed Packages**](#3-upgrade-installed-packages)
      - [**4. Install MySQL Server**](#4-install-mysql-server)
      - [**5. Start the MySQL Service**](#5-start-the-mysql-service)
      - [**6. Create MySQL User and Grant Privileges**](#6-create-mysql-user-and-grant-privileges)
      - [**7. Echo Statement - SQL Seed File Creation**](#7-echo-statement---sql-seed-file-creation)
      - [**8. Generate SQL Seed File**](#8-generate-sql-seed-file)
      - [**9. Execute SQL Seed File**](#9-execute-sql-seed-file)
      - [**10. Verify Data in Authors Table**](#10-verify-data-in-authors-table)
      - [**11. Change MySQL Bind Address**](#11-change-mysql-bind-address)
      - [**12. Restart MySQL Service**](#12-restart-mysql-service)
      - [**13. Final Message**](#13-final-message)

## Infrastructure

This document outlines the infrastructure setup described in the provided Terraform code. The setup creates an application server (EC2 instance) and a database server (EC2 instance), both within AWS, along with necessary networking and security configurations.

### **Application Server (EC2 Instance)**

- **Security Group**: A security group for the application instance to control traffic flow.
  - Inbound rules allow:
    - SSH (port 22) from a defined CIDR range.
    - HTTP (port 5000) from the same CIDR range.
  - Outbound rule allows all traffic to any destination.

- **Application EC2 Instance**: The EC2 instance where the Java application will run.
  - Configures the instance with a specific AMI (Ubuntu 22.04), instance type, and SSH key pair.
  - User data is passed to provision the instance, including a GitHub token and database connection details.

### **2. Database Server (EC2 Instance)**

- **Security Group**: A security group for the database instance to control access to the database server.
  - Inbound rules allow:
    - SSH (port 22) from a defined CIDR range.
    - MySQL (port 3306) from the application server's security group.
  - Outbound rule allows all traffic to any destination.

- **Database EC2 Instance**: The EC2 instance for running the MySQL database.
  - Configures the instance with a specified AMI (Ubuntu 22.04), instance type, and SSH key pair.
  - User data for provisioning the database, including SQL seed data (`library.sql`).

### **3. Networking and Security**

- **Ingress and Egress Rules**:
  - For both the application and database instances, there are rules that define which ports and traffic types are allowed:
    - **SSH (Port 22)**: Access for secure shell login.
    - **HTTP (Port 5000)**: For communication between the application server and external users.
    - **MySQL (Port 3306)**: For communication between the application and database servers.
    - Egress rules allow all outbound traffic from both instances.

- **Security Group Dependencies**: The application server depends on the database instance for connectivity, with the database's private IP being passed into the application server's provisioning script.

### **4. Variables and Parameters**

- **User Data Scripts**:
  - The `java-app-prov.sh` script provisions the application server, while the `db-prov.sh` script provisions the database server. These scripts are expected to set up the necessary environments, such as installing Java and MySQL, as well as seeding the database with initial data.

---

## Application

### **App Provisioning Script**

This [bash script](../deployments/stage-3-aws/provisioning/java-app-prov.sh) automates the process of updating and upgrading packages, installing dependencies, setting up a Java environment, cloning a GitHub repository, and starting a Spring Boot application. Below is a breakdown of each section of the script:

---

#### **1. Set the GitHub Repository URL**

```bash
# Set the GitHub repository URL as a variable
GH_REPO=https://github.com/shonifari/tech264-java-app
```

- **Purpose**: Initializes a variable `GH_REPO` with the GitHub repository URL from where the application will be cloned.

---

#### **2. Package Update and Upgrade**

```bash
# Echo statement to indicate the start of the update and upgrade process
echo "[UPDATE & UPGRADE PACKAGES]"

# Update package list
echo "Updating package list..."
sudo apt-get update -y

# Upgrade all installed packages
echo "Upgrading installed packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
```

- **Purpose**:
  - Updates the list of available packages.
  - Upgrades all installed packages to their latest versions in a non-interactive mode, ensuring smooth automation.

---

#### **3. Install Java 17**

```bash
# Install Java 17
echo "Installing Java 17..."
sudo DEBIAN_FRONTEND=noninteractive apt install openjdk-17-jdk -y
```

- **Purpose**: Installs Java 17 JDK, which is required for running the Java-based application.

---

#### **4. Set Java Home Environment Variable**

```bash
# Set Java home environment variable and update the PATH
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

- **Purpose**:
  - Sets the `JAVA_HOME` environment variable to the installed Java 17 location.
  - Updates the system `PATH` to include the Java binaries so Java commands can be executed from any location.

---

#### **5. Install Maven**

```bash
# Install Maven by downloading and extracting the binary
echo "Downloading and installing Apache Maven..."
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz

# Extract Maven to the /opt directory
echo "Extracting Maven to /opt directory..."
sudo tar -xvzf apache-maven-*.tar.gz -C /opt

# Move extracted Maven to a more appropriate directory
echo "Moving Maven to /opt/maven..."
sudo mv /opt/apache-maven-* /opt/maven
```

- **Purpose**:
  - Downloads the specified Apache Maven version.
  - Extracts the Maven binary archive to the `/opt` directory.
  - Moves the extracted Maven folder to a dedicated `/opt/maven` directory.

---

#### **6. Configure Maven Environment Variables**

```bash
# Export Maven environment variables
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
```

- **Purpose**:
  - Sets the `M2_HOME` environment variable to point to the Maven installation directory.
  - Updates the system `PATH` to include the Maven binaries, enabling the execution of Maven commands globally.

---

#### **7. Check Maven Installation**

```bash
# Check Maven version to verify installation
echo "Checking Maven version..."
mvn -version
```

- **Purpose**: Verifies that Maven was installed correctly by checking its version.

---

#### **8. Clean Up Maven Download**

```bash
# Cleanup by removing the downloaded Maven tar.gz file
echo "Cleaning up the downloaded Maven tarball..."
rm apache-maven-*.tar.gz
```

- **Purpose**: Removes the downloaded Maven archive to clean up unnecessary files.

---

#### **9. Set Database Connection Variables**

```bash
# Export database connection details
export DB_USER="java-app"
export DB_PASS="password"
export DB_HOST=jdbc:mysql://${DATABASE_IP}:3306/library
```

- **Purpose**:
  - Sets the database user, password, and host as environment variables to be used later in the script.

---

#### **10. Clone the GitHub Repository**

```bash
# Clone the GitHub repository using the provided token for authentication
echo "Cloning the repository from GitHub..."
git clone https://shonifari:${GH_TOKEN}@github.com/shonifari/tech264-java-app.git repo
```

- **Purpose**: Clones the specified GitHub repository using a GitHub token for authentication.

---

#### **11. Navigate to the Project Directory**

```bash
# Navigate into the cloned project directory
cd repo/LibraryProject2
```

- **Purpose**: Changes the current working directory to the project directory where the application is located.

---

#### **12. Wait for Database to Be Ready**

```bash
# Wait for a few seconds to ensure the database is ready
echo "Waiting for 5 seconds..."
sleep 5s
```

- **Purpose**: Pauses the script for 5 seconds to allow the database (or other services) to be fully initialized before proceeding.

---

#### **13. Build the Project**

```bash
# Build the project using Maven
echo "Building the project with Maven..."
mvn clean package
```

- **Purpose**: Uses Maven to clean the project and package it, preparing the application for deployment.

---

#### **14. Start the Spring Boot Application**

```bash
# Start the Spring Boot application
echo "Starting the Spring Boot application..."
mvn spring-boot:start
```

- **Purpose**: Uses Maven to start the Spring Boot application on the system.

---

#### **15. Final Message**

```bash
# Final message indicating script completion
echo "[PROCESS COMPLETED] Application setup and start completed."
```

- **Purpose**: Outputs a final message indicating that the process has been completed successfully.

---

### **Summary**

This script automates the process of:

1. Updating system packages.
2. Installing Java 17 and Maven.
3. Cloning a GitHub repository.
4. Building and starting a Spring Boot application using Maven.

It also provides helpful echo statements for tracking the progress of each step.

## Database

### **Database Provisioning Script**

This [bash script](../deployments/stage-3-aws/provisioning/db-prov.sh) automates the process of setting up and configuring a MySQL server, creating a user, granting privileges, populating the database with initial data, and making the database accessible over the network. Below is a step-by-step breakdown of the script:

---

#### **1. Echo Statement - Start Update and Upgrade Process**

```bash
# Echo statement to indicate the start of the update and upgrade process
echo "[UPDATE & UPGRADE PACKAGES]"
```

- **Purpose**: This echo statement acts as a starting point for the script, indicating that the process of updating and upgrading packages has begun.

---

#### **2. Update Package List**

```bash
# Update package list
echo "Updating package list..."
sudo apt-get update -y
```

- **Purpose**: Refreshes the list of available packages on the system, ensuring that you have the most current package versions available for installation.

---

#### **3. Upgrade Installed Packages**

```bash
# Upgrade all installed packages
echo "Upgrading installed packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
```

- **Purpose**: Upgrades all installed packages on the system to their latest versions without requiring user interaction, which is necessary for automation.

---

#### **4. Install MySQL Server**

```bash
# Install MySQL server (using Java 17 in the comment for clarity)
echo "Installing MySQL server..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y
```

- **Purpose**: Installs MySQL server on the system. The comment indicates that this step is not related to Java version (e.g., Java 17); it's specifically for MySQL installation.

---

#### **5. Start the MySQL Service**

```bash
# Start the MySQL service
echo "Starting MySQL service..."
sudo systemctl start mysql.service
```

- **Purpose**: Starts the MySQL service to allow connections and interactions with the database.

---

#### **6. Create MySQL User and Grant Privileges**

```bash
# Create a MySQL user and grant privileges on the 'library' database
echo "Creating MySQL user 'java-app' and granting privileges on the 'library' database..."
sudo mysql -ppassword -e "CREATE USER 'java-app'@'%' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON library.* TO 'java-app'@'%'; FLUSH PRIVILEGES;"
```

- **Purpose**:
  - Creates a new user `java-app` with a specified password.
  - Grants this user `ALL` privileges on the `library` database.
  - `FLUSH PRIVILEGES` ensures that these changes take effect immediately.

---

#### **7. Echo Statement - SQL Seed File Creation**

```bash
# Echo statement to indicate that the SQL seed file is being created
echo "Creating the SQL seed file..."
```

- **Purpose**: Prepares the user for the next step - creating the SQL seed file.

---

#### **8. Generate SQL Seed File**

```bash
# Generate SQL file from variable DATABASE_SEED_SQL (assuming this is set elsewhere in the script or environment)
sudo tee ./library.sql <<EOF
${DATABASE_SEED_SQL}
EOF
```

- **Purpose**: Uses `tee` to write the content of `DATABASE_SEED_SQL` (presumably set earlier in the script or environment) into a file named `library.sql`. This file can then be used to populate the database with initial data.

---

#### **9. Execute SQL Seed File**

```bash
# Execute the SQL file to populate the database
echo "Populating database with seed data from './library.sql'..."
sudo mysql -ppassword -e "SOURCE ./library.sql"
```

- **Purpose**: Loads the data from `library.sql` into the `library` database.
- `SOURCE` is a MySQL command that executes SQL statements from a file.

---

#### **10. Verify Data in Authors Table**

```bash
# Verify data in the 'authors' table
echo "Verifying data in 'authors' table..."
sudo mysql -ppassword library -e "SELECT * FROM authors;"
```

- **Purpose**: Checks if the `authors` table in the `library` database contains the expected data after running `library.sql`.

---

#### **11. Change MySQL Bind Address**

```bash
# Change MySQL bind-address to allow remote connections
echo "Changing MySQL bind-address to allow remote connections..."
sudo sed -i 's/\s*bind-address\s*=\s*127.0.0.1\s*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
```

- **Purpose**: Allows the MySQL server to accept remote connections by modifying the `bind-address` configuration in `mysqld.cnf` file.

---

#### **12. Restart MySQL Service**

```bash
# Restart MySQL service to apply changes
echo "Restarting MySQL service to apply changes..."
sudo systemctl restart mysql.service
```

- **Purpose**: Applies the `bind-address` change immediately by restarting the MySQL service.

---

#### **13. Final Message**

```bash
# Final message indicating script completion
echo "[PROCESS COMPLETED] MySQL setup and configuration finished."
```

- **Purpose**: Signals the completion of the script and confirms that the MySQL server has been configured successfully, with remote access enabled, a new user created, and initial data loaded into the `library` database.
