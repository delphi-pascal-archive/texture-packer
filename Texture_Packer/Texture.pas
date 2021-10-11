// Classe TTexture qui permet d'ajouter un objet TTexture à un TexturePkg
// Contient une texture, un nom et un auteur.

unit Texture;

interface

uses Windows, SysUtils, Classes, Graphics, Contnrs, Controls, Messages, Dialogs;

type TTexture=class(TObject)
  public
  Texture: TBitmap;
  Nom: String;    // Texture, nom, auteur
  Auteur: String;
  constructor Create; overload;
  destructor Destroy; override;
 end;

implementation

constructor TTexture.Create;
begin
 inherited Create;     // A la création de l'objet, création du bitmap texture
 Texture := TBitmap.Create;
end;

destructor TTexture.Destroy;
begin
 Texture.Free;    // A la destruction de l'objet, destruction du bitmap texture
 inherited Destroy;
end;

end.
