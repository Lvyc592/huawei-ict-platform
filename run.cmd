@echo off
cd /d "C:\Users\lv\Desktop\springboot-huawei-ict(1)\springboot-huawei-ict(1)"
"D:\Program Files\Java\jdk-18.0.2.1\bin\java.exe" -jar target\ict-platform-1.0.0.jar --server.port=8080 > app.log 2> app.log.err
