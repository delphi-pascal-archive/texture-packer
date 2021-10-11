{ TEXTUREPKG

Description : Unité permettant le stockage et l'enregistrement d'une liste de textures, de taille inférieure ou égale à 128px/128px.
Auteur : Bacterius
Prérequis : Unités Contnrs et Texture
Remerciements : Toute la communauté CS, et plus particulièrement f0xi pour ses TFileItem et TFileHeader.
Fonctions additionnelles :
 => Fournit un système de débogage par console Windows avancé.
 => Gère la majorité des erreurs silencieusement.

}

unit TexturePkg;

interface
                                                                        // Objet de FTextures
uses Windows, SysUtils, Classes, Graphics, Contnrs, Controls, Messages, Texture, Dialogs;

const
 MAXBMPWIDTH=128;    // Le maximum théorique pour une image par ce procédé est 584px sur 584px
 MAXBMPHEIGHT=128;

type
  TRGBPixel=record
   R, G, B: Byte;  // Contenu d'un pixel de l'image
  end;

  TRGBTriple=array [0..2] of Byte;  // Contenu d'un pixel de bitmap (utilisé par ScanLine)

  TRGBArray = array [0..MAXBMPWIDTH] of TRGBTriple;  // Tableau pour ScanLine
  pTRGBArray = ^TRGBArray;

type
  TFileHeader = record  // Contenu de la tête du fichier
    PkgName : ShortString;  // Nom du paquet
    PkgDescription : ShortString;  // Description du paquet
    PkgVersion : ShortString;  // Version du paquet
    PkgAuthor : ShortString;  // Auteur du paquet
    ItemCount : Integer;   // Nombre d'objets dans le paquet
  end;
  pFileHeader = ^TFileHeader;  // Référence à l'objet TFileHeader

const
  FileHeaderSize = SizeOf(TFileHeader); // Taille de TFileHeader

type
  TFileItem = record  // Un objet du fichier (contient l'information d'une texture (texture + nom et auteur)
    Bitmap: array [0..MAXBMPWIDTH, 0..MAXBMPHEIGHT] of TRGBPixel; // Le tableau qui contient les pixels du bitmap
    BmpWidth, BmpHeight: Integer; // Taille réelle du bitmap
    FNom: ShortString;
    FAuteur: ShortString;
  end;
  pFileItem = ^TFileItem;  // Référence à TFileItem

const
  FileItemSize = SizeOf(TFileItem);  // Taille de TFileItem

type
  TTexturePkg=class(TObject)
  // Contenu de TTexturePkg
  private
  // Privé
  FTextures: TObjectList;
  FPkgName: String;
  FPkgDescription: String;
  FPkgVersion: String;
  FPkgAuthor: String;
  FIn, FOut, FErr: HWND; // Handles de console
  FConsole: Boolean; // Si la console est activée
  // Fonctions de conversion Bitmap => Tableau de pixels et vice-versa
  function BitmapToPixels(var Bmp: TBitmap; var FileItemStructure: TFileItem): Boolean;
  function PixelsToBitmap(var Bmp: TBitmap; var FileItemStructure: TFileItem): Boolean;
  // Getters-Setters
  function GetPackageName: String;
  function GetPackageDescription: String;
  function GetPackageSize: Int64;
  function GetPackageVersion: String;
  function GetPackageAuthor: String;
  procedure SetPackageName(Name: String);
  procedure SetPackageDescription(Description: String);
  procedure SetPackageVersion(Version: String);
  procedure SetPackageAuthor(Author: String);
  public
  // Public
  constructor Create; overload; // Création de TexturePkg
  destructor Destroy; override; // Destruction de TexturePkg
  procedure NewPackage(PkgName, PkgDescription, PkgVersion, PkgAuthor: String); // Créer un nouveau paquet
  function LoadPackage(AFileName: String): Boolean; // Charger un paquet
  function SavePackage(AFileName: String): Boolean; // Enregistrer un paquet
  function ReadTexture(Index: Int64; var Texture: TTexture): Boolean; // Extraction d'une texture
  function WriteTexture(var Texture: TTexture): Boolean;  // Ecriture d'une texture
  function ExchangeTextures(Index1, Index2: Int64): Boolean;  // "Swap" de deux textures
  function DeleteTexture(Texture: TTexture): Boolean; overload; // Supprimer une texture à l'aide des informations de la texture
  function DeleteTexture(Index: Int64): Boolean; overload; // Supprimer une texture à l'aide de son index
  function SetConsoleHandles(ConsoleTitle: String): Boolean; // Définit les handles console
  function WriteInConsole(AText: String): Boolean; // Ecrit dans la console
  function IndexOf(Texture: TTexture): Int64; // Renvoie la position d'un objet précis Texture
  property PackageName: String read GetPackageName write SetPackageName; // Propriété nom du paquet
  property PackageDescription: String read GetPackageDescription write SetPackageDescription; // Propriété description du paquet
  property PackageVersion: String read GetPackageVersion write SetPackageVersion; // Propriété version du paquet
  property PackageAuthor: String read GetPackageAuthor write SetPackageAuthor; // Propriété auteur du paquet
  property PackageCount: Int64 read GetPackageSize; // Propriété nombre de textures
  property Package: TObjectList read FTextures write FTextures;  // Accès direct au TObjectList (à voir)
 end;

