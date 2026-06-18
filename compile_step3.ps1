cd "C:\Users\lv\Desktop\springboot-huawei-ict(1)"

$libCP = (Get-ChildItem "target\extracted-lib\BOOT-INF\lib\*.jar" | ForEach-Object { $_.FullName }) -join ";"
$lombokPath = "C:\Users\lv\Desktop\springboot-huawei-ict(1)\Userslv.m2repository\org\projectlombok\lombok\1.18.30\lombok-1.18.30.jar"
$classesDir = (Resolve-Path "target\extracted-lib\BOOT-INF\classes").Path
$fullCP = "$lombokPath;$libCP;$classesDir"

Write-Host "=== Compiling AuthService with full CP ==="
Write-Host "Lombok: $lombokPath"
Write-Host "Libs count: $((Get-ChildItem 'target\extracted-lib\BOOT-INF\lib\*.jar').Count)"
Write-Host "Classes dir: $classesDir (exists: $(Test-Path $classesDir))"

& "D:\Program Files\Java\jdk-18.0.2.1\bin\javac.exe" `
    -encoding UTF-8 `
    -cp "$fullCP" `
    -d "target\classes" `
    "src\main\java\com\huawei\ict\service\AuthService.java"

if ($LASTEXITCODE -ne 0) {
    Write-Host "COMPILE FAILED! Exit code: $LASTEXITCODE"
} else {
    Write-Host "COMPILE SUCCESS!"
    Get-Item "target\classes\com\huawei\ict\service\AuthService.class" | Select FullName, LastWriteTime, Length
}
