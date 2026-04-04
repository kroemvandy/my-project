# -------- Build stage --------
FROM gradle:8.5-jdk17 AS builder

WORKDIR /app

# Copy Gradle files first (for caching dependencies)
COPY build.gradle settings.gradle gradlew ./
COPY gradle gradle

# Download dependencies (cache layer)
RUN ./gradlew dependencies --no-daemon || true

# Copy source code
COPY src src

# Build the application
RUN ./gradlew build -x test --no-daemon

# -------- Runtime stage --------
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# Copy built jar from builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]