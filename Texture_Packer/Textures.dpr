program Textures;

uses
  Windows, Forms,
  Main in 'Main.pas' {MainForm},
  TexturePkg in 'TexturePkg.pas',
  Texture in 'Texture.pas',
  NewPkg in 'NewPkg.pas' {NewPkgForm},
  ImportTex in 'ImportTex.pas' {ImportForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Texture Packer';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TNewPkgForm, NewPkgForm);
  Application.CreateForm(TImportForm, ImportForm);
  Application.Run;
end.
