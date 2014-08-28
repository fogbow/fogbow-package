[Setup]
AppName=Nova Compute
AppVersion=0.0.1
AppPublisher=Fogbow
AppCopyright=Fogbow
DefaultDirName={pf}\Fogbow\Nova
DefaultGroupName=Fogbow
Compression=lzma2
SolidCompression=yes
OutputDir=userdocs:.fogbow\setup

[Files]
Source: "ReplaceTokens.vbs"; DestDir: "{tmp}"
Source: "Pybow27\*"; DestDir: "{app}\Pybow27"; Flags: recursesubdirs
Source: "uac.vbs"; DestDir: "{app}"
Source: "updater.py"; DestDir: "{app}"
Source: "tags"; DestDir: "{app}"
Source: "qemu\*"; DestDir: "{app}\qemu"; Flags: recursesubdirs
Source: "fogbow-powernap-win32\run.py"; DestDir: "{app}\powernap"
Source: "powernap.conf"; DestDir: "{commonappdata}\Fogbow\etc"
Source: "nova.conf"; DestDir: "{commonappdata}\Fogbow\etc"

[Icons]
Name: "{group}\Nova\nova.conf"; Filename: "{app}\uac.vbs"; Parameters: "notepad.exe {commonappdata}\Fogbow\etc\nova.conf";
Name: "{group}\Nova\Start Nova"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe /Run /TN NovaComputeStarter";
Name: "{group}\Nova\Stop Nova"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe /End /TN NovaComputeStarter";
Name: "{group}\Powernap\powernap.conf"; Filename: "{app}\uac.vbs"; Parameters: "notepad.exe {commonappdata}\Fogbow\etc\powernap.conf";
Name: "{group}\Powernap\Start Powernap"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe /Run /TN PowernapStarter";
Name: "{group}\Powernap\Stop Powernap"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe /End /TN PowernapStarter";
Name: "{group}\Uninstall"; Filename: "{uninstallexe}";

[Run]
Filename: {tmp}\ReplaceTokens.vbs; Parameters: " ""{commonappdata}\Fogbow\etc\nova.conf"" ""[[NOVA_DIR]]={code:Normalize|{commonappdata}\Fogbow\etc}"" "; Flags: skipifdoesntexist waituntilterminated runhidden shellexec; StatusMsg: Setting configuration
Filename: {tmp}\ReplaceTokens.vbs; Parameters: " ""{commonappdata}\Fogbow\etc\powernap.conf"" ""[[NOVA_DIR]]={code:Normalize|{commonappdata}\Fogbow\etc}"" "; Flags: skipifdoesntexist waituntilterminated runhidden shellexec; StatusMsg: Setting configuration

; Nova compute service
Filename: "schtasks.exe"; Parameters: "/create /F /sc onstart /tn NovaComputeStarter /rl highest /tr ""{\}""{app}\Pybow27\Scripts\nova-compute.exe{\}"" --config-file {\}""{commonappdata}\Fogbow\etc\nova.conf{\}"""" /ru ""SYSTEM"" "; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Run /TN NovaComputeStarter"; Flags: runhidden

; Powernap service
Filename: "schtasks.exe"; Parameters: "/create /F /sc onstart /tn PowernapStarter /rl highest /tr ""{\}""{app}\Pybow27\python.exe{\}"" {\}""{app}\powernap\run.py{\}"" {\}""{commonappdata}\Fogbow\etc\powernap.conf{\}"""" /ru ""SYSTEM"" "; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Run /TN PowernapStarter"; Flags: runhidden

; Updater service
Filename: "schtasks.exe"; Parameters: "/create /F /sc onstart /sc daily /st 22:00 /tn FogbowUpdater /rl highest /tr ""{\}""{app}\Pybow27\python.exe{\}"" {\}""{app}\updater.py{\}"" {\}""{app}{\}"""" /ru ""SYSTEM"" "; Flags: runhidden

Filename: "sc.exe"; Parameters: "config msiscsi start= auto"; Flags: runhidden
Filename: "net.exe"; Parameters: "start msiscsi"; Flags: runhidden

[UninstallDelete]
Type: dirifempty; Name: {pf}\Fogbow\Nova; 
Type: dirifempty; Name: {pf}\Fogbow;

[UninstallRun]
Filename: "schtasks.exe"; Parameters: "/End /TN NovaComputeStarter"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Delete /F /TN NovaComputeStarter"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/End /TN PowernapStarter"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Delete /F /TN PowernapStarter"; Flags: runhidden

[Code]
function Normalize(Param: String): String;
begin
  StringChange(Param, '\', '\\');
  Result := Param
end;