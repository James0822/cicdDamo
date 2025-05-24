# 第一阶段：使用Maven镜像构建项目
FROM maven:3.8.6-openjdk-17-slim AS builder
WORKDIR /app
COPY pom.xml .
# 先下载依赖（利用Docker缓存层）
RUN mvn dependency:go-offline

COPY src ./src
# 打包应用（跳过测试以加快构建速度，测试已在Jenkins流水线中完成）
RUN mvn clean package -DskipTests

# 第二阶段：使用轻量级JRE运行环境
FROM openjdk:17-jdk-slim
WORKDIR /app

# 从构建阶段复制打包好的JAR文件
COPY --from=builder /app/target/awscicd-test-*.jar /app/app.jar

# 设置时区（可选）
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 暴露端口（根据实际应用需要修改）
EXPOSE 8080

# 设置容器启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
