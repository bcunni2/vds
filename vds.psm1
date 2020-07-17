Add-Type -AssemblyName System.Windows.Forms,Microsoft.VisualBasic,System.Drawing, presentationframework, presentationcore, WindowsBase

Add-Type @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class vds {
[DllImport("user32.dll")]
public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);
[DllImport("user32.dll")]
public static extern bool ShowWindow(int hWnd, WindowState nCmdShow);
public enum WindowState
    {
        SW_HIDE               = 0,
        SW_SHOW_NORMAL        = 1,
        SW_SHOW_MINIMIZED     = 2,
        SW_MAXIMIZE           = 3,
        SW_SHOW_MAXIMIZED     = 3,
        SW_SHOW_NO_ACTIVE     = 4,
        SW_SHOW               = 5,
        SW_MINIMIZE           = 6,
        SW_SHOW_MIN_NO_ACTIVE = 7,
        SW_SHOW_NA            = 8,
        SW_RESTORE            = 9,
        SW_SHOW_DEFAULT       = 10,
        SW_FORCE_MINIMIZE     = 11
    }
    
[DllImport("User32.dll")]
public static extern bool MoveWindow(int hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
[DllImport("User32.dll")]
public static extern bool GetWindowRect(int hWnd, out RECT lpRect);

      
[DllImport("user32.dll", EntryPoint="FindWindow")]
internal static extern int FWBC(string lpClassName, int ZeroOnly);
public static int FindWindowByClass(string lpClassName) {
return FWBC(lpClassName, 0);}

[DllImport("user32.dll", EntryPoint="FindWindow")]
internal static extern int FWBT(int ZeroOnly, string lpTitle);
public static int FindWindowByTitle(string lpTitle) {
return FWBT(0, lpTitle);}

[DllImport("user32.dll")]
     public static extern IntPtr GetForegroundWindow();

[DllImport("user32.dll")]    
     public static extern int GetWindowTextLength(int hWnd);
     
[DllImport("user32.dll")]
public static extern IntPtr WindowFromPoint(System.Drawing.Point p);
     
[DllImport("user32.dll")]
public static extern IntPtr GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);

[DllImport("user32.dll")]
public static extern IntPtr GetClassName(IntPtr hWnd, System.Text.StringBuilder text, int count);
     
[DllImport("user32.dll")]
    public static extern bool SetWindowPos(int hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    
[DllImport ("user32.dll")]
public static extern bool SetParent(int ChWnd, int hWnd);

[DllImport("user32.dll")]
public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    
[DllImport("User32.dll")]
public static extern bool SetWindowText(IntPtr hWnd, string lpString);

//CC-BY-SA
//Adapted from script by StephenP
//https://stackoverflow.com/users/3594883/stephenp
[DllImport("User32.dll")]
extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

public struct INPUT
    { 
        public int        type; // 0 = INPUT_MOUSE,
                                // 1 = INPUT_KEYBOARD
                                // 2 = INPUT_HARDWARE
        public MOUSEINPUT mi;
    }

public struct MOUSEINPUT
    {
        public int    dx ;
        public int    dy ;
        public int    mouseData ;
        public int    dwFlags;
        public int    time;
        public IntPtr dwExtraInfo;
    }
    
const int MOUSEEVENTF_MOVED      = 0x0001 ;
const int MOUSEEVENTF_LEFTDOWN   = 0x0002 ;
const int MOUSEEVENTF_LEFTUP     = 0x0004 ;
const int MOUSEEVENTF_RIGHTDOWN  = 0x0008 ;
const int MOUSEEVENTF_RIGHTUP    = 0x0010 ;
const int MOUSEEVENTF_MIDDLEDOWN = 0x0020 ;
const int MOUSEEVENTF_MIDDLEUP   = 0x0040 ;
const int MOUSEEVENTF_WHEEL      = 0x0080 ;
const int MOUSEEVENTF_XDOWN      = 0x0100 ;
const int MOUSEEVENTF_XUP        = 0x0200 ;
const int MOUSEEVENTF_ABSOLUTE   = 0x8000 ;

const int screen_length = 0x10000 ;

public static void LeftClickAtPoint(int x, int y)
{
    //Move the mouse
    INPUT[] input = new INPUT[3];
    input[0].mi.dx = x*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
    input[0].mi.dy = y*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
    input[0].mi.dwFlags = MOUSEEVENTF_MOVED | MOUSEEVENTF_ABSOLUTE;
    //Left mouse button down
    input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    //Left mouse button up
    input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;
    SendInput(3, input, Marshal.SizeOf(input[0]));
}

public static void RightClickAtPoint(int x, int y)
{
    //Move the mouse
    INPUT[] input = new INPUT[3];
    input[0].mi.dx = x*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
    input[0].mi.dy = y*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
    input[0].mi.dwFlags = MOUSEEVENTF_MOVED | MOUSEEVENTF_ABSOLUTE;
    //Left mouse button down
    input[1].mi.dwFlags = MOUSEEVENTF_RIGHTDOWN;
    //Left mouse button up
    input[2].mi.dwFlags = MOUSEEVENTF_RIGHTUP;
    SendInput(3, input, Marshal.SizeOf(input[0]));
}
//End CC-SA
[DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);


}

 public struct RECT

    {
    public int Left;
    public int Top; 
    public int Right;
    public int Bottom;
    }
"@ -ReferencedAssemblies System.Windows.Forms,System.Drawing


<#      
        Function: FlashWindow
        Author: Boe Prox
        https://social.technet.microsoft.com/profile/boe%20prox/
        Adapted to VDS: 20190212
        License: Microsoft Limited Public License
#>
Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

public class Window
{
    [StructLayout(LayoutKind.Sequential)]
    public struct FLASHWINFO
    {
        public UInt32 cbSize;
        public IntPtr hwnd;
        public UInt32 dwFlags;
        public UInt32 uCount;
        public UInt32 dwTimeout;
    }

    //Stop flashing. The system restores the window to its original state. 
    const UInt32 FLASHW_STOP = 0;
    //Flash the window caption. 
    const UInt32 FLASHW_CAPTION = 1;
    //Flash the taskbar button. 
    const UInt32 FLASHW_TRAY = 2;
    //Flash both the window caption and taskbar button.
    //This is equivalent to setting the FLASHW_CAPTION | FLASHW_TRAY flags. 
    const UInt32 FLASHW_ALL = 3;
    //Flash continuously, until the FLASHW_STOP flag is set. 
    const UInt32 FLASHW_TIMER = 4;
    //Flash continuously until the window comes to the foreground. 
    const UInt32 FLASHW_TIMERNOFG = 12; 


    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool FlashWindowEx(ref FLASHWINFO pwfi);

    public static bool FlashWindow(IntPtr handle, UInt32 timeout, UInt32 count)
    {
        IntPtr hWnd = handle;
        FLASHWINFO fInfo = new FLASHWINFO();

        fInfo.cbSize = Convert.ToUInt32(Marshal.SizeOf(fInfo));
        fInfo.hwnd = hWnd;
        fInfo.dwFlags = FLASHW_ALL | FLASHW_TIMERNOFG;
        fInfo.uCount = count;
        fInfo.dwTimeout = timeout;

        return FlashWindowEx(ref fInfo);
    }
}
"@


##Code standards -----------------------------------------------------------------------
#Follow the patterns used in the current code.

#=====================================commands==========================================

$global:xmen = $false
$global:fieldsep = "|"
$global:database = new-object System.Data.Odbc.OdbcConnection
set-alias run invoke-expression

