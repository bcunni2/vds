powershell -Command "&{ Start-Process C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ArgumentList ' -windowstyle hidden -ep bypass -File %cd%\setup.ps1 install' -Verb RunAs }"