implementation

function AllocConsole: HWND; stdcall; external 'kernel32.dll';
function FreeConsole: HWND; stdcall; external 'kernel32.dll';
function GetStdHandle(nStdHandle: HWND): HWND; stdcall; external 'kernel32.dll';
function SetConsoleTitle(const lpConsoleTitle: String): HWND; stdcall; external 'kernel32.dll' name 'SetConsoleTitleA';
function WriteConsole(var hConsoleOutput: HWND;
                      lpBuffer: Variant;
                      nNumberOfCharsToWrite: LongWord;
                      lpNumberOfCharsWritten: LongWord;
                      lpReserved: Variant): LongWord
                      stdcall;
                      external 'kernel32.dll' name 'WriteConsoleA';

function TTexturePkg.SetConsoleHandles(ConsoleTitle: String): Boolean;
begin
 Result := True;
 FConsole := True;
 try
 AllocConsole;
 SetConsoleTitle(ConsoleTitle);

 FIn := GetStdHandle(STD_INPUT_HANDLE);
 FOut := GetStdHandle(STD_OUTPUT_HANDLE);  // On crée la console de débogage
 FErr := GetStdHandle(STD_ERROR_HANDLE);
 FConsole := True;
 except
  Result := False;
  FConsole := False;
 end;
end;

function TTexturePkg.WriteInConsole(AText: String): Boolean;
begin
 Result := True;
 if FConsole then
  try
   WriteLn(AText); // Et on réécrit (obligatoire, va savoir pourquoi ...)
  except
   Result := False;
  end;
end;

constructor TTexturePkg.Create;
begin
 inherited Create;  // Création du paquet et de FTextures
 FTextures := TObjectList.Create;
end;

destructor TTexturePkg.Destroy;
begin
 WriteInConsole('Preparation a la destruction du paquet de textures ...');
 FTextures.Free;  // Destruction de FTextures et destruction du paquet
 WriteInConsole('Paquet de textures detruit.');
 WriteInConsole('Destruction de l''objet.');
 WriteInConsole('end.');
 inherited Destroy;
end;

procedure TTexturePkg.NewPackage(PkgName, PkgDescription, PkgVersion, PkgAuthor: String);
begin
 WriteInConsole('Preparation a la creation d''un nouveau paquet ...');
 WriteInConsole('Suppression des textures');
 FTextures.Clear;   // Nouveau paquet, on vide les bitmaps et on remplace les champs
 WriteInConsole('Textures supprimees.');
 FPkgName := PkgName;
 FPkgDescription := PkgDescription;
 FPkgVersion := PkgVersion;
 FPkgAuthor := PkgAuthor;
 WriteInConsole('Informations du paquet ecrites.');
