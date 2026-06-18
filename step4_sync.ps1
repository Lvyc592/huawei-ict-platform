cd "C:\Users\lv\Desktop\springboot-huawei-ict(1)"
Copy-Item -Recurse -Force "target\classes\*" "target\extracted-lib\BOOT-INF\classes\"
Get-Item "target\extracted-lib\BOOT-INF\classes\com\huawei\ict\service\AuthService.class" | Select LastWriteTime, Length
