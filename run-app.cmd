@echo off
cd /d C:\Users\nsf\Desktop\test\change\springboot-huawei-ict
set MAVEN_OPTS=--add-opens java.base/java.lang=ALL-UNNAMED --add-opens jdk.zipfs/jdk.nio.zipfs=ALL-UNNAMED
mvn spring-boot:run -DskipTests --settings custom-settings.xml --batch-mode > app-run.log 2>&1
