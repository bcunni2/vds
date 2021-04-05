cd compile
cd compile
powershell -executionpolicy bypass -file .\compile.ps1
powershell -executionpolicy bypass -file .\release.ps1 release.ps1 ..\compile.exe -compiler -version 0.2.7.7 -iconfile ..\..\res\compile.ico -company "vds/pwsh community" -product "DialogShell Compile" -description "DialogShell Compiler" -title "compile"
cd ..
compile.exe "..\setup.ds1" "..\setup.exe" -version 0.2.7.7 -noconsole -requireadmin -sta -iconfile ..\res\cog_go.ico -company "vds/pwsh community" -product "DialogShell Designer" -description "DialogShell Designer" -title "DialogShell Designer"
.\compile.exe .\compile-gui.ds1 .\compile-gui.exe -noconsole -sta -version 0.2.7.7 -iconfile ..\res\compile.ico -company "vds/pwsh community" -product "compile-gui" -description "compile-gui" -title "compile-gui"
.\compile.exe .\DialogShell.ds1 .\DialogShell.exe -sta -version 0.2.7.7 -iconfile ..\res\terminal.ico -company "vds/pwsh community" -product "DialogShell" -description "DialogShell" -title "DialogShell"
.\compile.exe .\DialogShell.ds1 .\DialogShell32.exe -sta -x86 -version 0.2.7.7 -iconfile ..\res\terminal.ico -company "vds/pwsh community" -product "DialogShell32" -description "DialogShell32" -title "DialogShell32"
rem Allows for legacy odbc connections.
.\compile.exe .\DialogShell.ds1 .\DialogShellCore.exe -sta -version 0.2.7.7 -iconfile ..\res\terminal.ico -company "vds/pwsh community" -product "DialogShellCore" -description "DialogShellCore" -title "DialogShellCore" -core
.\compile.exe ".\Visual DialogShell.ds1" ".\Visual DialogShell.exe" -version 0.2.7.7 -iconfile ..\res\application.ico -noconsole -sta -company "vds/pwsh community" -product "Visual DialogShell" -description "Visual DialogShell" -title "Visual DialogShell"
.\compile.exe ".\Visual DialogShell.ds1" ".\Visual DialogShell32.exe" -x86 -version 0.2.7.7 -iconfile ..\res\application.ico -noconsole -sta -company "vds/pwsh community" -product "Visual DialogShell32" -description "Visual DialogShell32" -title "Visual DialogShell32"
rem Allows for legacy ODBC connections.
.\compile.exe ".\Visual DialogShell.ds1" ".\Visual-DialogShellCore.exe" -version 0.2.7.7 -iconfile ..\res\application.ico -noconsole -sta -company "vds/pwsh community" -product "Visual DialogShellCore" -description "Visual DialogShellCore" -title "Visual DialogShellCore" -core
cd ..
cd examples
..\compile\compile.exe .\vds-ide.ds1 .\vds-ide.exe -sta -version 0.2.7.7 -noconsole -iconfile ..\res\icon.ico -company "vds/pwsh community" -product "DialogShell" -description "DialogShell" -title "DialogShell"
..\compile\compile.exe .\vds-ide.ds1 .\vds-ide32.exe -sta -x86 -version 0.2.7.7 -noconsole -iconfile ..\res\icon.ico -company "vds/pwsh community" -product "DialogShell" -description "DialogShell" -title "DialogShell"
..\compile\compile.exe .\vds-ide.ds1 .\vds-ide-core.exe -sta -version 0.2.7.7 -noconsole -iconfile ..\res\icon.ico -company "vds/pwsh community" -product "DialogShell" -description "DialogShell" -title "DialogShell" -core
cd ..
mkdir setup\compile
copy .\compile\*.exe .\setup\compile
copy .\compile\*.dll .\setup\compile
copy .\compile\*.config .\setup\compile
mkdir setup\examples
copy .\examples .\setup\examples
mkdir setup\examples\en-US
copy .\examples\en-US .\setup\examples\en-US
mkdir setup\elements
copy .\elements .\setup\elements
mkdir setup\res
xcopy .\res .\setup\res\ /E/H
mkdir setup\plugins
copy .\plugins .\setup\plugins
mkdir setup\wizards
copy .\wizards .\setup\wizards
copy .\license.md .\setup\license.md
copy .\vds.dll .\setup\compile
copy .\vds.dll .\setup\examples

setup.exe