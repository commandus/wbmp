unit ffileassoc;
(*##*)
(*******************************************************************
*                                                                  *
*   F  F  I  L  E  A  S  S  O  C                                 *
*   file associations form, part of CVRT2WBMP                      *
*                                                                 *
*   Copyright (c) 2001 Andrei Ivanov. All rights reserved.         *
*                                                                 *
*   Conditional defines:                                           *
*                                                                 *
*   Last Revision: Jun 26 2001                                     *
*   Last fix     :                                                *
*   Lines        :                                                 *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, CheckLst,
  utilwin, wbmputil;

type
  TFormFileAssociations = class(TForm)
    BOk: TButton;
    BCancel: TButton;
    CheckListBoxFileTypes: TCheckListBox;
    LFileTypes: TLabel;
    Memo1: TMemo;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFileAssociations: TFormFileAssociations;

implementation

{$R *.DFM}

uses
  fmain;
  
procedure TFormFileAssociations.FormActivate(Sender: TObject);
var
  R: TStrings;
  i, e: Integer;
  b: Boolean;
  FileDesc, FileIcon, CmdDesc, CmdProg, CmdParam, DdeApp, DDETopic, DDEItem: String;
begin
  R:= TStringList.Create;
  for i:= 0 to CheckListBoxFileTypes.Items.Count - 1 do begin
    R.Clear;
    GetStringsFromGraphicFilter(CheckListBoxFileTypes.Items[i], 2, R);
    b:= False;
    for e:= 0 to r.Count - 1 do begin
      b:= b or utilwin.IsFileExtAssociatesWithCmd(r[e], '2wbmp'+r[e], '2bmpView',
        FileDesc, FileIcon, CmdDesc, CmdProg, CmdParam, DdeApp, DDETopic, DDEItem);
    end;
    CheckListBoxFileTypes.Checked[i]:= b;
  end;
  R.Free;
end;

end.
