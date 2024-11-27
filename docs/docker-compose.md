# Docker Compose deployment

- [Docker Compose deployment](#docker-compose-deployment)
  - [Overview](#overview)
  - [Services](#services)
    - [1. **Database Service**](#1-database-service)
      - [Ports](#ports)
      - [Environment Variables](#environment-variables)
      - [Volumes](#volumes)
      - [Healthcheck](#healthcheck)
    - [2. **Application Service**](#2-application-service)
      - [Dependency](#dependency)
      - [Ports](#ports-1)
      - [Environment Variables](#environment-variables-1)
  - [Volumes](#volumes-1)
  - [Summary](#summary)

## Overview

Here's a breakdown of the [docker-compose.yml](docker-compose.md) file that deploys our service.

---

## Services

### 1. **Database Service**

```yaml
  database:
    image: mysql
```

- **`database`**: Defines a service named `database`.
- **`image: mysql`**: Specifies that the MySQL official image from Docker Hub will be used.

---

#### Ports

```yaml
    ports:
      - "3306:3306"
```

- Maps the container's MySQL port (`3306`) to the host machine's port `3306`, making it accessible from outside the container.

---

#### Environment Variables

```yaml
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: library
```

- **`MYSQL_ROOT_PASSWORD`**: Sets the root password for the MySQL database.
- **`MYSQL_DATABASE`**: Automatically creates a database named `library` upon initialization.

---

#### Volumes

```yaml
    volumes:
      - mysql-data:/var/lib/mysql
      - ./library.sql:/docker-entrypoint-initdb.d/library.sql
```

- **`mysql-data:/var/lib/mysql`**:
  - Maps a named volume `mysql-data` to MySQL's data directory (`/var/lib/mysql`), ensuring that the database data persists even if the container is restarted or deleted.
- **`./library.sql:/docker-entrypoint-initdb.d/library.sql`**:
  - Mounts the local `library.sql` file into the container. MySQL automatically runs this script to initialize the database on first startup.

---

#### Healthcheck

```yaml
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 3
```

- Monitors the health of the MySQL service.
- **`test`**: Runs `mysqladmin ping` to check if MySQL is ready and accessible.
- **`interval`**: Checks health every 10 seconds.
- **`timeout`**: Allows up to 5 seconds for each check.
- **`retries`**: Fails after 3 unsuccessful attempts.

---

### 2. **Application Service**

```yaml
  app:
    image: shonifari8/java-app:v1
```

- **`app`**: Defines a service named `app`.
- **`image: shonifari8/java-app:v1`**: Uses the custom image `shonifari8/java-app:v1`, assumed to contain the Java application.

---

#### Dependency

```yaml
    depends_on:
      database:
        condition: service_healthy
```

- Ensures that the `app` service starts only after the `database` service is healthy, as determined by its healthcheck.

---

#### Ports

```yaml
    ports:
      - "80:5000"
```

- Maps the container's port `5000` (where the Java app runs) to the host machine's port `80`, making it accessible from a browser or API client via `http://localhost`.

---

#### Environment Variables

```yaml
    environment:
       DB_HOST: "jdbc:mysql://database:3306/library"
       DB_USER: "root"
       DB_PASS: "password"
```

- Configures the application to connect to the database:
  - **`DB_HOST`**: Specifies the MySQL connection string. The hostname `database` refers to the `database` service defined in the Compose file.
  - **`DB_USER`**: Sets the MySQL username as `root`.
  - **`DB_PASS`**: Sets the password to match the `MYSQL_ROOT_PASSWORD`.

---

## Volumes

```yaml
volumes:
  mysql-data:
```

- **`mysql-data`**: A named volume that ensures persistent storage for the MySQL database data.

---

## Summary

1. **Database Service**:
   - Uses MySQL with persistent storage and initializes using a local SQL script.
   - Includes a healthcheck to ensure MySQL is ready before dependent services start.

2. **Application Service**:
   - Runs a Java application from a custom Docker image.
   - Depends on the `database` service and starts only when it is healthy.
   - Exposes the application on port `80`.

3. **Volumes**:
   - `mysql-data` ensures MySQL data is retained even after container restarts.

This setup is ideal for a Java Spring Boot application backed by a MySQL database, ensuring proper dependency management and persistent storage.