end;

function TTexturePkg.LoadPackage(AFileName: String): Boolean; // Ouverture d'un paquet
var
  FileHeader : TFileHeader;
  FileItem   : TFileItem;
  N          : integer;
  S: TFileStream;
  T: TTexture;
  Bmp: TBitmap;
begin
  WriteInConsole('Ouverture du paquet : "' + AFileName + '" ...');
  WriteInConsole('Creation du flux fichier du paquet ...');
  S := TFileStream.Create(AFileName, FMOPENREADWRITE); // Création du stream fichier du paquet
  WriteInConsole('Flux fichier de paquet cree.');
  WriteInConsole('Lecture du FileHeader ...');
  S.ReadBuffer(FileHeader, FileHeaderSize); // Lecture du header
  WriteInConsole('FileHeader lu.');
  WriteInConsole('Creation d''un nouveau paquet ...');
  NewPackage(FileHeader.PkgName, FileHeader.PkgDescription, FileHeader.PkgVersion, FileHeader.PkgAuthor);
  WriteInConsole('Nouveau paquet cree.');
  // Nouveau paquet avec les infos du header
  WriteInConsole('Creation du bitmap tampon ...');
  Bmp := TBitmap.Create;  // Création du bitmap tampon
  WriteInConsole('Bitmap tampon cree.');
  WriteInConsole('Preparation a la lecture des FileItems ...');
  for N := 0 to FileHeader.ItemCount do  // Pour chaque texture du paquet
  begin
    WriteInConsole('FileItem n°' + IntToStr(N) + '.');
    WriteInConsole('Lecture du FileItem ...');
    S.ReadBuffer(FileItem, FileItemSize); // Lecture de chaque FileItem de la texture
    WriteInConsole('FileItem lu.');
    WriteInConsole('Creation de la texture ...');
    T := TTexture.Create; // Création d'une texture
    WriteInConsole('Texture creee.');
    T.Nom := FileItem.FNom;
    T.Auteur := FileItem.FAuteur; // Attribution de FileItem à T
    WriteInConsole('Definition du nom et de l''auteur de la texture.');
    WriteInConsole('Preparation a la transformation du byte array en bitmap ...');
    PixelsToBitmap(Bmp, FileItem); // Transformation du byte array en bitmap et attribution du bitmap
    WriteInConsole('Transformation effectuee.');
    WriteInConsole('Definition du bitmap de la texture ...');
    T.Texture.Assign(Bmp); // Placement du bitmap frais dans la texture
    WriteInConsole('Bitmap de la texture defini.');
    WriteInConsole('Ecriture de la texture dans le paquet ...');
    WriteTexture(T);  // Ecriture de la texture dans le nouveau paquet
    WriteInConsole('Texture ecrite dans le paquet.');
  end;
  WriteInConsole('Liberation des objets ...');
  Bmp.Free;
  S.Free;   // Libération du bitmap tampon, du stream fichier
  WriteInConsole('Objets liberes.');
  WriteInConsole('Nettoyage du paquet ...');
  FTextures.Pack;  // Nettoyage du paquet
  WriteInConsole('Nettoyage effectue.');
  Result := True;
end;

function TTexturePkg.SavePackage(AFileName: String): Boolean; // Enregistrement d'un paquet
var
  FileHeader : TFileHeader;
  FileItem   : TFileItem;
  N          : integer;
  S: TFileStream;
  Bmp: TBitmap;
  T: TTexture;
