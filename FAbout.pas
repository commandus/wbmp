unit Fabout;
(*##*)
(*******************************************************************
*                                                                 *
*   f  a  b  o  u  t                                               *
*                                                                 *
*   Copyright (c) 2001, A.Ivanov. All rights reserved.             *
*   Part of cvrt2wbmp.                                            *
*   Conditional defines:                                           *
*                                                                 *
*   Last Revision: Jun 25 2001                                     *
*   Last fix     :        2001                                    *
*   Lines        :  90                                             *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, jpeg;

type
  TAboutBox = class(TForm)
    ProgramIcon: TImage;
    Comments: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    BRegister: TButton;
    LRegistered: TLabel;
    MemoInfo: TMemo;
    procedure CommentsClick(Sender: TObject);
    procedure BRegisterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

uses
  FRegister, util1, fmain, versions;

procedure TAboutBox.CommentsClick(Sender: TObject);
begin
  util1.EExecuteFile((Sender as TLabel).Caption);
end;

procedure TAboutBox.BRegisterClick(Sender: TObject);
begin
  FormRegister:= TFormRegister.Create(Self);
  FormRegister.ShowModal;
  FormRegister.Free;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
var
  FOSVersionInfo: TOSVersionInfo;
begin
  FOSVersionInfo.dwOSVersionInfoSize:= SizeOf(FOSVersionInfo);
  GetVersionEx(FOSVersionInfo);
  with FOSVersionInfo do begin
    MemoInfo.Lines.Insert(0, 'http://wbmp.commandus.com/ mailto:support@commandus.com');
    MemoInfo.Lines.Insert(0, Format( '%s', [String(szCSDVersion)]));
    MemoInfo.Lines.Insert(0, Format( 'Windows v. %d.%d build %d',
      [dwMajorVersion, dwMinorVersion, dwBuildNumber]));
    MemoInfo.Lines.Insert(0, Versions.GetVersionInfo(LNG, 'LegalCopyright'));
    MemoInfo.Lines.Insert(0, Versions.GetVersionInfo(LNG, 'ProductName'));
  end;
  ProgramIcon.Hint:= 'Visit other my sites:'#13#10'http://wbmp.commandus.com/'+
    #13#10'http://wap.commandus.com/'#13#10'http://bloxy.commandus.com/'#13#10'http://freeware.commandus.com/';
  if FormMain.FRegistered then begin
    LRegistered.Caption:= Format('Licensed to %s', [FormMain.FParameters.Values[ParameterNames[ID_USER]]]);
    BRegister.Enabled:= False;
  end else begin
    LRegistered.Caption:= 'Unregistered copy';
    BRegister.Enabled:= True;
  end;
end;

end.

