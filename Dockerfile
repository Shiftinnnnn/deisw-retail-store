# Build stage: Maven + Temurin 26 JDK
FROM maven:3.9.16-eclipse-temurin-26-noble AS build

WORKDIR /workspace

# Copy pom and download dependencies to leverage Docker cache
COPY pom.xml .

RUN mvn -B -f pom.xml -DskipTests dependency:go-offline

# Copy source and build the project
COPY . .

RUN mvn -B -DskipTests package


# Runtime stage: Temurin 26 JRE
FROM eclipse-temurin:26-jre-noble

WORKDIR /app

# Copy the built jar
COPY --from=build /workspace/target/*.jar app.jar

# Default env vars
ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8091
ENV JAVA_OPTS=""

EXPOSE 8091

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]