begin
  WriteInConsole('Sauvegarde du paquet : "' + AFileName + '".');
  WriteInConsole('Creation du bitmap tampon ...');
  Bmp := TBitmap.Create;  // Création du bitmap tampon
  WriteInConsole('Bitmap tampon cree.');
  WriteInConsole('Creation du flux de fichier ...');
  S := TFileStream.Create(AFileName, FMCREATE); // Création du stream fichier
  WriteInConsole('Flux de fichier cree.');
  FileHeader.ItemCount := FTextures.Count - 1;
  FileHeader.PkgName := FPkgName;
  FileHeader.PkgDescription := FPkgDescription;  // Ecriture du FileHeader
  FileHeader.PkgVersion := FPkgVersion;
  FIleHeader.PkgAuthor := FPkgAuthor;
  WriteInConsole('Definition du FileHeader.');
  WriteInConsole('Ecriture du FileHeader ...');
  S.WriteBuffer(FileHeader, FileHeaderSize); // Enregistrement du FileHeader
  WriteInConsole('FileHeader ecrit.');
  WriteInConsole('Creation de la texture tampon.');
  T := TTexture.Create; // Texture temporaire
  WriteInConsole('Preparation a l''ecriture des textures.');
  for N := 0 to FTextures.Count - 1 do  // Pour chaque texture du paquet
  begin
    WriteInConsole('Ecriture de la texture n°' + IntToStr(N) + ' dans le flux.');
    WriteInConsole('Recuperation de la texture.');
    ReadTexture(N, T); // On lit la texture appropriée
    WriteInConsole('Definition du FileItem ...');
    FileItem.FNom := T.Nom;
    FileItem.FAuteur := T.Auteur;  // On crée un FileItem avec la texture
    Bmp.Assign(TTexture(FTextures.Items[N]).Texture);
    FileItem.BmpWidth := Bmp.Width;
    FileItem.BmpHeight := Bmp.Height; // On définit la taille du bitmap
    WriteInConsole('FileItem defini.');
    WriteInConsole('Transformation du bitmap de la texture en byte array ...');
    BitmapToPixels(Bmp, FileItem); // Transformation du bitmap de la texture en byte array
    WriteInConsole('Transformation effectuee.');
    WriteInConsole('Ecriture de la texture dans le flux ...');
    S.WriteBuffer(FileItem, FileItemSize); // Ecriture du FileItem
    WriteInConsole('Texture ecrite dans le flux.');
  end;
 Bmp.Free;
 S.Free;  // Libération du stream fichier et du bitmap tampon
 FTextures.Pack; // Nettoyage du paquet
 T.Free; // On enleve la texture temporaire
 Result := True;
end;

function TTexturePkg.BitmapToPixels(var Bmp: TBitmap; var FileItemStructure: TFileItem): Boolean;
Var      // Conversion bitmap => Tableau de pixels
 Line: PTRGBARRAY;
 X, Y: Integer;
begin
 WriteInConsole('Conversion bitmap => byte array.');
 Result := True; // Tout va bien pour le moment
 try
 Bmp.PixelFormat := pf24Bit; // On met le bitmap au format 24 pixels pour une bonne lecture
 for X := 0 to Bmp.Height - 1 do  // Pour chaque ligne
  begin
   Line := Bmp.ScanLine[X]; // On scanne la ligne X
   for Y := 0 to Bmp.Width - 1 do   // Pour chaque pixel de la ligne X
    begin
     FileItemStructure.Bitmap[Y, X].R := Line[Y][0];
     FileItemStructure.Bitmap[Y, X].G := Line[Y][1]; // On remplit le byte array avec les couleurs du pixel
     FileItemStructure.Bitmap[Y, X].B := Line[Y][2];
    end;
  end;
 except
  Result := False; // Si erreur, on met à False
  WriteInConsole('Erreur.');
 end;
 WriteInConsole('Conversion terminee.');
end;

function TTexturePkg.PixelsToBitmap(var Bmp: TBitmap; var FileItemStructure: TFileItem): Boolean;
Var        // Conversion tableau de pixels => Bitmap
 Line: PTRGBARRAY;
 X, Y: Integer;
