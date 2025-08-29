FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/msa2-1.0.0.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
