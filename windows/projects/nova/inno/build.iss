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
Name: "{group}\Nova\nova.conf"; Filename: "{app}\uac.vbs"; Parameters: "notepad.exe {commonappdata}\Fogbow\etc\nova.conf"; IconFilename: "notepad.exe";
Name: "{group}\Nova\Start Nova"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe ""/Run /TN NovaComputeStarter"""; IconFilename: "schtasks.exe";
Name: "{group}\Nova\Stop Nova"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe ""/End /TN NovaComputeStarter"""; IconFilename: "schtasks.exe";
Name: "{group}\Powernap\powernap.conf"; Filename: "{app}\uac.vbs"; Parameters: "notepad.exe {commonappdata}\Fogbow\etc\powernap.conf"; IconFilename: "notepad.exe";
Name: "{group}\Powernap\Start Powernap"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe ""/Run /TN PowernapStarter"""; IconFilename: "schtasks.exe";
Name: "{group}\Powernap\Stop Powernap"; Filename: "{app}\uac.vbs"; Parameters: "schtasks.exe ""/End /TN PowernapStarter"""; IconFilename: "schtasks.exe";
Name: "{group}\Uninstall"; Filename: "{uninstallexe}";

[Run]
; Stop and delete services if they already exist
Filename: "schtasks.exe"; Parameters: "/End /TN NovaComputeStarter"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Delete /F /TN NovaComputeStarter"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/End /TN PowernapStarter"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Delete /F /TN PowernapStarter"; Flags: runhidden

; Replace tokens in conf files
Filename: {tmp}\ReplaceTokens.vbs; Parameters: " ""{commonappdata}\Fogbow\etc\nova.conf"" ""[[NOVA_DIR]]={commonappdata}\Fogbow\etc;[[NOVA_APP_DIR]]={app}"" "; Flags: skipifdoesntexist waituntilterminated runhidden shellexec; StatusMsg: Setting configuration
Filename: {tmp}\ReplaceTokens.vbs; Parameters: " ""{commonappdata}\Fogbow\etc\powernap.conf"" ""[[NOVA_DIR]]={commonappdata}\Fogbow\etc"" "; Flags: skipifdoesntexist waituntilterminated runhidden shellexec; StatusMsg: Setting configuration

; Nova compute service
Filename: "schtasks.exe"; Parameters: "/create /F /sc onstart /tn NovaComputeStarter /rl highest /tr ""{\}""{app}\Pybow27\python.exe{\}""  {\}""{app}\Pybow27\Scripts\nova-compute-script.py{\}"" --config-file {\}""{commonappdata}\Fogbow\etc\nova.conf{\}"""" /ru ""SYSTEM"" "; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Run /TN NovaComputeStarter"; Flags: runhidden

; Powernap service
Filename: "schtasks.exe"; Parameters: "/create /F /sc onstart /tn PowernapStarter /rl highest /tr ""{\}""{app}\Pybow27\python.exe{\}"" {\}""{app}\powernap\run.py{\}"" {\}""{commonappdata}\Fogbow\etc\powernap.conf{\}"""" /ru ""SYSTEM"" "; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Run /TN PowernapStarter"; Flags: runhidden

; Updater service
Filename: "schtasks.exe"; Parameters: "/create /F /sc daily /st 21:34 /tn FogbowUpdater /rl highest /tr ""{\}""{app}\Pybow27\python.exe{\}"" {\}""{app}\updater.py{\}"" {\}""{app}{\}"""" /ru ""SYSTEM"" "; Flags: runhidden

; Activate scsicli
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
Filename: "schtasks.exe"; Parameters: "/End /TN FogbowUpdater"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Delete /F /TN FogbowUpdater"; Flags: runhidden

[Code]
function Normalize(Param: String): String;
begin
  StringChange(Param, '\', '\\');
  Result := Param
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: integer;
begin
  Exec('schtasks.exe', '/End /TN NovaComputeStarter', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec('schtasks.exe', '/Delete /F /TN NovaComputeStarter', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec('schtasks.exe', '/End /TN PowernapStarter', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec('schtasks.exe', '/Delete /F /TN PowernapStarter', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec('schtasks.exe', '/End /TN FogbowUpdater', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec('schtasks.exe', '/Delete /F /TN FogbowUpdater', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
end;

const
  NET_FW_SCOPE_ALL = 0;
  NET_FW_IP_VERSION_ANY = 2;

procedure SetFirewallException(AppName,FileName:string);
var
  FirewallObject: Variant;
  FirewallManager: Variant;
  FirewallProfile: Variant;
begin
  try
    FirewallObject := CreateOleObject('HNetCfg.FwAuthorizedApplication');
    FirewallObject.ProcessImageFileName := FileName;
    FirewallObject.Name := AppName;
    FirewallObject.Scope := NET_FW_SCOPE_ALL;
    FirewallObject.IpVersion := NET_FW_IP_VERSION_ANY;
    FirewallObject.Enabled := True;
    FirewallManager := CreateOleObject('HNetCfg.FwMgr');
    FirewallProfile := FirewallManager.LocalPolicy.CurrentProfile;
    FirewallProfile.AuthorizedApplications.Add(FirewallObject);
  except
  end;
end;

procedure RemoveFirewallException( FileName:string );
var
  FirewallManager: Variant;
  FirewallProfile: Variant;
begin
  try
    FirewallManager := CreateOleObject('HNetCfg.FwMgr');
    FirewallProfile := FirewallManager.LocalPolicy.CurrentProfile;
    FireWallProfile.AuthorizedApplications.Remove(FileName);
  except
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep=ssPostInstall then
     SetFirewallException('Fogbow Nova Qemu i386', ExpandConstant('{app}')+'\qemu\qemu-system-i386.exe');
     SetFirewallException('Fogbow Nova Qemu x86_64', ExpandConstant('{app}')+'\qemu\qemu-system-x86_64.exe');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep=usPostUninstall then
     RemoveFirewallException(ExpandConstant('{app}')+'\qemu\qemu-system-i386.exe');
     RemoveFirewallException(ExpandConstant('{app}')+'\qemu\qemu-system-x86_64.exe');
end;