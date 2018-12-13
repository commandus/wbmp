unit fWarning;
(*##*)
(*******************************************************************
*                                                                  *
*   F  W  A  R  N  I  N  G                                        *
*   warning form of CVRT2WBMP, part of CVRT2WBMP                   *
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
  Buttons, ExtCtrls;

type
  TFormWarning = class(TForm)
    BRegister: TButton;
    BCancel: TButton;
    MemoMessage: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWarning: TFormWarning;

implementation

{$R *.DFM}


end.
