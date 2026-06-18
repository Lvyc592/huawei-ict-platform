@echo off
set MAVEN_OPTS=--add-opens java.base/java.lang=ALL-UNNAMED --add-opens jdk.zipfs/jdk.nio.zipfs=ALL-UNNAMED
"D:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2026.1\plugins\maven\lib\maven3\bin\mvn.cmd" spring-boot:run -DskipTests --settings custom-settings.xml --batch-mode > app-run.log 2>&1
