unit asciipic;

interface

uses
  Windows, Graphics, GifImage;

const
  GrayScaleChars1: String[16] = ' .,-=:;/+%$XH@M#';
  GrayScaleChars2: String[16] = ' .+%$2YODAUQ#HNM';

function Bitmap2ASCII(ABitmap: TBitmap; const AChars: String): String;

implementation

function Bitmap2ASCII(ABitmap: TBitmap; const AChars: String): String;
type
  BA = array[0..1] of Byte;
  LogPal = record
    lpal: TLogPalette;
    dummy: packed array[1..255] of TPaletteEntry;
  end;
var
  SysPal: LogPal;
  Bitmap: TBitmap;
  i, x, y, len: Integer;
  Pattern: array[0..255] of Char;
begin
  Result:= '';
  len:= Length(AChars);
  if len <=0
  then Exit;
  len:= 256 div len; // chars per 1 scale

  with SysPal.lPal do begin
    palVersion:= $300;
    palNumEntries:= 256;
    for i:= 0 to 255 do with palPalEntry[i] do begin
      peRed:= i;
      peGreen:= i;
      peBlue:= i;
      peFlags:= PC_NOCOLLAPSE;
    end;
  end;

  Bitmap:= TBitmap.Create;
  Bitmap.Assign(ABitmap);
  Bitmap:= ReduceColors(Bitmap, rmPalette, dmNearest, 8, CreatePalette(SysPal.lpal));
  with Bitmap do begin
    HandleType:= bmDIB;
    PixelFormat:= pf8bit;
    Palette:= CreatePalette(SysPal.lpal);
  end;
  // create pattern
  for i:= 0 to 255 do begin
    Pattern[255-i]:= AChars[i div len + 1];
  end;

  // fill result string
  for y:= 0 to Bitmap.Height - 1 do begin
    for x:= 0 to Bitmap.Width - 1 do begin
      Result:= Result + Pattern[BA(Bitmap.ScanLine[y]^)[x]];
    end;
    Result:= Result + #13#10;
  end;

  Bitmap.Free;
end;

end.
