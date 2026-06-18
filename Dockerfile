# 多阶段构建 Dockerfile for Zeabur 部署
# 阶段一：使用 Maven + JDK 21 构建项目
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# 先复制 pom.xml，利用 Docker 缓存加速依赖下载
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# 复制源码并打包
COPY src ./src
RUN mvn clean package -DskipTests -B

# 阶段二：运行环境（JRE 21 LTS）
FROM eclipse-temurin:21-jre

WORKDIR /app

# 从构建阶段复制 jar 包
COPY --from=build /app/target/*.jar app.jar

# 暴露端口（Zeabur 会自动分配 PORT 环境变量）
EXPOSE 8080

# 启动命令：支持 Zeabur 动态端口
ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=${PORT:-8080}"]
