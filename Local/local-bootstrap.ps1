param(
    [string]$SqlServer = ".\\SQLEXPRESS",
    [string]$SqlUser = "sa",
    [Parameter(Mandatory = $true)]
    [string]$SqlPassword,
    [string]$WebHost = "127.0.0.1"
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$RequestPath = (Resolve-Path (Join-Path $RepoRoot "Request")).Path

function New-ConnectionString {
    param([string]$Database)
    return "Data Source=$SqlServer;Initial Catalog=$Database;Persist Security Info=True;User ID=$SqlUser;Password=$SqlPassword"
}

function Set-AppSetting {
    param([string]$Path,[string]$Key,[string]$Value)
    [xml]$xml = Get-Content -LiteralPath $Path -Raw
    $appSettings = $xml.configuration.appSettings
    if ($null -eq $appSettings) { throw "Missing <appSettings> in $Path" }
    $node = @($appSettings.add) | Where-Object { $_.key -eq $Key } | Select-Object -First 1
    if ($null -eq $node) {
        $node = $xml.CreateElement("add")
        $node.SetAttribute("key",$Key)
        $node.SetAttribute("value",$Value)
        [void]$appSettings.AppendChild($node)
    } else { $node.value = $Value }
    $xml.Save($Path)
}

function Set-ConnectionString {
    param([string]$Path,[string]$Name,[string]$Value)
    [xml]$xml = Get-Content -LiteralPath $Path -Raw
    $collection = $xml.configuration.connectionStrings
    if ($null -eq $collection) { return }
    $node = @($collection.add) | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    if ($null -ne $node) { $node.connectionString = $Value; $xml.Save($Path) }
}

$mainDb = New-ConnectionString "Db_Tank41"
$crossDb = New-ConnectionString "Db_Tank"
$countDb = New-ConnectionString "Db_Count"
$membershipDb = New-ConnectionString "Db_Membership"

$center = Join-Path $RepoRoot "Source Server\Center.Service\App.config"
Set-AppSetting $center "conString" $mainDb
Set-AppSetting $center "crosszoneString" $crossDb
Set-AppSetting $center "countDb" $countDb

$fighting = Join-Path $RepoRoot "Source Server\Fighting.Service\app.config"
Set-AppSetting $fighting "conString" $mainDb
Set-AppSetting $fighting "crosszoneString" $crossDb
Set-AppSetting $fighting "IP" "127.0.0.1"
Set-AppSetting $fighting "ServerName" "Fighting Server"

$road = Join-Path $RepoRoot "Source Server\Road.Service\App.config"
Set-AppSetting $road "conString" $mainDb
Set-AppSetting $road "crosszoneString" $crossDb
Set-AppSetting $road "countDb" $countDb
Set-AppSetting $road "IP" "127.0.0.1"
Set-AppSetting $road "LoginServerIp" "127.0.0.1"
Set-AppSetting $road "FightServerIp" "127.0.0.1"
Set-AppSetting $road "LoginCrosszoneServerIp" "127.0.0.1"
Set-AppSetting $road "Request" "http://$WebHost/request/"
Set-AppSetting $road "CountRecord" "false"

$request = Join-Path $RepoRoot "Request\Web.config"
Set-AppSetting $request "conString" $mainDb
Set-AppSetting $request "crosszoneString" $crossDb
Set-AppSetting $request "countDb" $countDb
Set-AppSetting $request "ReqPath" ($RequestPath.TrimEnd("\") + "\")
Set-AppSetting $request "LoginIP" "127.0.0.1"
Set-AppSetting $request "CountRecord" "false"

$web = Join-Path $RepoRoot "Web\web.config"
Set-AppSetting $web "conString" $mainDb
Set-AppSetting $web "membershipDb" $membershipDb
Set-AppSetting $web "countDb" $countDb
Set-AppSetting $web "ActiveIP" "127.0.0.1"
Set-AppSetting $web "LoginUrl" "http://$WebHost/request/CreateLogin.aspx"
Set-AppSetting $web "LoginOnUrl" "http://$WebHost/"
Set-AppSetting $web "FlashUrl" "http://$WebHost/play.php"
Set-AppSetting $web "FlashConfig" "http://$WebHost/config.xml"
Set-AppSetting $web "FlashSite" "http://$WebHost/Flash/"
Set-ConnectionString $web "Db_Tank41ConnectionString" $mainDb

Write-Host ""
Write-Host "DDTank 4.1 local config updated." -ForegroundColor Green
Write-Host "SQL Server: $SqlServer"
Write-Host "Restore Db_Membership, Db_Tank, Db_Tank41 and run Local\Db_Count-Minimal.sql next."
