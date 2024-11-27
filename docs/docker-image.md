# Docker Image

- [Docker Image](#docker-image)
  - [Overview](#overview)
  - [Base Image](#base-image)
  - [Working Directory](#working-directory)
  - [Copy Application Source](#copy-application-source)
  - [Build the Project](#build-the-project)
  - [Default Command](#default-command)
  - [Build the Image](#build-the-image)
  - [Push the Image](#push-the-image)

## Overview

We create an image to deploy that:

1. Uses Maven and OpenJDK 17 to build and run the application.
2. Sets up the working directory and copies the project files.
3. Builds the project without running tests.
4. Starts the Spring Boot application by default when the container is run.

Using our own image will gives us benefits such as:

- Lightweight base image reduces container size.
- Ensures the build and runtime environment are consistent.
- Automates the process of building and running the Spring Boot application.

## Base Image

```dockerfile
FROM maven:3.8.5-openjdk-17-slim
```

- This sets the base image to `maven:3.8.5-openjdk-17-slim`.
- **Maven Version**: 3.8.5 is used for building and managing the project dependencies.
- **Java Version**: OpenJDK 17 is included for running the Spring Boot application.
- **Slim Variant**: A smaller image size is chosen to reduce the overhead.

---

## Working Directory

```dockerfile
WORKDIR /LibraryProject2
```

- Sets the working directory inside the container to `/LibraryProject2`.
- All subsequent commands will execute relative to this directory.

---

## Copy Application Source

```dockerfile
COPY ./repo/LibraryProject2 .
```

- Copies the contents of the local directory `./repo/LibraryProject2` to the container's working directory `/LibraryProject2`.

---

## Build the Project

```dockerfile
RUN mvn clean package -DskipTests
```

- Executes Maven commands to clean and package the project.
- **`clean`**: Removes any previous builds or temporary files.
- **`package`**: Compiles the code and packages it into a JAR or WAR file.
- **`-DskipTests`**: Skips running the unit tests during the build process to save time.

---

## Default Command

```dockerfile
CMD [ "mvn", "spring-boot:run" ]
```

- Specifies the default command to execute when the container runs.
- **`mvn spring-boot:run`**: Starts the Spring Boot application.

## Build the Image

```sh
docker build -t shonifari8/java-app:v1 .
```

- Specifies the default command to execute when the container runs.
- **`mvn spring-boot:run`**: Starts the Spring Boot application.

## Push the Image

```sh
docker push shonifari8/java-app:v1 
```

---