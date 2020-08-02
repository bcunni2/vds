# Visual DialogShell

Visual DialogShell is a way forward for DialogScript syntax within Powershell ~ this project exists to provide a vehicle for the spirit of the DialogScript language to continue - providing a concise, powerful, straightforward language with seemingly untyped variables. I say seemingly because Powershell doesn't actually have variables, it has objects that it auto-determines the type for, but they feel like untyped variables.

# Issue Velocity Points
Leave a comment under any task you'd like to be assigned to in the format [n][n] where n is a fibonacci number, the first representing how complex you feel the issue is, and the second representing how much effort you feel it will take to resolve. 

# Discord
https://discord.gg/87EyrgJ
(maybe email me to schedule until things get rolling brandoncomputer@hotmail.com)

## Getting Started
The best way to get started is to find a brief minimal Powershell tutorial, and review the provided material and examples here. Visual DialogShell is technically a Powershell module, but the goal of the module is to create seamless DialogScript integration. Powershell scripting will just work, and as much of DialogScript as possible will also be supported.

Powershell is technically speaking "Powershell.NET". That means this should feel a lot like a "DialogScript.NET" vibe. Things changed drastically from VB6 to VB.NET, we can expect some of the same style roadblocks VB users had transitioning even after this is ready for production use.

A great way to learn about .NET contols is through this PDF online: https://docs.microsoft.com/en-us/dotnet/opbuildpdf/framework/winforms/controls/toc.pdf?branch=live
The web version lives here: https://docs.microsoft.com/en-us/dotnet/framework/winforms/controls/ and the part we are probably most interested in lives here: https://docs.microsoft.com/en-us/dotnet/framework/winforms/controls/windows-forms-controls-by-function

Compile order: 
vds/compile/compile/make.bat
vds/compile/dialogshell.bat
vds/compile/visual dialogshell.bat
vds/dialog designer.bat

### Prerequisites

Windows 7 or above with Powershell is the primary prerequisite. 

For IDE choices, Powershell ISE is good to get started, but Visual Studio Code is more appropriate. I actually settled on Notepad++, and added this to my Run Run Save:
c:\vds\trunk\compile\DialogShell.exe "$(FULL_CURRENT_PATH)" -cpath

DialogShell.exe is partially compatible with Visual Studio Code as a console, but may need more work.

The intent is to mirror Microsoft Extended support ~ currently that means any changes made should work in Windows 7, although .Net 4.5 and Windows Management Framework 3.0 must be present.
Example script syntax:

```
$form1 =   dialog create "Hello World" 500 500 300 300
$button1 = dialog add $form1 button 10 10 100 20 "Click Me"

$timer = timer 1000
$timer.add_Tick({
console "Tick"
})

$button1.add_Click({
$info = $(chr 34) + "Hello World!" + $(chr 34)
info $info #Comment: We could have just called called the string directly from the info command, but it's more fun to show a defined object (variable)
})

$button1.add_MouseHover({
console "you are hovering!"
})


dialog show $form1

#Code pauses execution when the form is shown.

#:CLOSE

console $(dlgprops $button1)

console "exit"
exit

#END SCRIPT

```

### Notes about Commands, Functions, Assertions and Directives - and Pipes
(Powershell and most languages do not make this distinguishment, all are 'functions' in more traditional languages)
```
#Powershell 
$x = "Brandon".substring(2,2) 
[System.Windows.MessageBox]::Show($x+" ps","",'OK',64) | Out-Null; 

#VDS Function - classic syntax equivelent. 
$x = $(substr Brandon 2 4) 

#VDS Assertion - A function that won't work within another call, but works to assign an object. 
$x = substr Brandon 2 4 

#VDS Command - classic syntax equivelent. 
info $x" Command" 

#VDS Directive - a command that will work within another call. 
$(info $x" Directive") 

info "Let's do this a bizaare way"$(info $x" Directive in a String") 
#The directive was processed before the command. 

$(info $x" Directive in a sequence")+$(info "Let's do this a very bizzare way") 
#The directives executed in order. 

#Let's skip the assignment. 
info "$(substr Brandon 2 4) assignment skipped" 

#Pipes are input objects and also have the long form of -inputobject.
$a = 45 | Out-String
$a = Out-String -inputobject 45
$a = $(Out-String -inputobject 45)

#Law of Demeter - This needs a true dialogshell function so we built one.
$a = $(string 45)
#We don't care about cryptic pipe symbols. 
#We don't care about the Out verb. 
#We don't care about -inputobject, it always has the same ordinal position. 
#We do care that this doesn't work right, so internally we returned the trim of the desired output to avoid the additional carriage return line feed that's added.
#Ultimately after the code is written, we only care that when the end user inputs something, the expected output occurs.
```

### The Powershell String Function 
(First see notes about pipes above)
```
function string($a) {
return ($a | Out-String).trim()
#Proper form for dialogshell philosophy if splitting hairs: return $(trim $(Out-String -inputobject $a)) . Were it written before the trim function, ($(Out-String -inputobject $a)).Trim() . I don't feel we as a community should care, and this code is written and produces the expected output - so the point is moot. No one should touch this.

#Powershell proper form

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
}
```

In relation to Visual DialogShell and not necessarily Powershell in practical but not technical language.
----------------------------------------------------------------
(Powershell will not abide comma's. We must get over this and move on.)
$OBJECT - This can be a jumpto, an object or a variable.
$(FUNCTION PARAM1 PARAM2) - This is how function calls are made. 
COMMAND PARAM1 PARAM2 - This is how commands are called.

As seen above a special exception has been made for DIALOG. According to DialogScript, DIALOG would now be a function (@dialog()) but we are not doing that. I do however recommend calling the dialog command as an object that can be acted upon - otherwise you can't act on it. (When you think about it, this was also true in previous implementations of DialogScript, because the dialog command abstracted the user defined name of each dialog object (dialog select,0 or BUTTON1) - so this is arguably a non-change).

New events are available for most objects you are familiar with, use the new function dlgprops $(dlgprops $object) to discover stuff such as $button1.add_MouseHover above, this also can return the value of a property like $(dlgprops $button1 Text).

### Installing

Download template.ps1 and vds.psm1. template.ps1 should be a good example to get kicking off from.
Typically our environment is Windows Powershell ISE, however, if you are not an administrator, you'll need to kick off template.ps1 and other scripts from the command prompt or a shortcut as follows:

From command prompt, use

powershell c:\mypath\myscript.ps1 -executionpolicy bypass

To create a shortcut that can be ran by any user, use:

c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -executionpolicy bypass -sta -file "c:\MyPath\MyFile.ps1"

If you are an admin, you might want to consider changing your execution policy for powershell example: Set-ExecutionPolicy Unrestricted , as another alternative you can also utilize unblock-file.

*Although above 'Installing' is still great info, we now do have build procedures.
Compile order: 
vds/compile/compile/make.bat
vds/compile/dialogshell.bat
vds/compile/visual dialogshell.bat
vds/dialog designer.bat

## Authors

* **Brandon Cunningham** - *Initial work* - brandoncomputer@hotmail.com - forum.vdsworld.com | cnodnarb

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
```
Julian Moss (jules)
FreezingFire
Skit3000
Garrett
LiquidCode
Mac
Serge
vdsalchemist
Dr. Dread
CodeScript
PGWARE, for encouraging me on this project
```
