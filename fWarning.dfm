object FormWarning: TFormWarning
  Left = 70
  Top = 41
  BorderStyle = bsDialog
  ClientHeight = 214
  ClientWidth = 313
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object BRegister: TButton
    Left = 79
    Top = 180
    Width = 75
    Height = 25
    Caption = '&Register'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object BCancel: TButton
    Left = 159
    Top = 180
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object MemoMessage: TMemo
    Left = 8
    Top = 8
    Width = 297
    Height = 161
    ParentColor = True
    TabOrder = 2
  end
end