begin
 WriteInConsole('Conversion byte array => bitmap.');
 Result := True;
 try
 Bmp.Height := FileItemStructure.BmpHeight;
 Bmp.Width := FileItemStructure.BmpWidth;   // On définit la taille du bitmap
 Bmp.PixelFormat := pf24Bit;  // On met au format 24 pixels
 WriteInConsole('Preparation du bitmap ...');
 for X := 0 to Bmp.Height - 1 do  // Pour chaque ligne
  begin
   Line := Bmp.ScanLine[X]; // On scanne la ligne X
   for Y := 0 to Bmp.Width - 1 do // Pour chaque pixel de la ligne X
    begin
     Line[Y][0] := FileItemStructure.Bitmap[Y, X].R;
     Line[Y][1] := FileItemStructure.Bitmap[Y, X].G; // On convertit en couleur RGB le byte array
     Line[Y][2] := FileItemStructure.Bitmap[Y, X].B;
    end;
  end;
 except
  Result := False; // Si erreur, on met à false
  WriteInConsole('Erreur.');
 end;
 WriteInConsole('Conversion terminee.');
end;

function TTexturePkg.GetPackageName: String;
begin
 Result := FPkgName;   // On récupère le nom du paquet
 WriteInConsole('Recuperation nom du paquet ("' + Result + '").');
end;

function TTexturePkg.GetPackageDescription: String;
begin
 Result := FPkgDescription;   // On récupère la description du paquet
 WriteInConsole('Recuperation description du paquet ("' + Result + '").');
end;

function TTexturePkg.GetPackageVersion: String;
begin
 Result := FPkgVersion; // On récupère la version du paquet
 WriteInConsole('Recuperation version du paquet ("' + Result + '").');
end;

function TTexturePkg.GetPackageAuthor: String;
begin
 Result := FPkgAuthor;  // On récupère l'auteur du paquet
 WriteInConsole('Recuperation auteur du paquet ("' + Result + '").');
end;

function TTexturePkg.GetPackageSize: Int64;
begin
 Result := FTextures.Count;  // On récupère le nombre d'objets dans le paquet
 WriteInConsole('Recuperation nombre de textures du paquet ("' + IntToStr(Result) + '").');
end;

procedure TTexturePkg.SetPackageName(Name: String);
begin
 FPkgName := Name; // On fixe le nom du paquet
 WriteInConsole('Definition nom du paquet ("' + Name + '").');
end;

procedure TTexturePkg.SetPackageDescription(Description: String);
begin
 FPkgDescription := Description; // On fixe la description du paquet
 WriteInConsole('Definition description du paquet ("' + Description + '").');
end;

procedure TTexturePkg.SetPackageVersion(Version: String);
begin
 FPkgVersion := Version; // On fixe la version du paquet
 WriteInConsole('Definition version du paquet ("' + Version + '").');
end;

procedure TTexturePkg.SetPackageAuthor(Author: String);
begin
 FPkgAuthor := Author; // On fixe l'auteur du paquet
 WriteInConsole('Definition auteur du paquet ("' + Author + '").');
end;

function TTexturePkg.ReadTexture(Index: Int64; var Texture: TTexture): Boolean;
begin              // On lit une texture
 WriteInConsole('Lecture d''une texture.');
 Result := True; // Tout s'est bien passé

 // On évite les erreurs débiles

 if not (FTextures.Items[Index] is TTexture) then // Si l'objet n'est pas un TTexture alors laisse tomber
  begin
   WriteInConsole('Erreur.');
   raise Exception.Create('L''objet n''est pas adapté à cette routine.');
   Exit;
  end;

 if (not Index in [0..FTextures.Count - 1]) then
  begin
   WriteInConsole('Erreur.');
   Exit;
  end; 

 try
  WriteInConsole('Lecture de la texture ...');
  Texture.Texture.Assign(TTexture(FTextures.Items[Index]).Texture);
  Texture.Nom := TTexture(FTextures.Items[Index]).Nom; // On définit Texture passé en paramètre
  Texture.Auteur := TTexture(FTextures.Items[Index]).Auteur;
  WriteInConsole('Texture lue.');
 except
  Result := False; // Si erreur, on met à False
  WriteInConsole('Erreur.');
 end;
