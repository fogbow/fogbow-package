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
Source: "PyBow27"; DestDir: "{app}"

[Icons]
Name: "{group}\Nova\nova.conf"; Filename: "notepad.exe"; Parameters: "{pf}\Fogbow\Nova\etc\nova.conf";
Name: "{group}\Nova\Uninstall"; Filename: "{uninstallexe}";

[UninstallDelete]
Type: dirifempty; Name: {pf}\Fogbow\Nova; 
Type: dirifempty; Name: {pf}\Fogbow;
