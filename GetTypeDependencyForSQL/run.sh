#!/bin/bash

# Set project root and build directories
PROJECT_ROOT="D:\Learn\GitHub\DB2"

BUILD_DIR="$PROJECT_ROOT\build\libs"

# Navigate to project root
cd $PROJECT_ROOT

# Clean and build the project
./gradlew clean build

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Build failed. Exiting."
    exit 1
fi

# Run the application
java -jar $BUILD_DIR\DB-0.0.1-SNAPSHOT.jar functions.txt pg tenant

# Alternatively, specify the classpath and main class explicitly
# java -cp $BUILD_DIR/MySpringBootApplication-1.0-SNAPSHOT.jar com.connect.DB.DbApplication functions.txt pg tenant
