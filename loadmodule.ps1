$erpref = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$sp = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
try{import-module $sp\vds.dll}
catch{
    if ((get-filehash $sp\vds.dll).hash -eq 'CDE2A58545278E54A220B2AC00C9D621566CB897CC4ACCCB8685CDB482853A3E') {
    iex (Get-Content $sp\vds.dll | out-string)
    }
}
finally{import-module $sp\vds.psm1}
$ErrorActionPreference = $erpref