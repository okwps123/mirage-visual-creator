param(
 [string]$SourcePath=(Join-Path $env:USERPROFILE '.codex\skills\mirage-visual-creator'),
 [string]$RepoPath=(Join-Path $env:USERPROFILE 'source\mirage-visual-creator')
)
$ErrorActionPreference='Stop'
$url='https://github.com/okwps123/mirage-visual-creator.git'
$task='MirageVisualCreatorAutoSync'
if(!(Get-Command git -ErrorAction SilentlyContinue)){throw 'Install Git for Windows first.'}
if(!(Test-Path -LiteralPath $SourcePath -PathType Container)){throw "Local Skill source not found: $SourcePath"}
$parent=Split-Path -Parent $RepoPath
New-Item -ItemType Directory -Force -Path $parent | Out-Null
if(!(Test-Path -LiteralPath (Join-Path $RepoPath '.git'))){
 if(Test-Path -LiteralPath $RepoPath){
  if((Get-ChildItem -LiteralPath $RepoPath -Force | Measure-Object).Count -gt 0){throw "RepoPath is not empty: $RepoPath"}
  Remove-Item -LiteralPath $RepoPath -Force
 }
 & git clone $url $RepoPath
 if($LASTEXITCODE -ne 0){throw 'git clone failed; check GitHub login and repository access.'}
}
$origin=& git -C $RepoPath remote get-url origin
if($origin.Trim() -ne $url){throw "Unexpected origin remote: $origin"}
& git -C $RepoPath checkout main
if($LASTEXITCODE -ne 0){throw 'Could not check out main.'}
$sync=Join-Path $RepoPath 'scripts\auto-sync.ps1'
if(!(Test-Path -LiteralPath $sync)){throw "Sync script missing: $sync"}
& $sync -SourcePath $SourcePath -RepoPath $RepoPath
if($LASTEXITCODE -ne 0){throw 'Initial sync failed. Check GitHub authentication.'}
$args='-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "'+$sync+'" -SourcePath "'+$SourcePath+'" -RepoPath "'+$RepoPath+'" -Watch'
$action=New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $args
$trigger=New-ScheduledTaskTrigger -AtLogOn
$principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $task -Action $action -Trigger $trigger -Principal $principal -Description 'Auto-sync Mirage visual creator Skill changes to GitHub.' -Force | Out-Null
Start-ScheduledTask -TaskName $task
Write-Host 'Mirage auto-sync installed and started.'
Write-Host "Source: $SourcePath"
Write-Host "Repository: $RepoPath"
Write-Host "Log: $env:LOCALAPPDATA\MirageAutoSync\sync.log"
Write-Host "Uninstall: Unregister-ScheduledTask -TaskName $task -Confirm:\$false"
