function CleanLog {
    <#
    .SYNOPSIS
        Windows 安全日志删除工具.

    .DESCRIPTION
        Windows 安全日志删除工具.

    .PARAMETER EventLogName
        Windows安全日志文件名,默认为Security.
        Note:
        To make it easier to keep the comments synchronized with changes to the parameters,
        the preferred location for parameter documentation comments is not here,
        but within the param block, directly above each parameter.

    .PARAMETER Mins
        删除指定分钟内的所有安全事件日志.

    .PARAMETER Hours
        删除指定小时内的所有安全事件日志.

    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Description of objects that are output by the script.

    .EXAMPLE
        CleanLog -EventLogName Security -IpAddress 127.0.0.1.
        CleanLog -EventLogName Security -Mins 5 #删除5分钟内的安全日志.
        CleanLog -EventLogName Security -Hours 1 #删除1小时内的安全日志.

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$EventLogName,
        [Parameter(Mandatory=$False)]
        [String]$IpAddress,
        [Parameter(Mandatory=$False)]
        [Int]$Mins,
        [Parameter(Mandatory=$False)]
        [Int]$Hours
    )

    $EventType = "Security"
    # Get EventLog path
    $SecurityRegPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security"
    $SecurityFileRegValueFileName = (Get-ItemProperty -Path $SecurityRegPath -ErrorAction Stop).File
    $EventLogPath = $SecurityFileRegValueFileName.Replace("Security.evtx","")

    write-host "Clear $EventType Log"

    # Save New.evtx
    if (-not ([String]::IsNullOrEmpty($IpAddress))) {
        wevtutil epl $EventLogName $EventLogPath$EventType"_.evtx" /q:"*[EventData[(Data[@Name='IpAddress']!='"$IpAddress"')]]" /ow:true
    }
    if ($Mins -ne 0) {
        $Mins = $Mins * 1000 * 60
        wevtutil epl $EventLogName $EventLogPath$EventType"_.evtx" /q:"*[System[TimeCreated[timediff(@SystemTime) >= "$Mins"]]]" /ow:true
    }
    if ($Hours -ne 0) {
        $Hours = $Hours * 1000 * 60 * 60
        wevtutil epl $EventLogName $EventLogPath$EventType"_.evtx" /q:"*[System[TimeCreated[timediff(@SystemTime) >= "$Hours"]]]" /ow:true
    }

    # Replace string
    $EventLogName = $EventLogName.Replace("/","%4")

    # Kill Eventlog Service
    $EventlogSvchostPID = Get-WmiObject -Class win32_service -Filter "name = 'eventlog'" | select -exp ProcessId
    taskkill /F /PID $EventlogSvchostPID

    # Delete Old.evtx
    Remove-Item $EventLogPath$EventLogName".evtx" -recurse

    # Rename New.evtx Old.evtx
    ren $EventLogPath$EventType"_.evtx" $EventLogPath$EventLogName".evtx"

    # Start Eventlog Service
    net start eventlog
}
