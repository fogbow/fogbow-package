Set UAC = CreateObject("Shell.Application")
UAC.ShellExecute WScript.Arguments(0), WScript.Arguments(1), "", "runas", 1