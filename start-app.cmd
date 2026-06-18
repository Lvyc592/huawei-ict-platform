@echo off
cd /d C:\Users\nsf\Desktop\test\change\springboot-huawei-ict
mvn spring-boot:run --settings custom-settings.xml --batch-mode > app-output.log 2>&1
