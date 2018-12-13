unit FRegister;
(*##*)
(*******************************************************************
*                                                                  *
*   F  R  E  G  I  S  T  E  R                                     *
*   register form of CVRT2WBMP, part of CVRT2WBMP                  *
*                                                                 *
*   Copyright (c) 2001 Andrei Ivanov. All rights reserved.         *
*                                                                 *
*   Conditional defines:                                           *
*                                                                 *
*   Last Revision: Jun 07 2001                                     *
*   Last fix     :                                                *
*   Lines        :                                                 *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, Registry, ExtCtrls;

type
  TFormRegister = class(TForm)
    BEnterCode: TButton;
    BCancel: TButton;
    Label3: TLabel;
    ERegCode: TEdit;
    MDesc: TMemo;
    BRegister: TButton;
    BDetails: TButton;
    LName: TLabel;
    EUserName: TEdit;
    EProduct: TEdit;
    Label1: TLabel;
    procedure BRegisterClick(Sender: TObject);
    procedure BDetailsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormRegister: TFormRegister;

implementation

{$R *.DFM}

uses
  util1, fmain;

procedure TFormRegister.BRegisterClick(Sender: TObject);
begin
  util1.EExecuteFile(REGISTER_URL);
end;

procedure TFormRegister.BDetailsClick(Sender: TObject);
begin
  util1.EExecuteFile(REGISTER_HOWTO_URL);
end;

procedure TFormRegister.FormCreate(Sender: TObject);
begin
  // EManufacturer.Text:= FParameters.Values[ParameterNames[ID_MANUFACTURER]];
  with FormMain.FParameters do begin
    // EProduct.Text:= IntToStr(REGISTER_REGSOFTPRODUCTCODE);
    EUserName.Text:= Values[ParameterNames[ID_USER]];
    ERegCode.Text:= Values[ParameterNames[ID_CODE]];
  end;
end;

end.
