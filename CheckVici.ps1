while ($true) {
invoke-command -computername mccbos.cloud.mcc.loc -scriptblock { 
  $logfile = dir d:/logs/viciautoload/* | select -last 1 | get-content;
  $logfile | select-string -pattern "VERSION", "Connected to the SQL Server", "Pull leads to load" -NotMatch | select -last 50 | ft line;
  $logfile | select-string "Collection", "%" | ft line;
}

read-host
clear-host
}