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
Source: "Pybow27\*"; DestDir: "{app}\Pybow27"; Flags: recursesubdirs
Source: "nova.conf"; DestDir: "{app}\etc"

[Icons]
Name: "{group}\Nova\nova.conf"; Filename: "notepad.exe"; Parameters: "{app}\etc\nova.conf";
Name: "{group}\Nova\Uninstall"; Filename: "{uninstallexe}";

[UninstallDelete]
Type: dirifempty; Name: {pf}\Fogbow\Nova; 
Type: dirifempty; Name: {pf}\Fogbow;
