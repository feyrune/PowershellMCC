invoke-command -scriptblock {
  invoke-command -computername mccbos.cloud.mcc.loc -scriptblock {
    $First=$true; $PrevLineNumber=0;
    $logfile = (dir d:/logs/proderandtabletclearing/* | select -last 1).Name;
    (select-string -Path "d:/logs/proderandtabletclearing/$logfile" -SimpleMatch "Mid Atlantic Fulfillment", "id=12" -Context 0,2) | `
    foreach-object {
      $line=$($_.Line);
      $next1line=$($_.Context.PostContext)[0];
      $next2line=$($_.Context.PostContext)[1];
      $CurrLineNumber = $($_.LineNumber);

      $skip0=$false; 
$skip1=$false;
 $skip2=$false;
      if ($PrevLineNumber -eq ($($CurrLineNumber)-2)) { $skip0=$true; };
      if ($PrevLineNumber -eq ($($CurrLineNumber)-1)) { $skip0=$true; $skip1=$true; };
      if ($next1line -like "*End Clearing*") { $skip2=$true; };
      
      if ($First -eq $false) {
        if ($skip0 -eq $false) { write-output "$CurrLineNumber $line"; };
        if ($skip1 -eq $false) { write-output "$($CurrLineNumber+1) $next1line"; };
        if ($skip2 -eq $false) { write-output "$($CurrLineNumber+2) $next2line"; };
      };

      if ($First -eq $true) {
        write-output "$CurrLineNumber $line";
        write-output "$($CurrLineNumber+1) $next1line";
        write-output "$($CurrLineNumber+2) $next2line";
        $First=$false;
      };

      $PrevLineNumber = $CurrLineNumber;
    };
  };

  invoke-command -computername mccweb1.cloud.mcc.loc -scriptblock { 
    $today = "{0} {1}{2}*" -f (get-date).year, (get-date).month.tostring("00"), (get-date).day.tostring("00");
    $files = dir d:/ftpshares/midatlantic/$today;
    $filecount = $files.count;
    write-output "";
    write-output "There are $filecount files in MidAtlantic FTP folder";
    $files | ft Name, LastWriteTime
  };
};

Read-Host