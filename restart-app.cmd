@echo off
set MAVEN_OPTS=--add-opens java.base/java.lang=ALL-UNNAMED --add-opens jdk.zipfs/jdk.nio.zipfs=ALL-UNNAMED
cd /d "C:\Users\lv\Desktop\springboot-huawei-ict(1)"
call "D:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2026.1\plugins\maven\lib\maven3\bin\mvn.cmd" spring-boot:run -DskipTests -Dmaven.repo.local=C:\Users\lv\.m2\repository "-Dspring-boot.run.jvmArguments=-Dserver.port=8080" --batch-mode > app-run.log 2>&1
