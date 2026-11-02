param(
  [Parameter(Mandatory=$true)][string]$SourcePath,
  [Parameter(Mandatory=$true)][string]$RepoPath,
  [switch]$Watch,
  [int]$DebounceSeconds=8
)
$ErrorActionPreference='Stop'
$logDir=Join-Path $env:LOCALAPPDATA 'MirageAutoSync'
$log=Join-Path $logDir 'sync.log'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
function Log([string]$m){Add-Content -LiteralPath $log -Value "$(Get-Date -Format s) $m" -Encoding UTF8}
function Sync-Once {
  if(!(Test-Path -LiteralPath $SourcePath -PathType Container)){throw "Source folder not found: $SourcePath"}
  if(!(Test-Path -LiteralPath (Join-Path $RepoPath '.git'))){throw "Not a Git repository: $RepoPath"}
  $exclude=@('.git','.github','node_modules','.venv','venv','__pycache__','.cache','secrets','secret','credentials')
  Get-ChildItem -LiteralPath $SourcePath -File -Recurse -Force | ForEach-Object {
    $rel=$_.FullName.Substring($SourcePath.TrimEnd('\','/').Length).TrimStart('\','/')
    $parts=$rel -split '[\\/]'
    if($parts | Where-Object {$exclude -contains $_}){return}
    if($rel -match '(^|[\\/])\.env($|\.)' -and $rel -notmatch '\.env\.example$'){return}
    if($rel -match '(?i)(token|credential|secret).*\.json$|\.(pem|key|p12|pfx|keystore|jks|kdbx)$'){return}
    $dest=Join-Path $RepoPath $rel
    $dir=Split-Path -Parent $dest
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
  }
  & git -C $RepoPath add --all
  if($LASTEXITCODE -ne 0){throw 'git add failed'}
  & git -C $RepoPath diff --cached --quiet
  if($LASTEXITCODE -eq 0){Log 'No changes';return}
  if($LASTEXITCODE -ne 1){throw 'git diff failed'}
  & git -C $RepoPath commit -m ("chore(sync): update Mirage Skill " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
  if($LASTEXITCODE -ne 0){throw 'git commit failed'}
  & git -C $RepoPath push origin HEAD:main
  if($LASTEXITCODE -ne 0){throw 'git push failed'}
  Log 'Committed and pushed to origin/main'
}
if(!$Watch){Sync-Once;exit 0}
Sync-Once
$w=New-Object IO.FileSystemWatcher $SourcePath
$w.IncludeSubdirectories=$true
$w.NotifyFilter=[IO.NotifyFilters]::FileName -bor [IO.NotifyFilters]::DirectoryName -bor [IO.NotifyFilters]::LastWrite -bor [IO.NotifyFilters]::Size
$w.EnableRaisingEvents=$true
foreach($e in @('Changed','Created','Deleted','Renamed')){Register-ObjectEvent $w $e -SourceIdentifier "Mirage_$e" | Out-Null}
$pending=$false
$last=Get-Date
Log "Watcher started: $SourcePath"
try{
  while($true){
    $ev=Wait-Event -Timeout 2
    if($ev -and $ev.SourceIdentifier -like 'Mirage_*'){Remove-Event -EventIdentifier $ev.EventIdentifier -ErrorAction SilentlyContinue;$pending=$true;$last=Get-Date}
    if($pending -and ((Get-Date)-$last).TotalSeconds -ge $DebounceSeconds){
      try{Sync-Once}catch{Log ("Sync error: "+$_.Exception.Message)}
      $pending=$false
    }
  }
}finally{
  $w.EnableRaisingEvents=$false;$w.Dispose()
  Get-EventSubscriber | Where-Object {$_.SourceIdentifier -like 'Mirage_*'} | Unregister-Event -Force
  Log 'Watcher stopped'
}