function beep {
    [console]::beep(500,300)
<#
    .SYNOPSIS
    Beeps
     
    .DESCRIPTION
     VDS
    beep
    
    .LINK
    https://dialogshell.com/vds/help/index.php?title=Beep
#>
}
 function clipboard ($a,$b) {
    switch ($a) {
        append {
            Set-Clipboard -Append $b
        }
        clear {
            echo $null | clip
        }
        set {
            Set-Clipboard -Value $b
        }
    }
 <#
    .SYNOPSIS
    Performs clipboard operations
    Paramters: append, clear or set
     
    .DESCRIPTION
     VDS
    clipboard set $clip
    
    .LINK
    https://dialogshell.com/vds/help/index.php?title=Clipboard
 #>
 }
 function console ($a,$b){
     switch ($a) {
         read {
             return read-host -prompt $b
         }
         write {
             write-host $b
         }
         default {
             write-host $a
         }
     }
 <#
     .SYNOPSIS
     Performs console write or read operations
      
     .DESCRIPTION
      VDS
     $read = $(console read)
    
     .LINK
     https://dialogshell.com/vds/help/index.php?title=Console
 #>
 }
 function database($a,$b) {
     switch ($a) {
         Open {
             $database.connectionstring = "DSN="+$b
             $database.Open()
         }
         Close {
             $database.Close()
         }
         Execute {
             $command = New-object System.Data.Odbc.OdbcCommand($b,$database)
             $getdata = new-object System.Data.Dataset
             (new-object System.Data.odbc.Odbcdataadapter($command)).Fill($getdata)
             return $getdata.tables
         }
     }
 <#
     .SYNOPSIS
     Performs ODBC database operations, open requires the connection name, close closes the connection, execute is a sql command that returns data tables.
      
     .DESCRIPTION
      VDS
     $q = $(database execute 'select * from table where name like $string')
     
     .LINK
     https://dialogshell.com/vds/help/index.php?title=Database
 #>  
 }
 function dialog($a,$b,$c,$d,$e,$f,$g,$h) {
     switch ($a) {
         add {
             switch ($c) {
                 default {
                     if ($c -eq $null) {
                         $Control = New-Object System.Windows.Forms.$b
                     }
                     else {
                         $Control = New-Object System.Windows.Forms.$c
                     }
                     if ($d -is [int]) {
                         $Control.Top = $d
                         $Control.Left = $e
                         $Control.Width = $f
                         $Control.Height = $g
                         $Control.Text = $h
                     }
                     if ($c -ne $null) {
                         $b.Controls.Add($Control)
                     }
                     return $Control
                 }
                 items {
                     $c.items.add($d)
                 }
                 statusstrip {
                     $statusstrip = new-object System.Windows.Forms.StatusStrip
                     $b.controls.add($statusstrip)
                     $ToolStripStatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
                     $statusstrip.Items.AddRange($ToolStripStatusLabel)
                     return $statusstrip
                 }
                 menustrip { 
                     if ($global:xmen -ne $true) {
                         $global:menuribbon = new-object System.Windows.Forms.MenuStrip
                         $b.Controls.Add($global:menuribbon)
                         $global:xmen = $true
                     }
                                 
                     $xmenutitle = new-object System.Windows.Forms.ToolStripMenuItem
                     $xmenutitle.Name = $d
                     $xmenutitle.Text = $d
                     $global:menuribbon.Items.add($xmenutitle) | Out-Null
                     
                     foreach ($split in $e.split(",")) {
                         if ($split -ne "-") {
                             $innersplit = $split.split("|")
                             $split = $innersplit[0]
                             $item = new-object System.Windows.Forms.ToolStripMenuItem
                             if ($innersplit[2]) {
                             $item.image = [System.Drawing.Image]::FromFile($innersplit[2])
                             }
                             if ($innersplit[1]) {
                                 $item.ShortCutKeys = $innersplit[1]
                                 $item.ShowShortCutKeys = $true
                             }
                             $item.name = $split
                             $item.text = $split
                             $item.Add_Click({
                                     &menuitemclick $this
                             })
                         } 
                         else {
                             $item = new-object System.Windows.Forms.ToolStripSeparator
                             $item.name = $split
                             $item.text = $split                 
                         }                       
                         $xmenutitle.DropDownItems.Add($item) | Out-Null     
                     }   
                     return $xmenutitle                  
                 }
                 toolstrip {
                     $toolbuttons = New-Object System.Windows.Forms.ToolStrip
                     foreach ($split in $d.split(",")) {
                         if ($split -ne "-") {
                             $item = new-object System.Windows.Forms.ToolStripButton
                             $isplit = $split.split("|")
                             $item.name = $isplit[0]
                             $item.image = [System.Drawing.Image]::FromFile($isplit[1])
                             $item.text = $isplit[2]
                             $item.Add_Click({&toolstripitemclick $this})
                         }
                         else {
                             $item = new-object System.Windows.Forms.ToolStripSeparator
                             $item.name = $split
                             $item.text = $split                 
                         }                       
                         $toolbuttons.Items.Add($item) | Out-Null                    
                     }
                         $b.Controls.Add($toolbuttons)
                          return $toolbuttons
                 }
             }
         }
         image { 
             $b.Image = [System.Drawing.Image]::FromFile($c)
         } 
 		backgroundimage { 
 		 	$b.backgroundimage = [System.Drawing.Image]::FromFile($c)
         }
         clear {
             $b.Text = ""
         }
         clearsel {
             $b.Items.RemoveAt($b.SelectedIndex)
         }
         close {
             $b.Close()
         }
         create {
             $Form = New-Object system.Windows.Forms.Form
             $Form.Text = $b
             $Form.Top = $c
             $Form.Left = $d
             $Form.Width = $e
             $Form.Height = $f
             return $Form
         }
         cursor {
             $b.Cursor = $c
         } #https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.cursors.appstarting?view=netframework-4.7.2
         enable {
             $b.enabled = $true
         }
         disable {
             $b.enabled = $false
         }
         focus {
             $b.focus()
         }
         hide {
             $b.visible = $false
         }
         name {
             $b.Name = $c
         }
         popup { 
                     $xpopup = New-Object System.Windows.Forms.ContextMenuStrip
                     
                     foreach ($split in $c.split(",")) {
                         if ($split -ne "-")
                         {   $item = new-object System.Windows.Forms.ToolStripMenuItem
                             $isplit = $split.split("|")
                             $item.name = $isplit[0] 
 							if ($isplit[1])
 							{
                             $item.image = [System.Drawing.Image]::FromFile($isplit[1])}
                             $item.text = $isplit[0]
                             $item.Add_Click({&menuitemclick $this})
                         }
                         else {
                             $item = new-object System.Windows.Forms.ToolStripSeparator
                             $item.name = $split
                             $item.text = $split                 
                         }                       
                         $xpopup.Items.Add($item) | Out-Null                 
                     }
                         $b.ContextMenuStrip = $xpopup
                         return $xpopup
                 }
         properties {
             return $b | Get-Member
         } #NEW COMMAND
         property {
             $b.$c = $d
         }
         remove {    
             $b.dispose()
         } 
         run {
              $global:apprunning = $true
              [System.Windows.Forms.Application]::Run($b) | Out-Null
              #Only useful when using vds.psm1 as a module to PowerShell in scenarios where the same form in a ps1 file must be called multiple times.
          }
          set {
              $b.Text = $c
          }
          setpos {
              $b.Top = $c
              $b.Left = $d
              $b.Width = $e
              $b.Height = $f
          }
          settip {
              $t = New-Object System.Windows.Forms.Tooltip
              $t.SetToolTip($b, $c)
          }
          show {
              if ($global:apprunning -eq $true) {
                  $b.Show() | Out-Null
              }
              else {
                  $global:apprunning = $true
                  [System.Windows.Forms.Application]::Run($b) | Out-Null
              }
          }
          showmodal {
              $b.ShowDialog() | Out-Null
          }
          snap {
              switch ($c)
              {
                  on {$b.MaximizeBox = $tue}
                  off {$b.MaximizeBox = $false}
              } # not working during runtime for switching back.
          }
          title {
              $b.Text = $c
          }  #partial implementation - requires form as $b param          
      }
      <#
      .SYNOPSIS
      Controls creation and manipulation of forms
      add (control) int:top int:left int:width int:height string:text
      statusstrip
      menustrip
      toolstrip
      image
      clear
      clearsel
      close
      create string:caption int:top int:left int:width int:height
      cursor (Arrow, Cross, Default, Hand, Help, HSplit, IBeam, No, NoMove2D, NoMoveHoriz, NoMoveVert, PanEast, PanNE, PanNorth, PanNW, PanSE, PanSouth, PanSW, PanWest, SizeAll, SizeNESW, SizeNS, SizeNWSE, SizeWE, UpArrow, VSplit, WaitCursor)
      enable
      disable
      focus
      hide
      name
      popup
      property
      remove
      set
      setpos
      settip
      show
      showmodal
      snap
      title
      
      
      .DESCRIPTION
      VDS
      $MyForm = dialog create MyForm 0 0 800 600
      $textbox1 = dialog add $MyForm $textbox 10 10 100 20
      $menu = dialog add $MyForm menustrip "&File" ('&New|Ctrl+N|'+$(curdir)+'\..\res\application.ico,&Open|Ctrl+O,&Save|Ctrl+S,Save &As,-,Page Set&up...,&Print|Ctrl+P,-,E&xit')
      $toolstrip1 = dialog add $form1 toolstrip "Buttonx1|c:\temp\verisign.bmp|Test,-,Buttonx2|c:\temp\verisign.bmps|Test"
      $statustrip = dialog add $MyForm statusstrip
      $button1 = dialog add $MyForm button 40 10 100 20 "Button1"
      dialog set $statusstrip "Status"
      dialog image button1 ($(curdir)+'\my.png')
      dialog clear $textbox1
      dialog clearsel $list1
      dialog close $MyForm
      dialog cursor $MyForm Arrow
      dialog enable $textbox1
      dialog disable $textbox1
      dialog focus $textbox1
      dialog hide $textbox1
      dialog name $textbox1 textbox1
      $popup = dialog popup $MyForm1 "Beans,Rice"
      dialog property $textbox1 text Text
      dialog remove $textbox1
      dialog setpos $textbox1 10 10 20 100
      dialog settip $textbox1 'Do not wait'
      dialog show $MyForm
      dialog showmodal $MyForm
      dialog snap $MyFrom
      dialog title $MyForm "New Caption"  
      
      .LINK
  https://dialogshell.com/vds/help/index.php/Dialog
      #>  
  }
function directory($a,$b,$c) {
    switch ($a) {
        change 
        {
            Set-Location $b
        }
        create 
        {
            New-Item -ItemType directory -Path $b
        }
        delete 
        {
            Remove-Item -path $b -recurse -force
        }
        rename 
        {
            Rename-Item -Path $b -NewName $c
        }
    }
<#
    .SYNOPSIS
    Performs directory operations: change, create, delete, rename
     
    .DESCRIPTION
     VDS
    directory change c:\
    
    .LINK
    https://dialogshell.com/vds/help/index.php/Directory
#>  
}

