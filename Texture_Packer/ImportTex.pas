unit ImportTex;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Texture, StdCtrls, ExtCtrls, ExtDlgs, JPEG;

type
  TImportForm = class(TForm)
    Label1: TLabel;
    DirEdit: TEdit;
    BrowseBtn: TButton;
    Prev: TImage;
    Name: TLabel;
    NameEdit: TEdit;
    Label2: TLabel;
    AuthorEdit: TEdit;
    ImportBtn: TButton;
    CancelBtn: TButton;
    OpenPicDlg: TOpenPictureDialog;
    Label3: TLabel;
    PaintBtn: TButton;
    NoTexLbl: TLabel;
    NoTexShp: TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
    procedure PaintBtnClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    procedure LoadPic;
  end;

var
  ImportForm: TImportForm;

implementation

uses Main;

{$R *.dfm}

procedure TImportForm.FormCreate(Sender: TObject);
begin
 DoubleBuffered := True;
end;

procedure TImportForm.FormShow(Sender: TObject);
begin
 Prev.Picture := nil;
 DirEdit.Text := '';
 NameEdit.Text := '';
 AuthorEdit.Text := '';
 NoTexLbl.Visible := True;
 NoTexShp.Visible := True;
 LoadPic;
end;

procedure TImportForm.LoadPic;
Var
 Bmp: TBitmap;
 JPG: TJpegImage;
begin
 if OpenPicDlg.Execute then
  begin
   Bmp := TBitmap.Create;
   JPG := TJpegImage.Create;
   if ExtractFileExt(OpenPicDlg.FileName) = '.bmp' then Bmp.LoadFromFile(OpenPicDlg.FileName);
   if ExtractFileExt(OpenPicDlg.FileName) = '.jpg' then
    begin
     JPG.LoadFromFile(OpenPicDlg.FileName);
     JPG.CompressionQuality := 100;
     Bmp.Assign(JPG);
    end;
   Prev.Picture.Bitmap.Assign(Bmp);
   DirEdit.Text := OpenPicDlg.FileName;
   Bmp.Free;
   JPG.Free;
   NoTexLbl.Visible := False;
   NoTexShp.Visible := False;
  end
   else
    begin
     NoTexLbl.Visible := True;
     NoTexShp.Visible := True;
     DirEdit.Text := '';
    end;
end;

procedure TImportForm.BrowseBtnClick(Sender: TObject);
begin
 LoadPic;
end;

procedure TImportForm.CancelBtnClick(Sender: TObject);
begin
 Close;
end;

procedure TImportForm.ImportBtnClick(Sender: TObject);
Var
 T: TTexture;
 Bmp: TBitmap;
begin
 if DirEdit.Text = '' then
  raise Exception.Create('Veuillez spécifier une texture.');

 if NameEdit.Text = '' then
  raise Exception.Create('Veuillez spécifier un nom pour la texture.');
 if AuthorEdit.Text = '' then
  if MessageDlg('Vous n''avez pas spécifié d''auteur pour la texture. Continuer ?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then Exit;
 Bmp := TBitmap.Create;
 Bmp.Assign(Prev.Picture.Bitmap);
 T := TTexture.Create;
 T.Texture.Assign(Bmp);
 T.Texture.Width := 128;
 T.Texture.Height := 128;
 T.Nom := NameEdit.Text;
 T.Auteur := AuthorEdit.Text;
 Textures.WriteTexture(T);
 Bmp.Free;
 Textures.SavePackage(CurrentFile);
 MainForm.DrawTextures;
 Close;
end;

procedure TImportForm.PaintBtnClick(Sender: TObject);
begin
 WinExec(PChar('mspaint "' + DirEdit.Text + '"'), SW_SHOWNORMAL);
end;

end.
