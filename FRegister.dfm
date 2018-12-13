object FormRegister: TFormRegister
  Left = 308
  Top = 109
  BorderStyle = bsDialog
  Caption = 'Register evaluation copy of cvrt2wbmp'
  ClientHeight = 364
  ClientWidth = 331
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 24
    Top = 224
    Width = 236
    Height = 13
    Hint = 'Cut and paste'
    Caption = 'Cut and paste registration &code from mail message'
    ParentShowHint = False
    ShowHint = True
  end
  object LName: TLabel
    Left = 24
    Top = 192
    Width = 112
    Height = 13
    Hint = 'Case sensitive'
    Caption = '&Your name/or Company'
    ParentShowHint = False
    ShowHint = True
  end
  object Label1: TLabel
    Left = 24
    Top = 160
    Width = 64
    Height = 13
    Caption = '&Product code'
  end
  object BEnterCode: TButton
    Left = 184
    Top = 308
    Width = 105
    Height = 25
    Action = FormMain.ActEnterCode
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object BCancel: TButton
    Left = 56
    Top = 308
    Width = 106
    Height = 25
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 3
  end
  object ERegCode: TEdit
    Left = 24
    Top = 248
    Width = 265
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object MDesc: TMemo
    Left = 16
    Top = 0
    Width = 281
    Height = 65
    BorderStyle = bsNone
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      ''
      'Please register at regsoft.net - just press a button.'
      'If you are having difficulty accessing web, please visit:'
      'www.regsoft.net/purchase.php3?productid=38958')
    ParentFont = False
    ReadOnly = True
    TabOrder = 6
  end
  object BRegister: TButton
    Left = 40
    Top = 84
    Width = 249
    Height = 25
    Action = FormMain.ActRegisterGoWeb
    Default = True
    TabOrder = 4
  end
  object BDetails: TButton
    Left = 40
    Top = 116
    Width = 249
    Height = 25
    Action = FormMain.ActHowToRegister
    Default = True
    TabOrder = 5
  end
  object EUserName: TEdit
    Left = 160
    Top = 184
    Width = 129
    Height = 21
    TabOrder = 0
  end
  object EProduct: TEdit
    Left = 160
    Top = 152
    Width = 129
    Height = 21
    Color = clInactiveBorder
    Enabled = False
    ReadOnly = True
    TabOrder = 7
    Text = 'cvrt2wbmp'
  end
end
