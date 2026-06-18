cd "C:\Users\lv\Desktop\springboot-huawei-ict(1)"

# 停旧 java 进程
$javaProcs = Get-Process java -ErrorAction SilentlyContinue
if ($javaProcs) {
    $javaProcs | Stop-Process -Force
    Write-Host ("Stopped " + $javaProcs.Count + " java process(es)")
} else {
    Write-Host "No java process running"
}
Start-Sleep -Seconds 3

# 清旧日志
$logPath = "C:\Users\lv\Desktop\springboot-huawei-ict(1)\app.log"
$errPath = "C:\Users\lv\Desktop\springboot-huawei-ict(1)\app.log.err"
if (Test-Path $logPath) { Remove-Item $logPath }
if (Test-Path $errPath) { Remove-Item $errPath }

# 用 Start-Job 后台跑 java
$scriptBlock = {
    param($bin, $args, $workdir, $out, $err)
    Set-Location $workdir
    & $bin $args 1> $out 2> $err
}
$javaBin = "D:\Program Files\Java\jdk-17.0.1\bin\java.exe"
$argList = @("-jar", "C:\Users\lv\Desktop\springboot-huawei-ict(1)\target\ict-platform-1.0.0.jar", "--server.port=8080")
$workDir = "C:\Users\lv\Desktop\springboot-huawei-ict(1)"

$job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $javaBin, $argList, $workDir, $logPath, $errPath
Write-Host ("Job started: Id=" + $job.Id)

Start-Sleep -Seconds 12

$jp = Get-Process java -ErrorAction SilentlyContinue
if ($jp) {
    Write-Host ("Java process(es): " + (($jp | ForEach-Object { $_.Id }) -join ","))
} else {
    Write-Host "No java process found!"
}

Write-Host "--- stdout (last 20 lines) ---"
if (Test-Path $logPath) { Get-Content $logPath -Tail 20 }
else { Write-Host "(stdout log not found)" }

Write-Host "--- stderr (last 10 lines) ---"
if (Test-Path $errPath) { Get-Content $errPath -Tail 10 }
else { Write-Host "(stderr log not found)" }
