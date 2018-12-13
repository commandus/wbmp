program i2wbmp;
(*##*)
(***************************************************************************
*                                                                         *
*   i  2  w  b  m  p                                                       *
*                                                                         *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                   *
*   wbmp image convertor console win32 application                        *
*   Conditional defines:                                                   *
*                                                                         *
*   Registry:                                                              *
*   HKEY_LOCAL_MACHINE\Software\ensen\i2wbmp\1.0\                         *
*     DefDitherMode, as dither parameter, default 'nearest'                *
*                                                                         *
*                                                                          *
*     \Virtual Roots - contains aliases in addition ti IIS (PWS)          *
*   Usage                                                                  *
*   i2wbmp [-?][-r][-m DitherMode][-o Path][-v] File(s)|FileMask|Directory*
*      FileMask - file name or mask                                        *
*      Path - output folder path                                          *
*      Options:                                                            *
*        ? - this screen                                                  *
*        r - recurse subfolders                                            *
*        o - output folder path                                           *
*        v - verbose output                                                *
*        c - send to output (do not store output files)                   *
*        m - dithering mode:                                               *
*          Nearest|FloydSteinberg|Stucki|Sierra|JaJuNI|SteveArche|Burkes  *
*          default nearest                                                 *
*        g - get command line options from QUERY_STRING environment var   *
*        p - get command line options from input                           *
*        h - create HTTP header                                           *
*        d - skip default settings (don''t load i2wbmp.ini)                *
*        8 - no 8 bit align                                               *
*        s - print output to console                                       *
*        n - invert image (negative)                                      *
*                                                                          *
*                                                                         *
*   Configuration file i2wbmp.ini can keep defaults.                       *
*   Revisions    : Apr 15 2002                                            *
*   Last fix     : Apr 17 2002                                             *
*   Lines        : 59                                                     *
*   History      :                                                         *
*   Printed      : ---                                                    *
*                                                                          *
***************************************************************************)
(*##*)

{$APPTYPE CONSOLE}

uses
  SysUtils, Types, Classes, Registry, Windows, Secure,
  cmdcvrt in 'cmdcvrt.pas';

{ TODO -oUser -cConsole Main : Insert code here }

function IsRegistered: Boolean;
const
  CVRTRGPATH = 'Software\ensen\cvrt2wbmp\1.0';
var
  S, u, c: String;
  rg: TRegistry;
begin
  rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_LOCAL_MACHINE;
  // calculate hash
  Rg.OpenKeyReadOnly(CVRTRGPATH);
  u:= rg.ReadString('Name');
  c:= rg.ReadString('Code');
  S:= 'enzi' + 'cvrt2wbmp' + u;
  Result:= c = secure.GetMD5Digest(PChar(S), Length(S), 36);
  rg.Free;
end;

begin
  DoCmd(IsRegistered);
end.
