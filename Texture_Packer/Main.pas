unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, ToolWin, TexturePkg, Texture, ExtDlgs, Menus;

type
  TMainForm = class(TForm)
    List: TListView;
    TexList: TImageList;
    ToolList: TImageList;
    ToolBar: TToolBar;
    QuitBtn: TToolButton;
    Separator1: TToolButton;
    LoadBtn: TToolButton;
    SaveBtn: TToolButton;
    Separator2: TToolButton;
    ImportBtn: TToolButton;
    ExportBtn: TToolButton;
    Separator3: TToolButton;
    OptionsBtn: TToolButton;
    DeleteBtn: TToolButton;
    NewBtn: TToolButton;
    OpenDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    ListPopup: TPopupMenu;
    QuitMenu: TMenuItem;
    N1: TMenuItem;
    NewMenu: TMenuItem;
    LoadMenu: TMenuItem;
    SaveMenu: TMenuItem;
    N2: TMenuItem;
    ImportMenu: TMenuItem;
    ExportMenu: TMenuItem;
    DeleteMenu: TMenuItem;
    N3: TMenuItem;
    OptionsMenu: TMenuItem;
    Status: TStatusBar;
    N4: TMenuItem;
    ViewColor: TMenuItem;
    ColorDlg: TColorDialog;
    procedure QuitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewBtnClick(Sender: TObject);
    procedure OptionsBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure ExportBtnClick(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
    procedure ListPopupPopup(Sender: TObject);
    procedure ViewColorClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    procedure DrawTextures;
    procedure Log(AText: String);
  end;

var
  MainForm: TMainForm;
  Textures: TTexturePkg; // Le coeur de l'application : le paquet de textures
  CurrentFile: String; // Fichier paquet actuel

implementation

uses NewPkg, ImportTex;

{$R *.dfm}

procedure TMainForm.Log(AText: String);
begin
 Textures.WriteInConsole(AText); // On écrit dans la console
end;

procedure TMainForm.QuitBtnClick(Sender: TObject);
begin
 Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 Textures := TTexturePkg.Create;  // On instancie le package des textures
 if FindCmdLineSwitch('debug', ['-','/'], true) then Textures.SetConsoleHandles('Console de debogage de Texture Packer');

 Log('===============================================');
 Log('==== Console de debogage de Texture Packer ====');
 Log('===============================================');
 Log(' ');
 Log('      *** Ne pas fermer cette fenetre ***');
 Log(' ');
 Log(' ');
 Log('Initialisation du paquet de textures ...');
 Log('Paquet de textures initialise ...');

 DoubleBuffered := True;
 List.DoubleBuffered := True;  // On evite les scintillements
 ToolBar.DoubleBuffered := True;
 DrawTextures;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if CurrentFile <> ''
 then
  if MessageDlg('Voulez-vous vraiment quitter? Le paquet en cours sera automatiquement sauvegardé.', mtConfirmation, [mbYes, mbNo], 0) = mrNo
  then
   begin
    Action := caFree;
    Exit;
   end
 else
  if CurrentFile <> ''
  then Textures.SavePackage(CurrentFile); // On enregistre les textures avant de quitter

 Textures.Free;  // On libère le package des textures avant qu'il ne se fasse détruire
 // Puis la fiche se ferme, ainsi que l'application !
end;

procedure TMainForm.DrawTextures;
Var
 I: Integer;
 Bmp: TBitmap;
 Tex: TTexture;
 A: TListItem;
 F: TFileStream;
begin
 if CurrentFile <> '' then
  begin
   Status.Panels[0].Text := IntToStr(Textures.PackageCount) + ' textures';
   F := TFileStream.Create(CurrentFile, FMOPENREAD);
   Status.Panels[1].Text := IntToStr(F.Size div 1024) + ' Ko';
   F.Free;
   Status.Panels[2].Text := ' ' + CurrentFile;
  end
 else
  begin
   Status.Panels[0].Text := 'Pas de textures';
   Status.Panels[1].Text := 'Aucun paquet';
   Status.Panels[2].Text := ' Aucun paquet ouvert';
  end;
 Bmp := TBitmap.Create;
 Tex := TTexture.Create;
 TexList.Clear;
 List.Clear;
 for I := 0 to Textures.PackageCount - 1 do
  begin
   Textures.ReadTexture(I, Tex);
   Bmp.Assign(Tex.Texture);
   Bmp.Width := 128;
   Bmp.Height := 128;
   TexList.Add(Bmp, nil);
   A := List.Items.Add;
   A.Caption := Tex.Nom + chr(13) + Tex.Auteur;
   A.ImageIndex := I;
  end;
 Tex.Free;
 Bmp.Free;
end;

procedure TMainForm.NewBtnClick(Sender: TObject);
begin
 OperationTag := False;
 NewPkgForm.ShowModal;
end;

procedure TMainForm.OptionsBtnClick(Sender: TObject);
begin
 if CurrentFile = '' then
  raise Exception.Create('Aucun paquet chargé.');
 OperationTag := True;
 NewPkgForm.ShowModal;
end;

procedure TMainForm.DeleteBtnClick(Sender: TObject);
begin
 if (List.ItemIndex > -1) and (CurrentFile <> '') then
  begin
   Textures.DeleteTexture(List.ItemIndex);
   Textures.SavePackage(CurrentFile);
   DrawTextures;
  end
 else
  raise Exception.Create('Aucune texture sélectionnée.');
end;

procedure TMainForm.LoadBtnClick(Sender: TObject);
begin
 if OpenDlg.Execute then
  begin
   CurrentFile := OpenDlg.FileName;
   Textures.LoadPackage(CurrentFile);
   DrawTextures;
  end;
end;

procedure TMainForm.SaveBtnClick(Sender: TObject);
begin
 if CurrentFile = '' then
  raise Exception.Create('Aucun paquet chargé.');
 Textures.SavePackage(CurrentFile);
 DrawTextures;
end;

procedure TMainForm.ExportBtnClick(Sender: TObject);
Var
 Bmp: TBitmap;
 T: TTexture;
begin
 if (List.ItemIndex = -1) and (CurrentFile = '') then
  raise Exception.Create('Aucune texture sélectionnée.');
 Bmp := TBitmap.Create;
 T := TTexture.Create;
 if SaveDlg.Execute then
  begin
   Textures.ReadTexture(List.ItemIndex, T);
   Bmp.Assign(T.Texture);
   Bmp.SaveToFile(SaveDlg.FileName);
  end;
 T.Free;
 Bmp.Free;
end;

procedure TMainForm.ImportBtnClick(Sender: TObject);
begin
 if (CurrentFile <> '') then ImportForm.ShowModal
  else
 raise Exception.Create('Aucun paquet chargé.');
end;

procedure TMainForm.ListPopupPopup(Sender: TObject);
begin
 SaveMenu.Enabled := (CurrentFile <> '');
 ExportMenu.Enabled := (CurrentFile <> '') and (List.ItemIndex <> -1);
 DeleteMenu.Enabled := (CurrentFile <> '') and (List.ItemIndex <> -1);
 ImportMenu.Enabled := (CurrentFile <> '');
 OptionsMenu.Enabled := (CurrentFile <> '');
end;

procedure TMainForm.ViewColorClick(Sender: TObject);
begin
 ColorDlg.Color := List.Color;
 if ColorDlg.Execute then
  begin
   List.Color := ColorDlg.Color;
   List.Font.Color := rgb(
    255 - GetRValue(List.Color),
    255 - GetGValue(List.Color),
    255 - GetBValue(List.Color));
  end;
end;

end.
