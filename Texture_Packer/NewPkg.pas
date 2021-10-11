unit NewPkg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TNewPkgForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    NomEdit: TEdit;
    Label3: TLabel;
    DescriptionEdit: TEdit;
    Label4: TLabel;
    VersionEdit: TEdit;
    Label5: TLabel;
    AuteurEdit: TEdit;
    Bevel1: TBevel;
    ApplyBtn: TButton;
    CancelBtn: TButton;
    SaveDlg: TSaveDialog;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  NewPkgForm: TNewPkgForm;
  OperationTag: Boolean;

implementation

uses Main;

{$R *.dfm}

procedure TNewPkgForm.CancelBtnClick(Sender: TObject);
begin
 Close;
end;

procedure TNewPkgForm.FormCreate(Sender: TObject);
begin
 DoubleBuffered := True;
end;

procedure TNewPkgForm.FormShow(Sender: TObject);
begin
  case OperationTag of
 False:
  begin
   NomEdit.Text := '';
   DescriptionEdit.Text := '';
   VersionEdit.Text := '';
   AuteurEdit.Text := '';
   Caption := 'Nouveau paquet de textures';
   ApplyBtn.Caption := 'Créer le nouveau paquet';
   Label1.Caption := 'Création d''un nouveau paquet de textures vierge.';
  end;
 True:
  begin
   NomEdit.Text := Textures.PackageName;
   DescriptionEdit.Text := Textures.PackageDescription;
   VersionEdit.Text := Textures.PackageVersion;
   AuteurEdit.Text := Textures.PackageAuthor;
   Caption := 'Paquet de textures actuel';
   ApplyBtn.Caption := 'Modifier le paquet';
   Label1.Caption := 'Modification du paquet actuel.';
  end;
 end;
end;

procedure TNewPkgForm.ApplyBtnClick(Sender: TObject);
begin
 case OperationTag of
 False:
  begin
   Textures.NewPackage(NomEdit.Text, DescriptionEdit.Text, VersionEdit.Text, AuteurEdit.Text);
   if SaveDlg.Execute then
    begin
     CurrentFile := SaveDlg.FileName;
     Textures.SavePackage(CurrentFile);
     Close;
    end;
  end;
 True:
  begin
   Textures.PackageName := NomEdit.Text;
   Textures.PackageDescription := DescriptionEdit.Text;
   Textures.PackageVersion := VersionEdit.Text;
   Textures.PackageAuthor := AuteurEdit.Text;
   Textures.SavePackage(CurrentFile);
   Close;
  end;
 end;
 MainForm.DrawTextures;
end;

end.
