# Use an OpenJDK base image
FROM openjdk:8-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the project dependencies and build files
COPY ./src /app/src
COPY ./pom.xml /app

# Install Maven and build the project
RUN apt-get update && \
    apt-get install -y maven && \
    mvn clean install -DskipTests

# Expose the port that Spring Boot is running on
EXPOSE 8080

# Set the entry point for the container
CMD ["java", "-jar", "/app/target/suspicious-events-detector-0.0.1-SNAPSHOT.jar"]