end;

function TTexturePkg.WriteTexture(var Texture: TTexture): Boolean;
Var             // On écrit une texture
 T: TTexture;
 Bmp: TBitmap;
begin
 WriteInConsole('Ecriture d''une texture.');
 Result := True; // Tout s'est bien passé
 WriteInConsole('Creation du bitmap tampon.');
 Bmp := TBitmap.Create; // On crée le bitmap tampon
 try
  WriteInConsole('Ecriture de la texture ...');
  Bmp.Assign(Texture.Texture);
  T := TTexture.Create;
  T.Nom := Texture.Nom;
  T.Auteur := Texture.Auteur;
  T.Texture.Assign(Bmp);  // On écrit la texture
  FTextures.Add(T);
  WriteInConsole('Texture ecrite.');
  WriteInConsole('Nettoyage du paquet ...');
  FTextures.Pack; // On nettoie le paquet
  WriteInConsole('Nettoyage effectue.');
 except
  Result := False;  // Si erreur, on met False
  WriteInConsole('Erreur.');
 end;
  Bmp.Free; // De toute façon on libère le bitmap
  WriteInConsole('Liberation du bitmap tampon.');
end;

function TTexturePkg.ExchangeTextures(Index1, Index2: Int64): Boolean;
begin
 WriteInConsole('Echange de textures.');
 Result := True; // par défaut tout s'est bien passé
 try
  FTextures.Exchange(Index1, Index2);   // On échange deux textures de position
  FTextures.Pack; // On nettoie le paquet
  WriteInConsole('Textures echangees.');
 except
  Result := False; // Si erreur, on met False
  WriteInConsole('Erreur.');
 end;
end;

function TTexturePkg.DeleteTexture(Texture: TTexture): Boolean;
Var
 I: Integer;
begin
 WriteInConsole('Suppression de texture.');
 Result := True; // par défaut tout s'est bien passé
 try
  for I := 0 to FTextures.Count - 1 do // Pour chaque texture
   if TTexture(FTextures.Items[I]) = Texture then // Si la texture est la même alors ...
    begin
     FTextures.Delete(I);  // On supprime la texture !
     FTextures.Pack; // On nettoie le paquet
     Result := True;  // On met à True
    end;
 except
  Result := False; // Si erreur, on met False
  WriteInConsole('Erreur.');
 end;
 WriteInConsole('Texture supprimee.');
end;

function TTexturePkg.DeleteTexture(Index: Int64): Boolean;
begin
 WriteInConsole('Suppression de texture.');
 Result := True; // par défaut tout s'est bien passé
 try
  FTextures.Delete(Index);  // On supprime une texture !
  FTextures.Pack; // On nettoie le paquet
 except
  Result := False; // Si erreur, on met False
  WriteInConsole('Erreur.');
 end;
 WriteInConsole('Texture supprimee.');
end;

function TTexturePkg.IndexOf(Texture: TTexture): Int64;
Var                // On cherche l'index d'une texture
 I: Integer;
begin
 WriteInConsole('Recherche de l''index d''une texture.');
 Result := -1; // Si on ne trouve rien on retombera sur -1
 try
  for I := 0 to FTextures.Count - 1 do   // Pour chaque texture du paquet
   if TTexture(FTextures.Items[I]) = Texture then
    begin
     Result := I; // Si c'est la même texture alors on donne cet index au résultat ...
     Exit; // ... et on s'en va (ce qui fait que l'on tombe sur la première texture identique sans tenir compte des autres)
    end;
 except
  Result := -1; // Si une erreur, alors résultat négatif
  WriteInConsole('Erreur.');
 end;
 WriteInConsole('Index trouve (' + IntToStr(Result) + ').');
end;

end.
