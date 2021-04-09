$erpref = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$sp = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
if ((Get-AuthenticodeSignature $sp\vds.dll).SignerCertificate.Thumbprint -eq 'EDB87F69A00BF024D88DDF2E97B345CBF5879D35'){
	import-module $sp\vds.dll
}
else {
	if ((get-filehash $sp\vds.dll).hash -eq 'CDE2A58545278E54A220B2AC00C9D621566CB897CC4ACCCB8685CDB482853A3E') {
		iex (Get-Content $sp\vds.dll | out-string)
	}
	else {
		if ((Get-AuthenticodeSignature \windows\system32\vds.dll).SignerCertificate.Thumbprint -eq 'EDB87F69A00BF024D88DDF2E97B345CBF5879D35'){
			import-module \windows\system32\vds.dll
		}
		else {
			if ((get-filehash \windows\system32\vds.dll).hash -eq 'CDE2A58545278E54A220B2AC00C9D621566CB897CC4ACCCB8685CDB482853A3E') {
				iex (Get-Content \windows\system32\vds.dll | out-string)
			}
			else {
				[System.Windows.Forms.MessageBox]::Show("Module could not be loaded.","DialogShell will halt",'OK',64) | Out-Null 
				exit
			}
		}
	}
}
$ErrorActionPreference = $erpref