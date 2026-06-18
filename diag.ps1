cd "C:\Users\lv\Desktop\springboot-huawei-ict(1)"

# 简单诊断
$logPath = "C:\Users\lv\Desktop\springboot-huawei-ict(1)\app.log"
$errPath = "C:\Users\lv\Desktop\springboot-huawei-ict(1)\app.log.err"

# 先看现在有没有 java 进程
Write-Host "=== java procs now ==="
Get-Process java -ErrorAction SilentlyContinue | Select Id, ProcessName | Format-Table -AutoSize

# 看看 log 文件
Write-Host "=== files ==="
Get-ChildItem app.log, app.log.err, run.cmd, target\ict-platform-1.0.0.jar 2>&1 | Select Name, Length, LastWriteTime | Format-Table -AutoSize

# 直接试一次同步运行 run.cmd，看错误
Write-Host "=== run.cmd contents ==="
Get-Content run.cmd

Write-Host "=== manual test: java -version via run.cmd style ==="
$testLog = "C:\Users\lv\Desktop\springboot-huawei-ict(1)\test.log"
& cmd /c "D:\Program Files\Java\jdk-17.0.1\bin\java.exe -version > `"$testLog`" 2>&1"
Get-Content $testLog
