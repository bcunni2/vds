$erpref = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$sp = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
if (((Get-AuthenticodeSignature $sp\vds.psm1).Status -ne 'HashMismatch') -and ((Get-AuthenticodeSignature $sp\vds.psm1).SignerCertificate.Thumbprint -eq 'EDB87F69A00BF024D88DDF2E97B345CBF5879D35')){
	import-module $sp\vds.psm1
}
else {
	if (((Get-AuthenticodeSignature \windows\system32\vds.psm1).Status -ne 'HashMismatch') -and ((Get-AuthenticodeSignature \windows\system32\vds.psm1).SignerCertificate.Thumbprint -eq 'EDB87F69A00BF024D88DDF2E97B345CBF5879D35')){
		import-module \windows\system32\vds.psm1
	}
	else {
		[System.Windows.Forms.MessageBox]::Show("Module could not be loaded.","Program will halt",'OK',64) | Out-Null 
		exit
	}
}
$ErrorActionPreference = $erpref