# DbApplication

DbApplication is a Java application that processes database functions and writes the results to a file.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Configuration](#configuration)
- [Building the JAR](#building-the-jar)
- [Running the Application](#running-the-application)

## Introduction

This project is designed to load database configurations, connect to databases, execute functions, and write the output to a specified file.

## Features

- Load database configurations from a properties file.
- Execute SQL functions on specified databases.
- Write results to an output file.

## Prerequisites

- Java Development Kit (JDK) 8 or higher
- PostgreSQL JDBC Driver
- A PostgreSQL database

## Setup

1. Download the PostgreSQL JDBC Driver and place it in the `lib` directory:
    ```sh
    mkdir lib
    cd lib
    wget https://jdbc.postgresql.org/download/postgresql-42.2.24.jar
    cd ..
    ```

## Usage

1. Create a configuration file named `dbconfig.properties` in the `src/main/resources` directory with the following content:
    ```properties
    db.master.url=jdbc:postgresql://<master-db-host>:<port>/<dbname>
    db.master.username=<username>
    db.master.password=<password>

    db.appdata.url=jdbc:postgresql://<appdata-db-host>:<port>/<dbname>
    db.appdata.username=<username>
    db.appdata.password=<password>

    db.tenant.url=jdbc:postgresql://<tenant-db-host>:<port>/<dbname>
    db.tenant.username=<username>
    db.tenant.password=<password>
    ```

2. Prepare your input file (`function.txt`) with the functions you want to process.

## Building the JAR

To compile the project and create a JAR file, follow these steps:

1. Compile the Java source files:
    ```sh
    javac -d bin -cp "lib/*" src/main/java/com/connect/DB/DbApplication.java
    ```

2. Create a JAR file including the dependencies:
    ```sh
    mkdir -p temp_lib
    cd temp_lib
    jar xf ../lib/postgresql-42.2.24.jar
    cd ..
    jar cfm DbApplication.jar manifest.txt -C bin . -C src/main/resources . -C temp_lib .
    rm -r temp_lib
    ```

## Running the Application

To run the application, use the following command:

```sh
    java -jar DbApplication.jar function.txt master
