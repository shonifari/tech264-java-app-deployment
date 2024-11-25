# Local App deployment

- [Local App deployment](#local-app-deployment)
  - [1. Install Java JDK](#1-install-java-jdk)
  - [2. Install MySQL](#2-install-mysql)
  - [3. Create database](#3-create-database)
  - [4. Export variables](#4-export-variables)
  - [5. Run application](#5-run-application)

## 1. Install Java JDK

Follow this guide on [how to install and setup Java, JDK and Maven](installing-java.md)

## 2. Install MySQL

Follow this guide on [how to install and setup MySQL](installing-mysql.md)

## 3. Create database

Access mysql with this command `mysql -u root -p`.

Run the script that creates and seeds the database

```mysql

SOURCE path/to/sql/file
```

## 4. Export variables

Export the following variables for the app to be able to connect to the database:

- Variable name: `DB_HOST`
      *Description: Acts like a connection string
      * Value: `jdbc:mysql://$DATABASE_IP:3306/library`
  - Variable name: `DB_USER`
    - Description: The username setup in your MySQL database
    - Value: Can be whatever what you want to setup
  - Variable name: `DB_PASS`
    - Description: The password setup in your MySQL database
    - Value: Can be whatever what you want to setup

## 5. Run application

Start the application with `mvn spring-boot:run` or  `mvn spring-boot:start` to run it in the background.

Access <http://localhost:5000/web/authors> to see the content of the database.