function eternium($a,$b,$c,$d,$e){ 
	switch($a){
		open {
			$global:ie = new-object -ComObject "InternetExplorer.Application"
			$global:ie.visible = $true
			$global:ie.navigate($b)
			while($global:ie.Busy) {
				Start-Sleep -Milliseconds 100
			}
		}
		get {
			try{ 
				$global:ie.document.getElementsByTagName('*') | % {
					if ($_.getAttributeNode($b).Value -eq $c) {
						 return $_ 
					}
				}
			}
			catch{
				$global:ie.document.IHTMLDocument3_getElementsByTagName('*') | % {
					if ($_.getAttributeNode($b).Value -eq $c) {
						 return $_ 
					}
				}
			}
		}
		set {
			try{
				$global:ie.document.getElementsByTagName('*') | % {
					if ($_.getAttributeNode($b).Value -eq $c) {
						$_.$d = $e
					}
				}
			}
			catch{
	            $global:ie.document.IHTMLDocument3_getElementsByTagName('*') | % {
					if ($_.getAttributeNode($b).Value -eq $c) {
						 $_.$d = $e
					}
                } 
			}
        }
		click {
			try{ 
				$global:ie.document.getElementsByTagName('*') | % {
					if ($_.getAttributeNode($b).Value -eq $c) {
						$_.click()
					}
				}
			}
			catch{
				$global:ie.document.IHTMLDocument3_getElementsByTagName('*') | % {
					if ($_.getAttributeNode($b).Value -eq $c) {
						 $_.click()
					}
				}
			}
		}
	}
<#
    .SYNOPSIS
    Automates Internet Explorer.
     
    .DESCRIPTION
     VDS
	eternium open 'http://google.com'
	$value = $(eternium get 'id' 'Text1').value
	eternium set 'class' 'Text1' 'value' 'new value'
	eternium click 'name' 'button1'
    
    .LINK
    https://dialogshell.com/vds/help/index.php/eternium
#>	
}
function exit ($a) {
exit $a
<#
    .SYNOPSIS
    Exits with a specific code
     
    .DESCRIPTION
     VDS
    exit 21
    
    .LINK
    https://dialogshell.com/vds/help/index.php/Exit
#>
} #partial implementation - does not work with gosubs, this is technically now the same as error
function exitwin($a) {
    switch ($a) {
        logoff {
        Invoke-RDUserLogoff -HostServer "localhost" -UnifiedSessionID 1
        } #This is probably wrong.
        shutdown {
        Stop-Computer}
        restart {
        Restart-Computer
        }
    }
<#
    .SYNOPSIS
    Logoff, shutdown or restart
     
    .DESCRIPTION
     VDS
    exitwin restart
    
    .LINK
    https://dialogshell.com/vds/help/index.php/Exitwin
#>
}
function file($a,$b,$c,$d) {
    switch ($a) {
        copy {
			if ((substr $b 0 4) -eq 'http'){
				$file = New-Object System.Net.WebClient
				$file.DownloadFile($b,$c)
			}
			else {
				copy-item -path $b -destination $c -recurse
			}
		}
        delete {
            Remove-Item -path $b -force
        }
        rename {
            Rename-Item -Path $b -NewName $c
        }
        setdate {
            $b = Get-Item $b; $b.LastWriteTime = New-object DateTime $c
        }
        setattr {
            switch ($c) {
                set {
                    $b =(Get-ChildItem $b -force)
                    $b.Attributes = $b.Attributes -bor ([System.IO.FileAttributes]$d).value__
                }
                unset {
                    $b =(Get-ChildItem $b -force)
                    $b.Attributes = $b.Attributes -bxor ([System.IO.FileAttributes]$d).value__
                }
            }
        }
        default {
            if (Test-Path -path $a) {
                return $true
            }
            else {
                return $false
            }
        }
    }
<#
    .SYNOPSIS
    copy, delete, rename, setdate or setattr
     
    .DESCRIPTION
     VDS
    file copy $file1 file2
    file delete $file1
    file rename $file1 $rename
    file setdate $(datetime)
    file setattr $file set Hidden
    
    .LINK
    https://dialogshell.com/vds/help/index.php/File
#>
}
 function font ($a, $b) {
    switch ($a) {
        add {
            $shellapp =  New-Object -ComoObject Shell.Application
            $Fonts =  $shellapp.NameSpace(0x14)
            $Fonts.CopyHere($b)
        }
        remove {
            $name = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' | Select-Object -ExpandProperty Property | Out-String
            #$name = $(out-string $(select-object $(get-item -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts') -expandproperty property))
            $keys = $name.Split([char][byte]10)
            foreach ($key in $keys) {
                $key = $key.Trim()
                if ($(substr $key 0 ($b.length)) -eq $b) {
                    $file = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $key | Select -ExpandProperty $key
                    $file = $file.trim() 
                    Remove-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $key 
                }
            }
        }
    }
 <#
    .SYNOPSIS
    Adds or removes a font
     
    .DESCRIPTION
     VDS
    font add $file
    font remove $font-name
    
    .LINK
    https://dialogshell.com/vds/help/index.php/Font
 #>
 }
 function htmlhelp ($a) {
    start-process -filepath hh.exe -argumentlist $a
 <#
    .SYNOPSIS
    Jumps to a specfied location in a compiled html file
     
    .DESCRIPTION
     VDS
    htmlhelp mk:@MSITStore:C:\Users\Brandon\Documents\textpad.chm::/Help/new.htm
    
    .LINK
    https://dialogshell.com/vds/help/index.php/htmlhelp
 #>
 }
 function info($a,$b) {
    [System.Windows.Forms.MessageBox]::Show($a,$b,'OK',64) | Out-Null
 <#
    .SYNOPSIS
    Displays a message and a title
     
    .DESCRIPTION
     VDS
    info "Message" "Title"
    
    .LINK
    https://dialogshell.com/vds/help/index.php/info
 #>
}
 function inifile ($a,$b,$c,$d) {
    switch ($a) { 
        open {
            $global:inifile = $b
        } 
        write {
            $Items = New-Object System.Collections.Generic.List[System.Object]
            $content = get-content $global:inifile
            if ($content) {
                $Items.AddRange($content)
            }
            if ($Items.indexof("[$b]") -eq -1) {
                $Items.add("")
                $Items.add("[$b]")
                $Items.add("$c=$d")
                $Items | Out-File $global:inifile
                }
            else {
                For ($i=$Items.indexof("[$b]")+1; $i -lt $Items.count; $i++) {
                if ($Items[$i].length -gt $c.length) {
                    if ($Items[$i].substring(0,$c.length) -eq $c -and ($tgate -ne $true)) {
                            $Items[$i] = "$c=$d"
                            $tgate = $true
                        }
                    }
                    if ($Items[$i].length -gt 0) {
                        if (($Items[$i].substring(0,1) -eq "[") -and ($tgate -ne $true)) {
                            $i--
                            $Items.insert(($i),"$c=$d")
                            $tgate = $true
                            $i++
                        }
                    }               
                }
                if ($Items.indexof("$c=$d") -eq -1) {
                    $Items.add("$c=$d")
                }
                $Items | Out-File $global:inifile -enc ascii
            }
        } 
    }
 <#
    .SYNOPSIS
    Open and write to ini files
     
    .DESCRIPTION
     VDS
    inifile open $(evn windir)+'\win.ini'
    inifile write probably "don't do this"
    
    .LINK
    https://dialogshell.com/vds/help/inifile
 #>
 }
 function killtask ($a) {
    stop-process -name $a
 <#
    .SYNOPSIS
    Ends a task
     
    .DESCRIPTION
     VDS
    killtask explorer.exe
    
    .LINK
    https://dialogshell.com/vds/help/index.php/killtask
 #>
 }
 function link ($a,$b,$c,$d,$e,$f,$g) {
    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut($a)
    $ShortCut.TargetPath=$b
    $ShortCut.Arguments=$e
    $ShortCut.WorkingDirectory = $c
    $ShortCut.WindowStyle = 1;
    $ShortCut.Hotkey = ""
    $ShortCut.IconLocation = $d
    $ShortCut.DESCRIPTION
     VDS = ""
    $ShortCut.Save()
 <#
    .SYNOPSIS
    Creates a shortcut
     
    .DESCRIPTION
     VDS
    link c:\vds\explorer.lnk c:\windows\explorer.exe c:\windows c:\windows\explorer.exe 
    
    .LINK
    https://dialogshell.com/vds/help/index.php/link
 #>
 }
 function list ($a,$b,$c,$d) {
    switch ($a) {
        add {
            $b.Items.Add($c) | Out-Null
        }
        append {
            $b.Items.AddRange($c.Split())
        }
        assign {
            $b.Items.AddRange($c.Items)
        }
        clear {
            $b.Items.Clear()
        }
        copy {
            Set-Clipboard $b.items
        } 
        delete {
            $b.Items.RemoveAt($b.SelectedIndex)
        }
        insert {
            $b.items.Insert($b.SelectedIndex,$c)
        }
        paste {     
                $clip = Get-Clipboard
                $b.Items.AddRange($clip.Split())
            }
        put {
                $sel = $b.selectedIndex
                $b.Items.RemoveAt($b.SelectedIndex)
                $b.items.Insert($sel,$c)
            }
        reverse {
            $rev = [array]$b.items
            [array]::Reverse($rev)
            $b.items.clear()
            $b.items.AddRange($rev)
        }
        seek {
            $b.selectedIndex = $c
        }
        sort {
            $b.sorted = $true
        }
        dropfiles {
            if ($c.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
                foreach ($filename in $c.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
                    list add $b $filename
                }
            }
        }#  list dropfiles $listbox1 $_
         # declare: $listbox1.AllowDrop = $true
         # Use $listbox1.add_DragEnter
        filelist {
            switch ($d) {
                dir {
                    $items = Get-ChildItem -Path $c
                    foreach ($item in $items) {
                        if ($item.Attributes -eq "Directory") {
                            list add $b $item
                        }
                    }
                }
                file {
                    $items = Get-ChildItem -Path $c
                    foreach ($item in $items) {
                        if ($item.Attributes -ne "Directory") {
                            list add $b $item
                        }
                    }
                }
            }
        }
        fontlist {  
            [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
            $r = (New-Object System.Drawing.Text.InstalledFontCollection).Families
            foreach ($s in $r){
                $b.items.AddRange($s.name)
            }
        }
        loadfile {
            $content = get-content $c
            $b.items.addrange($content)
        }
        loadtext {
            $b.items.addrange($c.Split([char][byte]10))
        }
        modules {
            $process = Get-Process $c -module
            foreach ($module in $process) {
                $b.items.Add($module) | Out-Null
            }
        }
        regkeys {
            $keys = Get-ChildItem -Path $c
            foreach ($key in $keys) {
                $b.items.add($key) | Out-Null
            }
        }
        
        regvals {
            #$name = Get-Item -Path $c | Select-Object -ExpandProperty Property | Out-String
            $name = $(out-string -inputobject $(select-object -inputobject $(get-item -path $c) -expandproperty property))
            $b.items.addrange($name.Split([char][byte]13))
        } 
        savefile {
        $b.items | Out-File  $c
        }
        tasklist {
            $proc = Get-Process | Select-Object -ExpandProperty ProcessName | Out-String
            $b.items.addrange($proc.Split([char][byte]13))
        }
        winlist {
            $win = Get-Process | Where-Object {$_.MainWindowTitle -ne ""} | Select-Object -ExpandProperty MainWindowTitle | Out-String
            $b.items.addrange($win.Split([char][byte]13))
        }
    }
 <#
    .SYNOPSIS
    Performs list operations.
    add
    append
    assign
    clear
    copy
    delete
    insert
    paste
    put
    reverse
    seek
    sort
    dropfiles
    filelist
        dir
        file
    fontlist
    loadfile
    loadtext
    modules
    regkeys
    regvals
    savefile
    tasklist
    winlist
     
    .DESCRIPTION
     VDS
    list add $list1 "item"
    list append $list1 $string
    list assign $list1 $list2
    list clear $list1
    list copy $list1
    list delete $list1
    list insert $list1 $item
    list paste $list1
    list put $list1 $item
    list reverse $list1
    list seek $list1 5
    list sort $list1
    list dropfiles $list1 $_
        (Inside of your script, you must $list1.AllowDrop = $true; the event is $list1.add_DragEnter)
    list filelist $list1 c:\ dir
    list filelist $list1 c:\ file
    list fontlist $combobox1
    list loadfile $list1 c:\windows\win.ini
    list loadtext $list1 $string
    list modules $list1 explorer.exe
    list regkeys $list1 hkcu:\software\dialogshell
    list regvals $list1 hkcu:\software\dialogshell
    list savefile $list1 c:\vds\test.txt
    list tasklist $list1
    list winlist $list1
    
    .LINK
    https://dialogshell.com/vds/help/index.php/list
 #>
 }
 function module ($a,$b,$c) {
	switch ($a){
		import {
			$Content = (get-content $b)
			$Content = resource asciidecode $Content
			return (string $Content)
		}
		export {
			$Content = (get-content $b)
			$exportstring = resource asciiencode $Content
			$exportstring | Out-File $c -enc ascii
		}
	}
 <#
    .SYNOPSIS
    Exports or imports  base64 encoded modules
     
    .DESCRIPTION
     VDS
	module export c:\vds\trunk\sum.psm1 c:\vds\trunk\sum.dll
	module import c:\vds\trunk\sum.dll | run
    
    .LINK
    https://dialogshell.com/vds/help/index.php/module
 #>
 }
function option ($a, $b, $c, $d) {
    switch ($a) {
        colordlg {
            switch ($b) {
                object {$global:colordlg = "object"}
                normal {$global:colordlg = "normal"}
            }
        }

        fieldsep {
            $global:fieldsep = $b
        }
    }
<#
    .SYNOPSIS
    Declares an application option, currently colordlg and fieldsep
     
    .DESCRIPTION
     VDS
    option colordlg object
    option fieldsep ":"
    
    .LINK
    https://dialogshell.com/vds/help/index.php/option
#>
}   
function parse ($a) {
    return $a.split($global:fieldsep)
<#
    .SYNOPSIS
    parses a string by fieldsep
     
    .DESCRIPTION
     VDS
    $parse = $(parse $string)
    info $parse[0]
    
    .LINK
    https://dialogshell.com/vds/help/index.php/parse
#>
}

 function pineapples {
    start https://dialogshell.com/vds/help/index.php/Talk:Pineapples
 <#
    .SYNOPSIS
    Open a page to discuss pineapples
     
    .DESCRIPTION
     VDS
     pineapples
    
    .LINK
    https://dialogshell.com/vds/help/index.php/pineapples
 #>
 }

function play ($a, $b) {
    $PlayWav=New-Object System.Media.SoundPlayer
    $PlayWav.SoundLocation=$a
    if ($b -eq "wait") {
        $PlayWav.playsync()
    }
    else {
        $PlayWav.play()
    }
<#
    .SYNOPSIS
    Plays a sound
     
    .DESCRIPTION
     VDS
    play my.wav wait
    play my.wav
    
    .LINK
    https://dialogshell.com/vds/help/index.php/play
#>
}

function presentation($a,$b,$c,$d,$e,$f,$g,$h,$i){
	switch ($a){
		create {

		$xaml = @"
			<Window
					xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
					xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
					Title="$b" Height="$g" Width="$f">
					<Grid Name="$c">
					</Grid>
			</Window>
"@
			$MainWindow = (presentation $xaml)
			return $MainWindow
		}
		add {
			$control = new-object System.Windows.Controls.$c
			$control.Content = "$h"
			$b.Children.Insert($b.Children.Count, $control)
			$control.VerticalAlignment = "Top"
			$control.HorizontalAlignment = "Left"
			$control.Margin = "$e,$d,0,0"
			$control.Height = "$g"
			$control.Width = "$f"
			return $control
		}
		insert {
		$control = new-object System.Windows.Controls.$c
		$b.Children.Insert($b.Children.Count, $control)
		return $control
		}
		findname {
		return $b.FindName($c)
		}
		valign { $b.VerticalAlignment = $c
		}
		align { $b.HorizontalAlignment = $c
		}
		content { $b.Content = $c}
		margin {$b.Margin = $c}
		height {$b.Height = $c}
		width {$b.Width = $c}
		navigationwindow {
		$Xaml = @"
			<NavigationWindow xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Name = "NavWindow" Width = "600" Height = "400" WindowStartupLocation = "CenterScreen" ResizeMode = "CanMinimize" ></NavigationWindow>
"@
$wind = presentation page $Xaml
if ($b)
{$wind.Content = (presentation page $b)}
return $wind
		}
		page {
			$b = $b -replace 'd:DesignHeight="\d*?"', '' -replace 'x:Class=".*?"', '' -replace 'mc:Ignorable="d"', '' -replace 'd:DesignWidth="\d*?"', '' 
			[xml]$b = $b
			$presentation = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $b))
			$b.SelectNodes("//*[@Name]") | %{
				Set-Variable -Name $_.Name.ToString() -Value $presentation.FindName($_.Name) -Scope global
			}
		return $presentation
		}
		window {
			$b = $b -replace "x:N", 'N' -replace 'd:DesignHeight="\d*?"', '' -replace 'x:Class=".*?"', '' -replace 'mc:Ignorable="d"', '' -replace 'd:DesignWidth="\d*?"', '' 
			[xml]$b = $b
			$presentation = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $b))
			$b.SelectNodes("//*[@Name]") | %{
				Set-Variable -Name $_.Name.ToString() -Value $presentation.FindName($_.Name) -Scope global
			}
		return $presentation
		}
		explicit {
		[xml]$a = $a
			$presentation = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $a))
			return $presentation
		}
		strict {
			[xml]$a = $a
			$presentation = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $a))
			$a.SelectNodes("//*[@Name]") | %{
				Set-Variable -Name $_.Name.ToString() -Value $presentation.FindName($_.Name) -Scope global
			}
		return $presentation
		}
		default {
			$a = $a -replace "x:N", 'N' -replace 'd:DesignHeight="\d*?"', '' -replace 'x:Class=".*?"', '' -replace 'mc:Ignorable="d"', '' -replace 'd:DesignWidth="\d*?"', '' 
			[xml]$a = $a
			$presentation = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $a))
			$a.SelectNodes("//*[@Name]") | %{
				Set-Variable -Name $_.Name.ToString() -Value $presentation.FindName($_.Name) -Scope global
			}
		return $presentation
		}
	}
