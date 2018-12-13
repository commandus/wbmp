program cvrt2wbmp;
(*##*)
(*******************************************************************
*                                                                  *
*   C  V  R  T  2  W  B  M  P                                     *
*   wireless bitmap convertor                                      *
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

uses
  Forms,
  fmain in 'fmain.pas' {FormMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'WBMP';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
