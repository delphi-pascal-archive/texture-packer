object ImportForm: TImportForm
  Left = 198
  Top = 114
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Importer une texture'
  ClientHeight = 177
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 131
    Height = 13
    Caption = 'Emplacement de la texture :'
  end
  object Prev: TImage
    Left = 8
    Top = 40
    Width = 128
    Height = 128
  end
  object Name: TLabel
    Left = 144
    Top = 48
    Width = 89
    Height = 13
    Caption = 'Nom de la texture :'
  end
  object Label2: TLabel
    Left = 144
    Top = 72
    Width = 98
    Height = 13
    Caption = 'Auteur de la texture :'
  end
  object Label3: TLabel
    Left = 144
    Top = 128
    Width = 233
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'Le bouton "Paint" permet d'#39'ouvrir l'#39#233'diteur d'#39'images de Microsof' +
      't avec la texture s'#233'lectionn'#233'e.'
    WordWrap = True
  end
  object NoTexLbl: TLabel
    Left = 8
    Top = 40
    Width = 128
    Height = 128
    Alignment = taCenter
    AutoSize = False
    Caption = 'Pas de texture s'#233'lectionn'#233'e'
    Layout = tlCenter
    WordWrap = True
  end
  object NoTexShp: TShape
    Left = 8
    Top = 40
    Width = 128
    Height = 128
    Brush.Style = bsClear
    Pen.Width = 2
  end
  object DirEdit: TEdit
    Left = 142
    Top = 6
    Width = 156
    Height = 21
    ReadOnly = True
    TabOrder = 0
  end
  object BrowseBtn: TButton
    Left = 304
    Top = 4
    Width = 75
    Height = 25
    Caption = 'Parcourir'
    TabOrder = 1
    OnClick = BrowseBtnClick
  end
  object NameEdit: TEdit
    Left = 235
    Top = 45
    Width = 142
    Height = 21
    TabOrder = 2
  end
  object AuthorEdit: TEdit
    Left = 246
    Top = 69
    Width = 131
    Height = 21
    TabOrder = 3
  end
  object ImportBtn: TButton
    Left = 144
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Importer'
    TabOrder = 4
    OnClick = ImportBtnClick
  end
  object CancelBtn: TButton
    Left = 304
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Annuler'
    TabOrder = 5
    OnClick = CancelBtnClick
  end
  object PaintBtn: TButton
    Left = 224
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Paint'
    TabOrder = 6
    OnClick = PaintBtnClick
  end
  object OpenPicDlg: TOpenPictureDialog
    DefaultExt = 'bmp'
    Filter = 
      'Tous les formats disponibles|*.bmp*;*.jpg*|Bitmaps (.bmp)|*.bmp*' +
      '|Images JPEG (.jpg)|*.jpg*'
    Title = 'Importer une texture'
    Left = 16
    Top = 48
  end
end