<#
    .SYNOPSIS
    Creates a Windows Foundation Presentation window or page form and elements within.
     
    .DESCRIPTION
     VDS
	 $presentation 	= presentation create "Admin Calculator" calc 0 0 148 229
		#dynamically create window on the fly, like a winform
	 $ButtonCE = presentation add $calc Button 30 5 30 30 "CE"  
	 
	 $ButtonCE = presentation insert $calc Button
		#insert into existing grid
		
	$calc = presentation findname $presentation calc
		#return the presentation object with the name specfied from the presentation object specfied
	 
	 presentation valign $button1 "Top"
	 presentation align $button1 "center"
	 
	 presentation content $page2
		#where page2 is a wpf page
	
	presentation margin $button1 10
	presentation height $button1 40
	presentation width $button1 120
	
	presentation navigationwindow $page2
		#where page2 is a presentation page
		#parses names and filters XAML.
	
	$pres = presentation page $page2
	
	$presentation = presentation window $page1
		#parses names and filters XAML.
	
	$presentation = presentation explicit $page1
		#Doesn't parse names, and XAML must be powershell ready.
		
	$presentation = presentation strict $page1
		#Parses names, but assumes XAML is powershell ready.
	
	$presentation = presentation $page1
		#see presentation window.
	    
    .LINK
    https://dialogshell.com/vds/help/index.php/Presentation
#>
}

function property ($a,$b,$c) {
    if ($c) {
        $a.$b = $c
    }
    else {
    return $a.$b
    }
<#
    .SYNOPSIS
    Sets a property
     
    .DESCRIPTION
     VDS
    property $text text "text"
    
    .LINK
    https://dialogshell.com/vds/help/index.php/property
#>
}
function random($a,$b) {
    if ($b) {
        return Get-Random -Minimum $a -Maximum $b
    }
    else {
        get-random -SetSeed $a
    }
<#
    .SYNOPSIS
    Generates a random number, or sets the random seed.
     
    .DESCRIPTION
     VDS
    random 123456 #seed
    $roll = $(random 1 100) #random number
    
    .LINK
    https://dialogshell.com/vds/help/index.php/random
#>
}
function registry ($a, $b, $c, $d, $e) {
    switch ($a) {
        copykey {
            Copy-Item -Path $b -Destination $c
        }
        deletekey {
            Remove-Item -Path $b -Recurse
        }
        movekey {
            Copy-Item -Path $b -Destination $c
            Remove-Item -Path $b -Recurse
        }
        renamekey {
            Rename-Item -Path $b -NewName $c
        }
		newkey {
            New-Item -Path $b -Name $c
        }
        newitem {
            New-ItemProperty -Path $b -Name $c -PropertyType $d -Value $e
        }
        modifyitem {
            Set-ItemProperty -Path $b -Name $c -Value $d
        }
        renameitem {    
            Rename-ItemProperty -Path $b -Name $c -NewName $d
        }
        deleteitem {    
            Remove-ItemProperty -Path $b -Name $c
        }
    }
<#
    .SYNOPSIS
    Performs registry operations
    copykey
    deletekey
    movekey
    renamekey
    newitem
    modifyitem
    renameitem
    deleteitem
     
    .DESCRIPTION
     VDS
    registry copykey hkcu:\software\dialogshell hklm:\software\dialogshell
    registry deletekey hkcu:\software\dialogshell
    registry movekey hkcu:\software\dialogshell hklm:\software\dialogshell
    registry renamekey hkcu:\software\dialogshell visualdialogshell
    registry newitem 
    
    .LINK
    https://dialogshell.com/vds/help/index.php/registry
#>
}
function resource ($a,$b,$c) {
	switch ($a)
	{
		load {
			return [Byte[]](resource decode (get-content $b))
		}
		import{
			$import = [System.IO.File]::ReadAllBytes($b)
			return [System.Convert]::ToBase64String($import)
		}
		export{
			$export = [System.Convert]::FromBase64String($b)
			[System.IO.File]::WriteAllBytes($c,$export)
		}
		asciiencode{
			$enc = [system.Text.Encoding]::ASCII
			return [System.Convert]::ToBase64String($enc.GetBytes($b))
		}
		asciidecode{
			$decode = [System.Convert]::FromBase64String($b)
			return [System.Text.Encoding]::ASCII.GetString($decode)
		}
		decode {
		return [System.Convert]::FromBase64String($b)
		#although this works, it returns a system object, which is not usable. We need raw. Not sure how to fix.
		}
	}
<#
    .SYNOPSIS
    Comment
     
    .DESCRIPTION
     VDS
    
	$resource = resource load .\resource.res
		#imports and decodes a base64 encoded file
	
	$resource = resource import .\resource.ico
		#import a resource directly from file, imports to base64
	
	resource export $resource .\resource.res
		#Exports a resource to a base64 encoded file
		
	$encode = resource asciiencode "this string"
	
	$decode = resource asciidecode "dGhpcyBzdHJpbmc="
	
	$decode = resource decode $resrouce #not working yet I think
	
    .LINK
    https://dialogshell.com/vds/help/index.php/resource
#>
}
function rem {
<#
    .SYNOPSIS
    Comment
     
    .DESCRIPTION
     VDS
    rem This will not be executed.  
    
    .LINK
    https://dialogshell.com/vds/help/index.php/rem
#>
} #This is done.

function selenium ($a,$b,$c,$d) {
	switch ($a){
		reference {
			$env:PATH += ";$b"
			Add-Type -Path ($b + 'WebDriver.dll')
			$ChromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
			$ChromeOptions.AddAdditionalCapability("useAutomationExtension", $false)
			$global:selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver($ChromeOptions)
		}
		open {
			$global:selenium.Navigate().GoToURL($b) 
		}
		get {
			return $global:selenium.FindElementByXPath("//*[contains(@$b, '$c')]")
		}
		set {
			$global:selenium.FindElementByXPath("//*[contains(@$b, '$c')]").SendKeys($d)
		}
		click {
			$global:selenium.FindElementByXPath("//*[contains(@$b, '$c')]").Click()
		}
		stop {
			$global:selenium.Close()
			$global:selenium.Quit()
			Get-Process -Name chromedriver -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue
		}
	}
<#
    .SYNOPSIS
    Requires webdriver.dll and chromedriver.exe for qa of google chrome
     
    .DESCRIPTION
     VDS
	selenium reference 'c:\temp\psl\'
	selenium open 'http://google.com'
	$value = $(selenium get 'id' 'Text1')
	selenium set 'id' 'Text1' 'new value'
	selenium click 'id' 'button1'
	selenium stop
    
    .LINK
    https://dialogshell.com/vds/help/index.php/selenium
#>
}

