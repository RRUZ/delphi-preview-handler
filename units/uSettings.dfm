object FrmSettings: TFrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 172
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 22
    Height = 13
    Caption = 'Font'
  end
  object Label2: TLabel
    Left = 159
    Top = 8
    Width = 19
    Height = 13
    Caption = 'Size'
  end
  object Label3: TLabel
    Left = 8
    Top = 64
    Width = 50
    Height = 13
    Caption = 'VCL Styles'
  end
  object Label4: TLabel
    Left = 215
    Top = 8
    Width = 110
    Height = 13
    Caption = 'Default Selection Mode'
  end
  object Label5: TLabel
    Left = 215
    Top = 64
    Width = 112
    Height = 13
    Caption = 'Syntax highlight Theme'
  end
  object CbFont: TComboBox
    Left = 8
    Top = 27
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 0
  end
  object EditFontSize: TEdit
    Left = 159
    Top = 27
    Width = 34
    Height = 21
    Alignment = taRightJustify
    Enabled = False
    NumbersOnly = True
    TabOrder = 1
    Text = '10'
  end
  object UpDown1: TUpDown
    Left = 193
    Top = 27
    Width = 16
    Height = 21
    Associate = EditFontSize
    Min = 8
    Max = 30
    Position = 10
    TabOrder = 2
  end
  object CbVCLStyles: TComboBox
    Left = 8
    Top = 83
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 3
  end
  object CbSelectionMode: TComboBox
    Left = 215
    Top = 27
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 4
  end
  object ButtonSave: TButton
    Left = 8
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 5
    OnClick = ButtonSaveClick
  end
  object cbSyntaxTheme: TComboBox
    Left = 215
    Top = 83
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 6
  end
  object Button1: TButton
    Left = 89
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = Button1Click
  end
end
