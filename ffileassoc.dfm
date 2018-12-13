object FormFileAssociations: TFormFileAssociations
  Left = 461
  Top = 90
  BorderStyle = bsDialog
  Caption = 'File associations (shell integration)'
  ClientHeight = 170
  ClientWidth = 339
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object LFileTypes: TLabel
    Left = 8
    Top = 40
    Width = 44
    Height = 13
    Caption = 'File t&ypes'
  end
  object BOk: TButton
    Left = 247
    Top = 60
    Width = 75
    Height = 25
    Caption = 'O&k'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object BCancel: TButton
    Left = 247
    Top = 92
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object CheckListBoxFileTypes: TCheckListBox
    Left = 8
    Top = 56
    Width = 225
    Height = 105
    ItemHeight = 13
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 8
    Top = 4
    Width = 329
    Height = 33
    BorderStyle = bsNone
    Lines.Strings = (
      
        'From the list below, select the file types which you would like ' +
        'program '
      'to open when you double-click on then in Explorer.')
    ParentColor = True
    ReadOnly = True
    TabOrder = 3
  end
end
