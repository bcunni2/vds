$erpref = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$sp = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
if ((Get-AuthenticodeSignature $sp\vds.psm1).SignerCertificate.Status -eq 'Valid'){
	import-module $sp\vds.psm1
}
else {
	if ((get-filehash $sp\vds.dll).hash -eq '2D3BD382C2FF0E2D6102B38FA3253253BD04C1DED5FF9A8686F10F86F8DB113C') {
		iex (Get-Content $sp\vds.dll | out-string)
	}
	else {
		if ((Get-AuthenticodeSignature \windows\system32\vds.psm1).SignerCertificate.Status -eq 'Valid'){
			import-module \windows\system32\vds.psm1
		}
		else {
			if ((get-filehash \windows\system32\vds.dll).hash -eq '2D3BD382C2FF0E2D6102B38FA3253253BD04C1DED5FF9A8686F10F86F8DB113C') {
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