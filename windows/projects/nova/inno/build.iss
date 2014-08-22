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
Source: "qemu\*"; DestDir: "{app}\qemu"; Flags: recursesubdirs
Source: "nova.conf"; DestDir: "{app}\etc"

[Icons]
Name: "{group}\Nova\nova.conf"; Filename: "notepad.exe"; Parameters: "{app}\etc\nova.conf";
Name: "{group}\Nova\Uninstall"; Filename: "{uninstallexe}";

[Run]
Filename: {tmp}\ReplaceTokens.vbs; Parameters: " ""{app}\etc\nova.conf"" ""[[NOVA_DIR]]={code:Normalize|{app}\etc}"" "; Flags: skipifdoesntexist waituntilterminated runhidden shellexec; StatusMsg: Setting configuration
Filename: "{cmd}"; Parameters: "schtasks /create /sc onstart /tn NovaComputeStarter /rl highest /tr """"{app}\Pybow27\Scripts\nova-compute.exe"" --config-file ""{app}\etc\nova.conf"""" /ru ""SYSTEM"" "; Flags: runhidden
Filename: "{cmd}"; Parameters: "schtasks /Run /TN NovaComputeStarter"; Flags: runhidden

[UninstallDelete]
Type: dirifempty; Name: {pf}\Fogbow\Nova; 
Type: dirifempty; Name: {pf}\Fogbow;

[Code]
function Normalize(Param: String): String;
begin
  StringChange(Param, '\', '\\');
  Result := Param
end;