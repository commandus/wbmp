unit wbmputil;
(*##*)
(*******************************************************************
*                                                                  *
*   W  B  M  P  U  T  I  L                                        *
*   utility fucntions WBMP, part of CVRT2WBMP                      *
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

uses
  Windows, Controls, Classes, Graphics,
  util1;

function GetStringsFromGraphicFilter(const AFilter: String; AStyle: Integer; AResult: TStrings): Boolean;
function CenterX(AX: Integer; AControl: TControl): Integer;
function AdsText(AWidth, AHeight: Integer; AText: String; APicture: TPicture): Boolean;

implementation

function GetStringsFromGraphicFilter(const AFilter: String; AStyle: Integer; AResult: TStrings): Boolean;
var
  F, S, SPrev, ext: String;
  cnt, p: Integer;
begin
  Result:= True;
  AResult.Clear;
  F:= AFilter;
  cnt:= 0;
  SPrev:= '';
  case AStyle of
  0:begin
      //
      repeat
        Inc(cnt);
        S:= GetToken(cnt, '|', F);
        if Length(S) = 0
        then Break;
        if Odd(cnt)
        then AResult.Add(S);
        SPrev:= S;
      until False;
    end;
  1:begin
      //
      repeat
        Inc(cnt);
        S:= GetToken(cnt, '|', F);
        if Length(S) = 0
        then Break;
        if not Odd(cnt) then begin
          // parse list of extensions
          p:= 0;
          repeat
            Inc(p);
            Ext:= GetToken(p, ';', S);
            if Length(Ext) = 0
            then Break;
            if Ext[1] = '*'
            then Delete(Ext, 1, 1);
            // if AResult.IndexOf(Ext) < 0 then
            AResult.AddObject(Ext, TObject(cnt div 2));
          until False;
        end;
      until False;
    end;
  2:begin
      //
      p:= Pos('(', F);
      if p <=0
      then Exit;
      Delete(F, 1, p);
      p:= Pos(')', F);
      if p <=0
      then Exit;
      Delete(F, p, MaxInt);
      repeat
        Inc(cnt);
        S:= GetToken(cnt, '|', F);
        if Length(S) = 0
        then Break;
          // parse list of extensions
          p:= 0;
          repeat
            Inc(p);
            Ext:= GetToken(p, ';', S);
            if Length(Ext) = 0
            then Break;
            if Ext[1] = '*'
            then Delete(Ext, 1, 1);
            AResult.Add(Ext);
          until False;
      until False;
    end;
  end;
end;

function CenterX(AX: Integer; AControl: TControl): Integer;
begin
  Result:= (AX - AControl.Width) div 2;
  AControl.Left:= Result;
end;

function AdsText(AWidth, AHeight: Integer; AText: String; APicture: TPicture): Boolean;
var
  R: TRect;
  Sz: TSize;
  bmp: TBitmap;
begin
  Result:= True;
  bmp:= TBitmap.Create;
  R.Left:= 0;
  R.Top:= 0;
  R.Right:= AWidth - 1;
  R.Bottom:= AHeight - 1;

  bmp.Width:= AWidth;
  bmp.Height:= AHeight;

  with bmp.Canvas do begin
    Brush.Color:= clWhite;
    Brush.Style:= bsSolid;
    Pen.Color:= clBlack;
    Rectangle(R);
    Font.Name:= 'Times';
    Font.Color:= clSilver;
    Font.Size:= 20;
    Font.Style:= [fsBold];
    Sz:= TextExtent(AText);
    TextOut((AWidth - Sz.cx) div 2, (AHeight - Sz.cy) div 2, AText);
  end;
  APicture.Bitmap.Assign(bmp);
  bmp.Free;
end;

end.
