# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.war app.war

EXPOSE 8080
ENTRYPOINT ["java", \
  "-Dspring.profiles.active=prod", \
  "-XX:MaxRAMPercentage=75.0", \
  "-jar", "app.war"]