function server ($a,$b,$c){
	switch ($a) {
		start {
			$vdsServer = New-Object Net.HttpListener
			$server = $b + ':' + $c + '/'
			$vdsServer.Prefixes.Add($server)
			$vdsServer.Start()
			return $vdsServer
		}
		watch {
			$event = $b.GetContext()
			return $event
		}
		context {
			return $b.Request.Url.LocalPath
		}
		return {
			$buffer = [System.Text.Encoding]::ASCII.GetBytes($c)
			$b.Response.ContentLength64 = (len $buffer)
			$b.Response.OutputStream.Write($buffer, 0, (len $buffer))
			$b.Response.Close()
		}
		stop {
			$b.Stop()
		}
	}
<#
    .SYNOPSIS
    Controls web server transactions
     
    .DESCRIPTION
     VDS
	$vdsServer = server start http://localhost:2323
	$event = (server watch $vdsServer)
	if(equal (server context $event) "/")
	server return $event $return
	server stop $vdsServer
    
    .LINK
    https://dialogshell.com/vds/help/index.php/server
#>
}
function stop {
    Exit-PSSession
<#
    .SYNOPSIS
    Exits the script and ends the program.
     
    .DESCRIPTION
     VDS
    stop
    
    .LINK
    https://dialogshell.com/vds/help/index.php/stop
#>
}
function taskbar ($a) {
    $hWnd = [vds]::FindWindowByClass("Shell_TrayWnd")
    switch ($a) {
        show {
            [vds]::ShowWindow($hWnd, "SW_SHOW_DEFAULT")
        }
        hide {
            [vds]::ShowWindow($hWnd, "SW_HIDE")
        }
    }
<#
    .SYNOPSIS
    Shows or hides the taskbar
     
    .DESCRIPTION
     VDS
    taskbar show
    taskbar hide
    
    .LINK
    https://dialogshell.com/vds/help/index.php/taskbar
#>
}
function shell($a,$b) {
        $shell = new-object -com shell.application
        $f = $shell.NameSpace($(path $b))
        $file = $f.ParseName(($(name $b))+'.'+($(ext $b)))
        $file.Verbs() | %{if($_.Name -eq $a) { $_.DoIt() }}
<#
    .SYNOPSIS
    Peforms a shell operation on a file
     
    .DESCRIPTION
     VDS
    shell "&Print" c:\windows\win.ini
    
    .LINK
    https://dialogshell.com/vds/help/index.php/shell
#>
}
function timer($a) {
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = $a
    $timer.Enabled = $true
    return $timer
<#
    .SYNOPSIS
    Creates a timer which has a tick event at a specified interval.
     
    .DESCRIPTION
     VDS
    $timer = timer 1000
    $timer.add_Tick({})
    
    .LINK
    https://dialogshell.com/vds/help/index.php/timer
#>
}
function title ($a,$b) {
    $a.text = $b
<#
    .SYNOPSIS
    Sets the title of a dialog window
     
    .DESCRIPTION
     VDS
    title $MyForm "New Title"
    
    .LINK
    https://dialogshell.com/vds/help/index.php/title
#>
}
function trace ($a) {
    switch ($a) {
            on {
                Set-PSDebug -Trace 1
            }
            off {
                Set-PSDebug -Trace 0
            }
        }
<#
    .SYNOPSIS
    Debugs output to the console window, valid switches are on and off.
     
    .DESCRIPTION
     VDS
    trace on
    
    .LINK
    https://dialogshell.com/vds/help/index.php/trace
#>
}
function wait ($a) {
    if ($a -eq $null) {
        $a = 1
    }
    start-sleep -s $a | Out-Null
<#
    .SYNOPSIS
    Pauses script execution in seconds, which may be fractional.
     
    .DESCRIPTION
     VDS
    wait .1 # 1/10th of 1 second
    
    .LINK
    https://dialogshell.com/vds/help/index.php/wait
#>
}
function warn ($a,$b) {
    [System.Windows.Forms.MessageBox]::Show($a,$b,'OK',48)
<#
    .SYNOPSIS
    Displays a warning message with title to the end user
     
    .DESCRIPTION
     VDS
    warn "Cannot complete action err $err" "Processing error..." 
    
    .LINK
    https://dialogshell.com/vds/help/index.php/warn
#>
}
function window ($a,$b,$c,$d,$e,$f) {
    switch ($a) {
        activate {
            [vds]::SetForegroundWindow($b)
        }
        click {
            window activate $b
            $x = $c + ($(winpos $b L))
            $y = $d + ($(winpos $b T))
            [vds]::LeftClickAtPoint($x,$y)
        }
        close {
            $(sendmsg $b 0x0112 0xF060 0)
        }
        flash {
            [Window]::FlashWindow($b,150,10)
        }
        fuse {
            [vds]::SetParent($b,$c)
        } 
        hide {
            [vds]::ShowWindow($b, "SW_HIDE")
        }
        iconize {
            [vds]::ShowWindow($b, "SW_MINIMIZE")
        }
        maximize {
            [vds]::ShowWindow($b, "SW_MAXIMIZE")
        }
        position {
        [vds]::MoveWindow($b,$c,$d,$e,$f,$true)
        }       
        rclick {
            window activate $b
            $x = $c + ($(winpos $b L))
            $y = $d + ($(winpos $b T))
            [vds]::RightClickAtPoint($x,$y)
        }       
        normal {
            [vds]::ShowWindow($b, "SW_SHOW_NORMAL")
        }
        ontop {
            [vds]::SetWindowPos($b, -1, $(winpos $b T), $(winpos $b L), $(winpos $b W), $(winpos $b H), 0x0040)
        }
        send {
            window activate $b
            $wshell = New-Object -ComObject wscript.shell
            $wshell.SendKeys($c)
        }
        settext {
            [vds]::SetWindowText($b,$c)
        }
    }
<#
    .SYNOPSIS
    Performs operations on displayed windows per parameter
    activate
    click
    close
    flash
    fuse
    hide
    iconize
    maximize
    position
    rclick
    normal
    ontop
    send
    settext
     
    .DESCRIPTION
     VDS
    window activate $(winexists notepad)
    window click $(winexists notepad) 15 15
    window close $(winxists notepad)
    window flash $(winexists notepad)
    window fuse $(winexists notepad) $(winexists $MyForm)
    window hide $(winexists notepad)
    window iconize $(winexists notepad)
    window maximize $(winexists notepad)
    window position $(winexists notepad) 15 15 200 200
    window rclick $(winexists notepad) 15 15
    window normal $(winexists notepad)
    window ontop $(winexists notepad)
    window send $(winexists notepad) "Notepad window"
    
    .LINK
    https://dialogshell.com/vds/help/index.php/window
#>
}
#=============================functions===================================================
function abs($a) {
<#
    .SYNOPSIS
     Returns the abslute value of a number.
     
    .DESCRIPTION
     VDS
    $number = -5
    if ($(abs $number) -gt 4)
    {console "It's greater than 4"}

    .LINK
    https://dialogshell.com/vds/help/index.php/abs
#>
    return [math]::abs($a)
}
function asc($a) {
<#
    .SYNOPSIS
     Returns the ascii code number related to character $a.

    .DESCRIPTION
     VDS
     $(asc 'm')

    .LINK
    https://dialogshell.com/vds/help/index.php/asc
#>
    return [byte][char]$a
}
function ask($a,$b) {
    $ask = [System.Windows.Forms.MessageBox]::Show($a,$b,'YesNo','Info')
    return $ask
<#
    .SYNOPSIS
     Opens a dialog window to ask the user a question.
     
    .DESCRIPTION
     VDS
    if ($(ask "Is this the question?" "This is the title") -eq "Yes")
    {info "This is the question"}
    else
    {info "This is not the question"}
    .LINK
    https://dialogshell.com/vds/help/index.php/ask
#>
}
function alt($a) {
    return "%$a"
<#
    .SYNOPSIS
     Sends the ALT key plus string. Only useful with 'window send'.
     
    .DESCRIPTION
     VDS
    window send $(winexists notepad) $(alt "F")
    .LINK
    https://dialogshell.com/vds/help/index.php/alt
#>
}
function both($a, $b) {
    if (($a) -and ($b)) {
        return $true 
    } 
    else {
        return $false
    }
<#
    .SYNOPSIS
     Checks if both values are $true
     
    .DESCRIPTION
     VDS
    if ($(both 1 2)){console "Both 1 and 2 exists"}
    .LINK
    https://dialogshell.com/vds/help/index.php/both
#>
}
function chr ($a) {
    $a = $a | Out-String
    return [char][byte]$a
<#
    .SYNOPSIS
     Returns the ascii code to character
     
    .DESCRIPTION
     VDS
    $(chr 34)
    .LINK
    https://dialogshell.com/vds/help/index.php/chr
#>
}
function clipbrd {
    return Get-Clipboard -Format Text
<#
    .SYNOPSIS
     Returns the text in the clipboard
     
    .DESCRIPTION
     VDS
    window send $(winexists notepad) $(clipbrd)
    .LINK
    https://dialogshell.com/vds/help/index.php/clipbrd
#>
}
function colordlg {
    $colorDialog = new-object System.Windows.Forms.ColorDialog
    $colorDialog.ShowDialog() | Out-Null
    if (($global:colordlg -eq $null) -or ($global:colordlg -eq "object")) {
        return $colorDialog
    }
    else {
            return $colorDialog.color.name
    }
<#
    .SYNOPSIS
     Produces a color selection dialog. 
     If 'option colordlg normal' has been set, this will return the friendly color name, otherwise it returns the entire colorDialog object.
     If 'option colordlg normal' is set, it may be unset using 'option colordlg object'.
         
    .DESCRIPTION
     VDS
     $color = $(colordlg); console $color.color.R; console $color.color.G; console $color.color.B

    .LINK
    https://dialogshell.com/vds/help/index.php/colordlg
#>
}
function count ($a) {
    return $a.items.count
<#
    .SYNOPSIS
     Returns the count of items in an object, usually a listbox. 

    .DESCRIPTION
     VDS
     $c = $(count $listbox1)

    .LINK
    https://dialogshell.com/vds/help/index.php/count
#>
}
function cr {
    return chr(13)
<#
    .SYNOPSIS
     A carriage return, this is usually followed by a line feed. 

    .DESCRIPTION
     VDS
     info "Return a new line $(cr) here."

    .LINK
    https://dialogshell.com/vds/help/index.php/cr
#>
}
function ctrl($a) {
    return "^$a"
<#
    .SYNOPSIS
     Sends the CTRL key plus string. Only useful with 'window send'.
     
    .DESCRIPTION
     VDS
    window send $(winexists notepad) $(ctrl "s")
    
    .LINK
    https://dialogshell.com/vds/help/index.php/ctrl
#>
}
 function curdir {
    return $(trim (Get-Location | Select-Object -expandproperty Path | Out-String))
<#
    .SYNOPSIS
     Returns the current directory as string
     
    .DESCRIPTION
     VDS
    $c = $(curdir)
    directory change c:\windows
    rem do some stuff
    directory change $c
    
    .LINK
    https://dialogshell.com/vds/help/index.php/curdir
#>
}
function datetime {
    return Get-Date
<#
    .SYNOPSIS
     Returns the current date and time.
     
    .DESCRIPTION
     VDS
     $(datetime)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/datetime
#>
} 
function div ($a,$b) {
    return $a / $b
    <#
    .SYNOPSIS
    Returns the quotient of a dividend and a divisor.
     
    .DESCRIPTION
     VDS
     $(div 4 2)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/div
#>
}
function differ ($a,$b) {
    return $a - $b
<#
    .SYNOPSIS
    Returns the subtractrion result.
     
    .DESCRIPTION
     VDS
     $(differ 4 2)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/differ
#>
}
function dirdlg($a,$b,$c) {
$dirdlg = New-Object System.Windows.Forms.FolderBrowserDialog
$dirdlg.description = $a
$dirdlg.rootfolder = $b
    if($dirdlg.ShowDialog() -eq "OK")   {
        $folder += $dirdlg.SelectedPath
    }
        return $folder
<#
    .SYNOPSIS
    Allows use of dialog to browse for folder and returns the result as string. 
    The first paramater is the text to display "Select main folder", the second paramater is the start folder.
    Permitted start folder locations are as follows: Desktop, Programs, MyDocuments, Personal, Favorites, Startup, Recent, SendTo, StartMenu, MyMusic, MyVideos, DesktopDirectory, MyComputer, NetworkShortcuts, Fonts, Templates, CommonStartMenu, 
    CommonPrograms, CommonStartup, CommonDesktopDirectory, ApplicationData, PrinterShortcuts, LocalApplicationData, InternetCache, Cookies, History, CommonApplicationData, Windows, System, ProgramFiles, MyPictures, UserProfile, SystemX86, 
    ProgramFilesX86, CommonProgramFiles, CommonProgramFilesX86, CommonTemplates, CommonDocuments, CommonAdminTools, AdminTools, CommonMusic, CommonPictures, CommonVideos, Resources, LocalizedResources, CommonOemLinks, CDBurning
    
    .DESCRIPTION
     VDS
     $mainfolder = $(dirdlg "Select Main Folder" "CDBurning")
     
    .LINK
    https://dialogshell.com/vds/help/index.php/dirdlg
#>
} #partial implementation - root folder constrained to certain values by powershell. 
function dlgname($a) {
    return $a.name
<#
    .SYNOPSIS
    Returns the name property of a dialog element
     
    .DESCRIPTION
     VDS
     $(name $textbox1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/dlgname
#>
}
function dlgpos ($a,$b) {
    switch ($b) {
        T {
            return $a.Top
        }
        L {
            return $a.Left
        }
        W {
            return $a.Width
        }
        'H' {
            return $a.Height
        }
    }
<#
    .SYNOPSIS
    Returns the an element of a dialog position, T for top, L for left, W for width or H for height.
     
    .DESCRIPTION
     VDS
     $(dlgpos $textbox1 T)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/dlgpos
#>  
} #partial implementation
function dlgprops ($a,$b,$c) {
    if ($b -eq $null) {
        return $a | Get-Member | Out-String
    }
    else {
        return ($a | select -ExpandProperty $b | Out-String).Trim()
    }
<#
    .SYNOPSIS
    Returns properties (1) or property (2 params) of a dialog element.
     
    .DESCRIPTION
     VDS
    console $(dlgprops $textbox1)
    $textbox1text = $(dlgprops $textbox1 text)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/dlgprops
#>
}
function dlgtext($a) {  
    return $a.Text
<#
    .SYNOPSIS
    Returns the text of a dialog element.
     
    .DESCRIPTION
     VDS
     $(dlgtext $textbox1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/dlgtext
#>
}
function env($a) {
    $loc = Get-Location | select -ExpandProperty Path
    Set-Location Env:
    $return = Get-ChildItem Env:$a | select -ExpandProperty Value
    Set-Location $loc;return $return
<#
    .SYNOPSIS
    Returns an environmental variable.
     
    .DESCRIPTION
     VDS
     $windir = $(env windir)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/env
#>
}
function equal($a, $b) {
    if ($a -eq $b) {
        return $true 
    } 
    else {
        return $false
    }
<#
    .SYNOPSIS
    Returns if two values are equal.
     
    .DESCRIPTION
     VDS
     if ($(equal 4 2))
     {console "Hey, four and two really are equal!"}
     
    .LINK
    https://dialogshell.com/vds/help/index.php/equal
#>
}
function error {
    return $LASTEXITCODE
<#
    .SYNOPSIS
    Returns the last error exit code.
     
    .DESCRIPTION
     VDS
     console $(error)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/error
#>
}
function esc {
    return $(chr 27)
<#
    .SYNOPSIS
    Returns the escape key, useful with window send.
     
    .DESCRIPTION
     VDS
     window send $(winexists "Save as...") $(esc)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/esc
#>
} 
function event {
    return (Get-PSCallStack)[1].Command
<#
    .SYNOPSIS
    Returns the last command called. This probably needs reworked, use sparsly.
     
    .DESCRIPTION
     VDS
     $event = $(event)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/event
#>
}
function expandproperty($a,$b){
return $(select-object -inputobject $a -expandproperty $b)
<#
    .SYNOPSIS
    Expands the property [property] of inputobject [inputobject]
     
    .DESCRIPTION
     VDS
     $major = $(expandproperty [System.Environment]::OSVersion.Version major)
     #major being the property.
     
    .LINK
    https://dialogshell.com/vds/help/index.php/expandproperty
#>
}
function ext($a) {
    $split = $a.Split('.')
    return $split[$split.count -1]
<#
    .SYNOPSIS
    returns the three character extension of a file name.
     
    .DESCRIPTION
     VDS
    $file = $(filedlg "Files|*.*")
    $ext = $(ext $file)
    info $ext
     
    .LINK
    https://dialogshell.com/vds/help/index.php/ext
#>
}
function fabs($a) {
    return [math]::abs($a)
<#
    .SYNOPSIS
    Returns the absolute value of a number.
     
    .DESCRIPTION
     VDS
    info $(fabs -10)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fabs
#>
}
function fadd($a,$b) {
    return $a + $b
<#
    .SYNOPSIS
    Returns the sum of two values.
     
    .DESCRIPTION
     VDS
    info $(fadd 2 2)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fadd
#>
}
function fatn($a,$b) {
    return [math]::atn($a / $b)
<#
    .SYNOPSIS
    Returns the arctangent of y over x.
     
    .DESCRIPTION
     VDS
    info $(fatn $y $x)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fatn
#>
}
function fcos {
    Param ($a);
    return [math]::cos($a)
<#
    .SYNOPSIS
    Returns cosine.
     
    .DESCRIPTION
     VDS
    info $(cos $a)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fcos
#>
}
function fdiv ($a,$b) {
    return $a / $b
<#
    .SYNOPSIS
    Returns the quotient of a division problem.
     
    .DESCRIPTION
     VDS
    info $(fdiv $a $b)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fdiv
#>
}
function fexp($a) {
    return [math]::exp($a)
<#
    .SYNOPSIS
    Returns exponent.
     
    .DESCRIPTION
     VDS
    info $(exp $a)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fexp
#>
}
function fieldsep {
    return $fieldsep
<#
    .SYNOPSIS
    Returns the fieldsep specified by option fieldsep
     
    .DESCRIPTION
     VDS
    info $a.split($(fieldsep))[0]
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fieldsep
#>
}
function filedlg($a,$b,$c) {
    if ($c -ne "save") {
        $filedlg = New-Object System.Windows.Forms.OpenFileDialog
        $filedlg.initialDirectory = $b
        $filedlg.filter = $a
        $filedlg.ShowDialog() | Out-Null
        return $filedlg.FileName
    }
    else {
        $filedlg = New-Object System.Windows.Forms.SaveFileDialog
        $filedlg.initialDirectory = $b
        $filedlg.filter = $a
        $filedlg.ShowDialog() | Out-Null
        return $filedlg.FileName
    }
<#
    .SYNOPSIS
    Returns the results of a file selection dialog. An optional 'save' parameter is available to generate a file save dialog.
     
    .DESCRIPTION
     VDS
    $file = $(filedlg 'Text Files|*.txt' $(windir)) 
     
    .LINK
    https://dialogshell.com/vds/help/index.php/filedlg
#>
}#partial implementation - excluded multi. Needs fixed.
function fint ($a) {
    return [int]$a
<#
    .SYNOPSIS
    Returns the value as integer.
     
    .DESCRIPTION
     VDS
    $(fint 19)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fint
#>
}
function fln ($a){
    return [math]::log($a)
<#
    .SYNOPSIS
    Returns logarithm
     
    .DESCRIPTION
     VDS
    $a = $(fln 64)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fln
#>
}
function fmul($a,$b) {
    return $a * $b
    <#
    .SYNOPSIS
    Returns the product of a multiplication problem.
     
    .DESCRIPTION
     VDS
    $a = $(fmul 4 4)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fmul
#>
}
function focus($a) {
    return $a.ActiveControl
<#
    .SYNOPSIS
    Returns the active control of the parameter
     
    .DESCRIPTION
     VDS
    $a = $(focus $MyForm)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/focus
#>
} #partial implementation - in this version, must specify the form as a parameter
function fontdlg($a,$b) {
    $fontdlg = new-object windows.forms.fontdialog
    $fontdlg.showcolor = $true
    $fontdlg.ShowDialog()
    return $fontdlg
<#
    .SYNOPSIS
    Returns a font dialog, the properties of which must be parsed.
     
    .DESCRIPTION
     VDS
    $fontdlg = $(fontdlg)
    $RichEdit.SelectionFont = $fontdlg.font
    
    .LINK
    https://dialogshell.com/vds/help/index.php/fontdlg
#>
} #partial implementation - does not preset font upon displaying the dialog.
function format($a,$b) {
    return $a | % {
        $_.ToString($b)
    }
<#
    .SYNOPSIS
    Formats a string according to specified paramater
     
    .DESCRIPTION
     VDS
    console $(format 8888888888 '###-###-####')
    
    .LINK
    https://dialogshell.com/vds/help/index.php/format
#>
} 
function frac($a) {
    $a = $a | Out-String 
    return  $a.split(".")[1]/1
<#
    .SYNOPSIS
    Returns the fractional portion of a number as integer.
     
    .DESCRIPTION
     VDS
    info $(frac 3.14)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/frac
#>
} 
function fsep($a) {
    return $fieldsep
<#
    .SYNOPSIS
    Returns the fieldsep specified by option fieldsep
     
    .DESCRIPTION
     VDS
    info $a.split($(fsep))[0]
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fsep
#>
} 
function fsin ($a){
    return [math]::sin($a)
<#
    .SYNOPSIS
    Returns the math sine of a number
     
    .DESCRIPTION
     VDS
    console $(fsin 1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fsin
#>
}
function fsqt ($a){
    return [math]::sqt($a)
<#
    .SYNOPSIS
    Returns the square root of a number
     
    .DESCRIPTION
     VDS
    console $(fsqt 4)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fsqt
#>
}
function fsub ($a,$b) {
    return $a - $b
<#
    .SYNOPSIS
    Returns the difference of two numbers
     
    .DESCRIPTION
     VDS
    console $(fsub 2 2)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/fsub
#>
}
function greater($a, $b) {
    if (($a) -gt ($b)) 
    {
        return $true
    } 
    else {
        return $false
    }
<#
    .SYNOPSIS
    Returns true if one value is greater than another.
     
    .DESCRIPTION
     VDS
    console $(greater 4 2)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/greater
#>
}
function gridview($a) { 
return $a | Out-Gridview
<#
    .SYNOPSIS
    Outputs result to a gridview dialog. Only valid on systems with Powershell ISE installed.
     
    .DESCRIPTION
     VDS
    gridview $(ls)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/gridview
#>
}
function hex($a){
    return $a | format-hex
<#
    .SYNOPSIS
    Returns hex
     
    .DESCRIPTION
     VDS
    console $(hex 15)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/hex
#>
}
function flog ($a) {
    return [math]::log($a)
<#
    .SYNOPSIS
    Returns log
     
    .DESCRIPTION
     VDS
    console $(log 15)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/flog
#>
}
function index($a) {
    return $a.SelectedIndex
<#
    .SYNOPSIS
    Returns the selected index of a control
     
    .DESCRIPTION
     VDS
    $index = $(index $listbox1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/index
#>
}
function iniread($a,$b) {
    $Items = New-Object System.Collections.Generic.List[System.Object]
    $content = get-content $global:inifile
    if ($content) {
        $Items.AddRange($content)
    }
    if ($Items.indexof("[$a]") -eq -1) {
        $return = ""
    }
    else {
        $return = ""
        For ($i=$Items.indexof("[$a]")+1; $i -lt $Items.count; $i++) {
            if ($Items[$i].length -gt $b.length) {
                if ($Items[$i].substring(0,$b.length) -eq $b -and $gate -ne $true) {
                        $return = $Items[$i].split("=")[1]
                        $gate = $true
                }
            }
            if ($Items[$i].length -gt 0) {
                if (($Items[$i].substring(0,1) -eq "[") -and ($tgate -ne $true)) {
                    $gate = $true
                }
            }
        }
    }
    return $return
<#
    .SYNOPSIS
    Returns a read from a file specified by inifile open.
     
    .DESCRIPTION
     VDS
    console $(iniread content value)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/iniread
#>  
}
function input($a,$b) {
    $input = [Microsoft.VisualBasic.Interaction]::InputBox($a,$b)
    return $input
<#
    .SYNOPSIS
    Produces a input dialog and returns the value.
     
    .DESCRIPTION
     VDS
    $input = $(input "Verify Address" "Verify Details")
     
    .LINK
    https://dialogshell.com/vds/help/index.php/input
#>  
} #partial implementation - Missing optional password parameter
function item($a) {
    return $a.SelectedItems
<#
    .SYNOPSIS
    Returns the selected item from a list
     
    .DESCRIPTION
     VDS
    $item = $(item $listbox1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/item
#>  
}
function items($a) {
    return $a.SelectedItems
<#
    .SYNOPSIS
    Returns the selected items from a list
     
    .DESCRIPTION
     VDS
    $items = $(items $listbox1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/items
#>
} #untested
function key($a) {
    return $(chr $(asc "{"))+$a+$(chr $(asc "}"))
<#
    .SYNOPSIS
    Useful with window send, works with special keys. Esc, Enter, Up, Down etc.
     
    .DESCRIPTION
     VDS
    window send $(winexists notepad) $(key up)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/key
#>
} 
function len($a) {
    return $a.length
<#
    .SYNOPSIS
    Returns the length of a string
     
    .DESCRIPTION
     VDS
    $length = $(len $textbox1.text)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/len
#>
}
function lf {
    return chr(10)
<#
    .SYNOPSIS
    Returns a line feed
     
    .DESCRIPTION
     VDS
    $lf = $(lf)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/lf
#>
}
function like ($a,$b) {
    return $a -like $b
<#
    .SYNOPSIS
    Returns the one item is like another
     
    .DESCRIPTION
     VDS
    $like = $(string $(like 'string' 'string'))
     
    .LINK
    https://dialogshell.com/vds/help/index.php/like
#>
}
function lower($a) {
    return $a.ToLower()
<#
    .SYNOPSIS
    Returns the lower case string of a string
     
    .DESCRIPTION
     VDS
    $lower = $(lower $string)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/lower
#>
}
function match($a,$b,$c) {
    if ($c = $null){
        $c = -1
    }
    else {
        $c = $c
    }
    try{$return = $a.FindString($b,$c)}
	catch{$return = $a.Items.IndexOf($b)}
	    return $return
<#
    .SYNOPSIS
    The index of the next match in a list, with an optional start point.
     
    .DESCRIPTION
     VDS
    $match = $(match $listbox1 $string 3)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/match
#>
}
function mod($a,$b) {
    return $a % $b
<#
    .SYNOPSIS
    Returns the modulo of dividend and divisor
     
    .DESCRIPTION
     VDS
    $mod = $(mod 60 30)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/mod
#>
}
function mousedown {
    return [System.Windows.Forms.UserControl]::MouseButtons | Out-String
<#
	.SYNOPSIS
	Returns the mousebutton that is pressed.
	 
	.DESCRIPTION
	$mousedown = $(mousedown)
	
	.LINK
	https://dialogshell.com/vds/help/index.php/mousedown
#>
} 
function mousepos($a) {
    switch ($a) {
        x {
            return [System.Windows.Forms.Cursor]::Position.X
        }
        y {
            return [System.Windows.Forms.Cursor]::Position.Y
        }
        xy {
        $x = [System.Windows.Forms.Cursor]::Position.X | Out-String
        $y = [System.Windows.Forms.Cursor]::Position.Y | Out-String
        return $x.Trim()+$fieldsep+$y.Trim()
        }
        yx {
        $x = [System.Windows.Forms.Cursor]::Position.X | Out-String
        $y = [System.Windows.Forms.Cursor]::Position.Y | Out-String
        return $y.Trim()+$fieldsep+$x.Trim()
        }
        default {
        $x = [System.Windows.Forms.Cursor]::Position.X | Out-String
        $y = [System.Windows.Forms.Cursor]::Position.Y | Out-String
        return $x.Trim()+$fieldsep+$y.Trim()
        }
    }
<#
    .SYNOPSIS
    Returns the mouse position as string with options being x, y, xy or yx. Defaults to xy.
     
    .DESCRIPTION
     VDS
    $mousepos = $(mousepos xy)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/mousepos
#>
} 
function msgbox($a,$b,$c,$d) {
    $msgbox = [System.Windows.Forms.MessageBox]::Show($a,$b,$c,$d)
    return $msgbox
<#
    .SYNOPSIS
    Generates a messagebox according to provided paramaters. 
    [param1 Message]
    [param2 Title]
    [param3 buttons, YesNo YesNoCancel OKCancel or OK]
    [param4 Icon, can be 0 (none) ,16 (Hand) ,32 (Question) ,48 (Warning) or 64 (Information)]
     
    .DESCRIPTION
     VDS
    $msgbox = $(msgbox 'Do we agree?' 'Question' 'YesNoCancel' 64)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/msgbox
#>  
} 
function name($a) {
    return [io.path]::GetFileNameWithoutExtension($a)
<#
    .SYNOPSIS
    Returns the file name without extension
     
    .DESCRIPTION
     VDS
    $name = $(name $file)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/name
#>
}
function next($a) {
    if ($a.items.count -gt $a.selectedIndex + 1) {
        $a.selectedIndex = $a.selectedIndex + 1
        return $a.selectedItems
    }
    else {
    return $false
    }
<#
    .SYNOPSIS
    Progresses a list to the next item.
     
    .DESCRIPTION
     VDS
    $next = $(next $listbox1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/next
#>
}
function not($a){
    if ($a -eq $false) {
        return $true
    }
    else {
    return $false}
<#
    .SYNOPSIS
    Returns true if false
     
    .DESCRIPTION
     VDS
    if ($(not $(null $value)))
    {console "It ain't nothing"}
     
    .LINK
    https://dialogshell.com/vds/help/index.php/not
#>
}
function null($a) {
    if ($a -eq $null) {
        return $true
    }
    else {
        return $false
    }
<#
    .SYNOPSIS
    Returns true if null
     
    .DESCRIPTION
     VDS
    if ($(not $(null $value)))
    {console "It ain't nothing"}
     
    .LINK
    https://dialogshell.com/vds/help/index.php/null
#>
}
function numeric($a) {
    return $a -is [int]
<#
    .SYNOPSIS
    Returns true if numeric
     
    .DESCRIPTION
     VDS
    console $(numeric $isnumber)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/numeric
#>
}
function ok {
    return $?
<#
    .SYNOPSIS
    Returns true if OK.
     
    .DESCRIPTION
     VDS
    console $(ok)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/ok
#>
} 
function path($a) {
    return Split-Path -Path $a
<#
    .SYNOPSIS
    Returns the path of a file
     
    .DESCRIPTION
     VDS
    console $(path $file)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/path
#>
}
function pos($a,$b) {
    $regEx = [regex]$a
    $pos = $regEx.Match($b)
    if ($pos.Success){ 
        return $pos.Index
    }
    else {
        return false
    }
<#
    .SYNOPSIS
    Returns the position of [param1] in [param2]
     
    .DESCRIPTION
     VDS
    console $(pos b brandon)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/pos
#>
} #partial implementation - missing 'exact'
function pred($a) {
    return $a - 1
<#
    .SYNOPSIS
    Returns the predecessor of number
     
    .DESCRIPTION
     VDS
    list seek $listbox1 $(pred $(index $listbox1))
    
    .LINK
    https://dialogshell.com/vds/help/index.php/pred
#>
}
function prod($a) {
    return $a + 1
<#
    .SYNOPSIS
    Returns the prodecessor of number
     
    .DESCRIPTION
     VDS
    list seek $listbox1 $(prod $(index $listbox1))
    
    .LINK
    https://dialogshell.com/vds/help/index.php/prod
#>
}
function query($a,$b) {
    $query = [System.Windows.Forms.MessageBox]::Show($a,$b,"OKCancel",32)
    return $query
<#
    .SYNOPSIS
    Generates an OK Cancel dialog and returns the result.
     
    .DESCRIPTION
     VDS
    $question = $(query "Is it Monday?" "Select Day")
    
    .LINK
    https://dialogshell.com/vds/help/index.php/query
#>
} 
function regexists($a,$b) {
    $return = Get-ItemProperty -Path $a -Name $b
    if ($return) {
    return $true
    }
    else {
    return $false
    }
<#
    .SYNOPSIS
    Returns true if the registry path exists
     
    .DESCRIPTION
     VDS
    console $(regexists hkcu:\software\dialogshell)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/regexists
#>
}
function regread($a,$b) {
    return Get-ItemProperty -Path $a -Name $b | Select -ExpandProperty $b
<#
    .SYNOPSIS
    Returns the value of a registry entry
     
    .DESCRIPTION
     VDS
    $regread = $(regread hkcu:\software\dialogshell window)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/regread
#>
} #partial implementation - path names are slightly different, $a is path with a : in it, $b is property. No default return. 
function regtype($a,$b) {
    switch ((Get-ItemProperty -Path $a -Name $b).$b.gettype().Name){ 
        "String" {
            return "REG_SZ"
        }
        "Int32" {
        return "REG_DWORD"
        }
        "Int64" {
        return "REG_QWORD"
        }
        "String[]" {
        return "REG_MULTI_SZ"
        }
        "Byte[]" {
        return "REG_BINARY"
        } 
        default {
        return "Unknown type"
        }
    }
<#
    .SYNOPSIS
    Returns the type of value from a registry entry
     
    .DESCRIPTION
     VDS
    $regtype = $(regtype hkcu:\software\dialogshell window)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/regtype
#>
} #partial implementation
function retcode() {
return $LASTEXITCODE
<#
    .SYNOPSIS
    Returns the last exit code
     
    .DESCRIPTION
     VDS
    console $(retcode)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/retcode
#>
}
function savedlg($a,$b,$c){
    $filedlg = New-Object System.Windows.Forms.SaveFileDialog
    $filedlg.initialDirectory = $b
    $filedlg.filter = $a
    $filedlg.ShowDialog() | Out-Null
    return $filedlg.FileName 
<#
    .SYNOPSIS
    Returns the results of a file selection dialog.
     
    .DESCRIPTION
     VDS
    $save = $(saveedlg 'Text Files|*.txt' $(windir)) 
     
    .LINK
    https://dialogshell.com/vds/help/index.php/savedlg
#>  
}
function selected($a) {
    return CountRows($a.SelectedItems)
<#
    .SYNOPSIS
    Returns the number of list items selected
     
    .DESCRIPTION
     VDS
    $selected = $(selected $listbox1)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/selected
#>
}
function sendmsg($a,$b,$c,$d) {
    [vds]::SendMessage($a, $b, $c, $d)
<#
    .SYNOPSIS
    See SendMessage Win32 API
    https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-sendmessage
     
    .DESCRIPTION
     VDS
    $currentrow = $(sendmsg $(winexists $RichEdit) 0x00c1 $RichEdit.SelectionStart 0)
     
    .LINK
    https://dialogshell.com/vds/help/index.php/sendmsg
#>
}
function shift($a) {
return "+$a"
<#
    .SYNOPSIS
     Sends the SHIFT key plus string. Only useful with 'window send'.
     
    .DESCRIPTION
     VDS
    window send $(winexists notepad) $(shift "s")
    
    .LINK
    https://dialogshell.com/vds/help/index.php/shift
#>
} 
function shortname {
    [cmdletbinding()]
    Param([Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)][array]$Path)
    If ($(Get-Item $Path).PSIsContainer -eq $true) {
        $SFSO = New-Object -ComObject Scripting.FileSystemObject
        $short = $SFSO.GetFolder($($Path)).ShortPath
    } 
    Else {
        $SFSO = New-Object -ComObject Scripting.FileSystemObject
        $short = $SFSO.GetFile($($Path)).ShortPath
    }
    return $short
<#
    .SYNOPSIS
     Returns the 8.3 shortname of a file
     
    .DESCRIPTION
     VDS
    $shortname = $(shortname $file)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/shortname
#>
}
function strdel($a,$b,$c) {
    return ($a.substring(0,$b)+$(substr $a $c $a.length))
<#
    .SYNOPSIS
     Returns the string without start index to end index.
     
    .DESCRIPTION
     VDS
    $string = $(strdel $string 8 16)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/strdel
#>
}
function string($a) {
return ($a | Out-String).trim()
#Proper form for dialogshell philosophy if splitting hairs: return $(trim $(Out-String -inputobject $a)) . Were it written before the trim function, ($(Out-String -inputobject $a)).Trim() . I don't feel we as a community should care, and this code is written and produces the expected output - so the point is moot. No one should touch this.

#Powershell proper form, which I really don't care about. It's ineffeicient and hard to remember. Feel free to write in this form, just don't expect me to.

<#
function string {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,mandatory=$true)]
        [string] $InputString)
        ($InputString | Out-String).Trim()
}
#>
#You'll notice proper powershell didn't include a return keyword, this is actually correct. I include the return keyword to discern a VDS function from a VDS command when I'm looking at the Powershell function without proper context.
#Expect me to be annoyed if you ask for help with a VDS function, and there is no return keyword, because I'll think I'm helping with a VDS command.
#Some keywords have both command and function form, like console. You'll notice the VDS function form of the keyword has a return statement.
<#
    .SYNOPSIS
     Converts a value to string.
     
    .DESCRIPTION
     VDS
    $string = $(string $value)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/string
#>
}
function substr($a,$b,$c) {
    return $a.substring($b,($c-$b))
<#
    .SYNOPSIS
     Gets the value of a string between a start index and a end index
     
    .DESCRIPTION
     VDS
    $string = $(substr $string 3 6)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/substr
#>
}
function succ($a) {
    return $a + 1
<#
    .SYNOPSIS
     Adds one to a value.
     
    .DESCRIPTION
     VDS
    $increase = $(succ $number)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/succ
#>
}
function sum($a,$b) {
    return $a + $b
<#
    .SYNOPSIS
     Adds two values.
     
    .DESCRIPTION
     VDS
    $total = $(sum $num1 $num2)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/sum
#>
} #partial implementation - only accepts two params
function sysinfo($a) {
    switch ($a) {
        freemem {
            $return = Get-WmiObject Win32_OperatingSystem | fl FreePhysicalMemory | Out-String
            return $return.split(':')[1].Trim() 
        } 
        pixperin {
        return $(regread 'hkcu:\Control Panel\Desktop\WindowMetrics' 'AppliedDpi')
        } 
        screenheight {
            foreach ($screen in [system.windows.forms.screen]::AllScreens) {
                if ($screen.primary) {
                    return $screen.Bounds.Height
                }
            }
        }
        screenwidth {
            foreach ($screen in [system.windows.forms.screen]::AllScreens) {
                if ($screen.primary) {
                    return $screen.Bounds.Width
                }
            }
        }    
        winver {
            $major = [System.Environment]::OSVersion.Version | Select-Object -expandproperty Major | Out-String
            $minor = [System.Environment]::OSVersion.Version | Select-Object -expandproperty Minor | Out-String
            $build = [System.Environment]::OSVersion.Version | Select-Object -expandproperty Build | Out-String
            $revision = [System.Environment]::OSVersion.Version | Select-Object -expandproperty Revision | Out-String
            return $major.Trim()+'.'+$minor.Trim()+'.'+$build.Trim()+'.'+$revision.Trim()
        } 
        win32 {
            return [Environment]::Is64BitProcess | Out-String
        } 
        psver {
            $major = $psversiontable.psversion.major | Out-String
            $minor = $psversiontable.psversion.minor | Out-String
            $build = $psversiontable.psversion.build | Out-String
            $revision = $psversiontable.psversion.revision | Out-String
            return $major.Trim()+'.'+$minor.Trim()+'.'+$build.Trim()+'.'+$revision.Trim() 
        } 
        dsver {
        return '0.2.5.4'
        }
        winboot {
            $return = Get-CimInstance -ClassName win32_operatingsystem | fl lastbootuptime | Out-String
            $return = $return.split('e')[1].Trim()
            $return = $(substr $return 2 $(len $return))
            return $return
        }
        screenrect {
            $z = '0'
            $sw = $(sysinfo screenwidth) | Out-String
            $sh = $(sysinfo screenheight) | Out-String
            return $z+$fieldsep+$z+$fieldsep+$sw.Trim()+$fieldsep+$sh.Trim()
        }
        language {
            return GET-WinSystemLocale |Select-Object -expandproperty DisplayName
        }
    }
<#
	.SYNOPSIS
	 Returns information about the system according to parameter.
	 Available parameters: freemem, pixperin, screenwidth, winver, win32, psver, dsver, winboot, screenrect, language
	 
	.DESCRIPTION
	$syinfo = $(sysinfo screenrect)
	
	.LINK
	https://dialogshell.com/vds/help/index.php/sysinfo
#>
} 

function tab {
    return "`t" 
<#
    .SYNOPSIS
    Returns the tab character, useful with window send
     
    .DESCRIPTION
     VDS
    window send $(winexists notepad) $(tab)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/tab
#>
} 
function text ($a) {
    return [array]$a.items | Out-String
<#
    .SYNOPSIS
    Returns the entire text of a list
     
    .DESCRIPTION
     VDS
    $text = $(text $listbox1)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/text
#>
} 
function the ($a,$b,$c) { #supports option "of" for $b
    if ($(null $c)) {
        return $b.$a
    }
    else {
    return $c.$a
    }
<#
    .SYNOPSIS
    Language element, represents the property of object.
     
    .DESCRIPTION
     VDS
    foreach($row in $(the Rows of $mElemetnsGrid)){}
    
    .LINK
    https://dialogshell.com/vds/help/index.php/the
#>
}
function trim ($a) {
    return $a.Trim()
<#
    .SYNOPSIS
    Returns the trim of a string
     
    .DESCRIPTION
     VDS
    $trimStr = $(trim $string)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/trim
#>
} 
function unequal($a, $b) {
    if ($a -eq $b) {
        return $false
    } 
    else {
        return $true
    }
<#
    .SYNOPSIS
    Returns true if two values are not equal
     
    .DESCRIPTION
     VDS
    $testEq = $(unequal $val1 $val2)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/unequal
#>
}
function upper($a) {
    return $a.ToUpper()
<#
    .SYNOPSIS
    Returns the string in uppercase
     
    .DESCRIPTION
     VDS
    $upperonly = $(upper $string)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/upper
#>
}
function val($a) {
    return $a
<#
    .SYNOPSIS
    Does nothing. Returns what's sent.
     
    .DESCRIPTION
     VDS
    $val = $(val 42)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/val
#>
} 
function volinfo($a,$b) {
    switch ($b) {
        F {
            return get-volume $a | Select-Object -expandproperty SizeRemaining
        }
        N { 
            return get-volume $a | Select-Object -expandproperty FriendlyName
        }
        S {
            return get-volume $a | Select-Object -expandproperty Size
        }
        T {
            return get-volume $a | Select-Object -expandproperty DriveType
        }
        Y {
            return get-volume $a | Select-Object -expandproperty FileSystemType
        }
        Z {
            return get-partition -driveletter $a | Get-Disk | Select-Object -expandproperty SerialNumber
        }
    }
<#
    .SYNOPSIS
    Does nothing. Returns what's sent.
     
    .DESCRIPTION
     VDS
    $val = $(val 42)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/volinfo
#>  
} 
function winactive($a) {
    return [vds]::GetForegroundWindow()
<#
    .SYNOPSIS
    Returns the active window handle
     
    .DESCRIPTION
     VDS
    $activewin = $(winactive)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/winactive
#>
}  
function winatpoint($a,$b) {
    $p = new-object system.drawing.point($a,$b)
    $return = [vds]::WindowFromPoint($p)
    return $return;
<#
    .SYNOPSIS
    Returns the window handle at x y
     
    .DESCRIPTION
     VDS
    $windowatxy = $(winatpoint 32 64)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/winatpoint
#>
}
function winclass($a) {
    $stringbuilt = New-Object System.Text.StringBuilder 256
    $that = [vds]::GetClassName($a, $stringbuilt, 256)
    return $($stringbuilt.ToString())
<#
    .SYNOPSIS
    Returns the window class by handle
     
    .DESCRIPTION
     VDS
    $class = $(winclass $(winexists "Untitled - Notepad"))
    
    .LINK
    https://dialogshell.com/vds/help/index.php/winclass
#>
} 
function windir($a) {
    return $(env windir)
<#
    .SYNOPSIS
    Returns the windows directory
     
    .DESCRIPTION
     VDS
    $windows = $(windir)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/windir
#>
} 
function winexists($a) {
    $class = [vds]::FindWindowByClass($a)
    if ($class) {
        return $class/1
    }
    else {
        $title = [vds]::FindWindowByTitle($a)
        if ($title){
            return $title/1
        }
        else {
            if ($a.handle) {
                return $a.handle
            }
        }   
    }
<#
    .SYNOPSIS
    Returns the handle of a window by class, title or $object
     
    .DESCRIPTION
     VDS
    $notepadopen = $(winexists notepad)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/winexists
#>
} 
function winpos($a,$b) {
    $Rect = New-Object RECT
    [vds]::GetWindowRect($a,[ref]$Rect) | Out-Null
    switch ($b)
    {
        T {
            return $Rect.Top
        }
        L {
            return $Rect.Left
        }
        W {
            return $Rect.Right - $Rect.Left
        }
        'H' {
        return $Rect.Bottom - $Rect.Top
        }
    }
<#
    .SYNOPSIS
    Returns a position element of a window by paramater
    Available parameters: T, L, W, H (Top, Left, Width, Height)
     
    .DESCRIPTION
     VDS
    $wintop = $(winpos $(winactive) T)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/winpos
#>
}
function wintext($a) {
    $strbld = [vds]::GetWindowTextLength($a)
    $stringbuilt = New-Object System.Text.StringBuilder $strbld+1
    $that = [vds]::GetWindowText($a, $stringbuilt, $strbld+1)
    return $($stringbuilt.ToString())
<#
    .SYNOPSIS
    Returns the text of a window
     
    .DESCRIPTION
     VDS
    $Stext = $(wintext $(winactive))
    
    .LINK
    https://dialogshell.com/vds/help/index.php/wintext
#>
}
function zero($a) {
    if ($a -eq 0) {
        return $true
    } 
    else {
    return $false
    }
<#
    .SYNOPSIS
    Returns $true if a value is zero
     
    .DESCRIPTION
     VDS
    $test = $(zero $num)
    
    .LINK
    https://dialogshell.com/vds/help/index.php/zero
#>
}

