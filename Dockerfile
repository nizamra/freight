# Use an OpenJDK base image
FROM openjdk:8-jdk-slim

# Install dependancies for the project
RUN apt-get update && \
    apt-get install -y maven

# Set the working directory inside the container
WORKDIR /app

# Copy the project dependencies and build files
COPY ./src /app/src
COPY ./pom.xml /app

# Build the project
RUN mvn clean install -DskipTests

# Expose the port that Spring Boot is running on
EXPOSE 8080

# Set the entry point for the container
CMD ["java", "-jar", "/app/target/suspicious-events-detector-0.0.1-SNAPSHOT.jar"]
