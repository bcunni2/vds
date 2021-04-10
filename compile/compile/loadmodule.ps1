$erpref = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$sp = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])

if (Test-Path -path $sp\vds.psm1) {
	if ((Get-AuthenticodeSignature $sp\vds.psm1).Status -ne 'HashMismatch'){
		import-module $sp\vds.psm1
	}
	else {
		if (Test-Path -path \windows\system32\vds.psm1) {
			if ((Get-AuthenticodeSignature \windows\system32\vds.psm1).Status -ne 'HashMismatch'){
				import-module \windows\system32\vds.psm1
			}
			else {
				[System.Windows.Forms.MessageBox]::Show("Module could not be loaded.","Program will halt",'OK',64) | Out-Null 
				exit
			}
		}	
		else {
			[System.Windows.Forms.MessageBox]::Show("Module could not be loaded.","Program will halt",'OK',64) | Out-Null 
			exit
		}
	}
} 
else {
	if (Test-Path -path \windows\system32\vds.psm1) {
		if ((Get-AuthenticodeSignature \windows\system32\vds.psm1).Status -ne 'HashMismatch'){
			import-module \windows\system32\vds.psm1
		}
		else {
			[System.Windows.Forms.MessageBox]::Show("Module could not be loaded.","Program will halt",'OK',64) | Out-Null 
			exit
		}
	}	
	else {
		[System.Windows.Forms.MessageBox]::Show("Module could not be loaded.","Program will halt",'OK',64) | Out-Null 
		exit
	}
}
$ErrorActionPreference = $erpref