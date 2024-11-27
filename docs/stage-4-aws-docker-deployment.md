# AWS Docker Deployment

- [AWS Docker Deployment](#aws-docker-deployment)
  - [Infrastructure](#infrastructure)
    - [**Application Server (EC2 Instance)**](#application-server-ec2-instance)
    - [**Networking and Security**](#networking-and-security)
    - [**Variables and Parameters**](#variables-and-parameters)
  - [Docker Image](#docker-image)
  - [Docker-compose](#docker-compose)
  - [Provisioning script](#provisioning-script)
    - [1. **Begin Script**](#1-begin-script)
    - [2. **Update and Upgrade Packages**](#2-update-and-upgrade-packages)
    - [3. **Install Docker and Docker Compose**](#3-install-docker-and-docker-compose)
    - [4. **Enable Docker Service**](#4-enable-docker-service)
    - [5. **Set Up Application Directory**](#5-set-up-application-directory)
    - [6. **Create `docker-compose.yml`**](#6-create-docker-composeyml)
    - [7. **Create Database Seed Script**](#7-create-database-seed-script)
    - [8. **Grant Docker Permissions to User**](#8-grant-docker-permissions-to-user)
    - [9. **Run Docker Compose**](#9-run-docker-compose)
    - [Key Notes](#key-notes)

## Infrastructure

This document outlines the infrastructure setup described in the provided Terraform code. The setup creates an application server (EC2 instance) and a database server (EC2 instance), both within AWS, along with necessary networking and security configurations.

### **Application Server (EC2 Instance)**

- **Application EC2 Instance**: The EC2 instance where the Java application will run.
  - Configures the instance with a specific AMI (Ubuntu 22.04), instance type, and SSH key pair.
  - User data is passed to provision the instance, including a GitHub token and database connection details.

### **Networking and Security**

- **Ingress and Egress Rules**:
  - For both the application and database instances, there are rules that define which ports and traffic types are allowed:
    - **SSH (Port 22)**: Access for secure shell login.
    - **HTTP (Port 80)**: For communication between the application server and external users.
    - Egress rules allow all outbound traffic from both instances.

### **Variables and Parameters**

- **User Data Scripts**:
  - The `java-app-prov.sh` script provisions the application server. It sets up the necessary environments, such as installing Java and MySQL, as well as seeding the database with initial data.

---

## Docker Image

We create an image to deploy that:

1. Uses Maven and OpenJDK 17 to build and run the application.
2. Sets up the working directory and copies the project files.
3. Builds the project without running tests.
4. Starts the Spring Boot application by default when the container is run.

Using our own image will gives us benefits such as:

- Lightweight base image reduces container size.
- Ensures the build and runtime environment are consistent.
- Automates the process of building and running the Spring Boot application.

Here's the full process breakdown: [How to create the Docker Image for the Java app](docker-image.md)

## Docker-compose

We need to creat a setup ideal for a Java Spring Boot application backed by a MySQL database, ensuring proper dependency management and persistent storage.
Here's what we need:

1. **Database Service**:
   - Uses MySQL with persistent storage and initializes using a local SQL script.
   - Includes a healthcheck to ensure MySQL is ready before dependent services start.

2. **Application Service**:
   - Runs a Java application from a [custom Docker image](#docker-image).
   - Depends on the `database` service and starts only when it is healthy.
   - Exposes the application on port `80`.

3. **Volumes**:
   - `mysql-data` ensures MySQL data is retained even after container restarts.

Here's the full process breakdown: [How to create the Docker Compose file for the Java app](docker-compose.md)

## Provisioning script

This script is passed as **user data** to an EC2 instance during its launch. It is used to configure the instance, install software, and set up services automatically upon boot.

- **Purpose**:
  - Automates instance setup.
  - Deploys a Dockerized application.
  - Seeds the database with initial data.

### 1. **Begin Script**

```bash
#!/bin/bash
```

- Specifies the script interpreter (`/bin/bash`), ensuring that the commands run in a Bash shell.

---

### 2. **Update and Upgrade Packages**

```bash
echo "[UPDATE & UPGRADE PACKAGES]"
echo "Updating package list..."
sudo apt-get update -y
echo "Upgrading installed packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
```

- **Purpose**: Updates the package list and upgrades installed packages to the latest versions.
- **`DEBIAN_FRONTEND=noninteractive`**: Suppresses interactive prompts during the upgrade process.
- **Logging**: Prints progress messages to indicate the operation's status.

---

### 3. **Install Docker and Docker Compose**

```bash
echo "[DOCKER]: Installing Docker"
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker.io docker-compose -y
```

- **Installs Docker and Docker Compose**: Ensures that the required containerization tools are available.
- **`-y`**: Automatically confirms installation prompts.

---

### 4. **Enable Docker Service**

```bash
echo "[DOCKER]: Enabling Docker"
sudo systemctl enable docker
echo "[DOCKER]: Provisioning Complete."
sudo docker --version
```

- **Enables Docker**: Configures Docker to start on system boot.
- **Logs Docker Version**: Verifies installation by outputting the installed Docker version.

---

### 5. **Set Up Application Directory**

```bash
mkdir /home/ubuntu/app
cd /home/ubuntu/app
```

- **Creates Directory**: Establishes `/home/ubuntu/app` as the working directory for the application files.
- **Navigates to Directory**: Moves into the directory for subsequent operations.

---

### 6. **Create `docker-compose.yml`**

```bash
sudo tee ./docker-compose.yml <<EOF
${DOCKER_COMPOSE_YML}
EOF
```

- **Creates `docker-compose.yml`**: Writes the contents of the `DOCKER_COMPOSE_YML` variable into the `docker-compose.yml` file. The variable is likely passed through Terraform.

---

### 7. **Create Database Seed Script**

```bash
sudo tee ./library.sql <<EOF
${DATABASE_SEED_SQL}
EOF
```

- **Creates `library.sql`**: Writes the contents of the `DATABASE_SEED_SQL` variable into `library.sql`, which is used to seed the database. This content is also likely passed through Terraform.

---

### 8. **Grant Docker Permissions to User**

```bash
sudo usermod -aG docker ubuntu
```

- **Adds `ubuntu` User to `docker` Group**: Grants the `ubuntu` user permission to run Docker commands without `sudo`.

---

### 9. **Run Docker Compose**

```bash
sudo -u ubuntu -i bash <<'EOF'
cd /home/ubuntu/app
docker-compose down
docker-compose up -d
EOF
```

- **Runs Commands as `ubuntu` User**:
  - Navigates to `/home/ubuntu/app`.
  - Brings down any existing Docker Compose services with `docker-compose down`.
  - Starts the application in detached mode (`-d`) using `docker-compose up`.

---

### Key Notes

- **Terraform Variables**:
  - **`${DOCKER_COMPOSE_YML}`**: Represents the contents of the `docker-compose.yml` file, dynamically provided via Terraform.
  - **`${DATABASE_SEED_SQL}`**: Represents the SQL script to seed the database, also provided via Terraform.
