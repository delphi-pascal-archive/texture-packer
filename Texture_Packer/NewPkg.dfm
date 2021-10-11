object NewPkgForm: TNewPkgForm
  Left = 198
  Top = 114
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Nouveau paquet de textures'
  ClientHeight = 169
  ClientWidth = 297
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
    Width = 233
    Height = 13
    Caption = 'Cr'#233'ation d'#39'un nouveau paquet de textures vierge.'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 79
    Height = 13
    Caption = 'Nom du paquet :'
  end
  object Label3: TLabel
    Left = 8
    Top = 56
    Width = 110
    Height = 13
    Caption = 'Description du paquet :'
  end
  object Label4: TLabel
    Left = 8
    Top = 80
    Width = 92
    Height = 13
    Caption = 'Version du paquet :'
  end
  object Label5: TLabel
    Left = 8
    Top = 104
    Width = 88
    Height = 13
    Caption = 'Auteur du paquet :'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 128
    Width = 281
    Height = 2
  end
  object NomEdit: TEdit
    Left = 88
    Top = 30
    Width = 201
    Height = 21
    TabOrder = 0
  end
  object DescriptionEdit: TEdit
    Left = 120
    Top = 54
    Width = 169
    Height = 21
    TabOrder = 1
  end
  object VersionEdit: TEdit
    Left = 104
    Top = 78
    Width = 185
    Height = 21
    TabOrder = 2
  end
  object AuteurEdit: TEdit
    Left = 104
    Top = 102
    Width = 185
    Height = 21
    TabOrder = 3
  end
  object ApplyBtn: TButton
    Left = 8
    Top = 136
    Width = 185
    Height = 25
    Caption = 'Cr'#233'er le nouveau paquet'
    TabOrder = 4
    OnClick = ApplyBtnClick
  end
  object CancelBtn: TButton
    Left = 200
    Top = 136
    Width = 91
    Height = 25
    Caption = 'Annuler'
    TabOrder = 5
    OnClick = CancelBtnClick
  end
  object SaveDlg: TSaveDialog
    DefaultExt = 'ptx'
    Filter = 'Paquet de Textures (.ptx)|*.ptx*'
    Title = 'Emplacement du paquet de textures'
    Left = 8
    Top = 8
  end
end
