# Base Image
FROM openjdk:8-jdk-alpine

# Add a volume pointing to /tmp
VOLUME /tmp

# The Application's Jar File
ARG JAR_FILE=target/TerraformApp.jar

# Add Application's Jar file to the Container
ADD ${JAR_FILE} TerraformApp.jar

# Make Port 80 available to the outside this Container
EXPOSE 8080

# Run the Jar File
ENTRYPOINT ["java", "-jar", "TerraformApp.jar"]