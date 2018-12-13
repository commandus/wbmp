unit
  cmdcvrt;
(*##*)
(***************************************************************************
*                                                                         *
*   c  m  d  c  v  r  t                                                    *
*                                                                         *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                   *
*   wbmp image convertor console win32 main procedure                     *
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
*   Lines        : 697                                                    *
*   History      :                                                         *
*   Printed      : ---                                                    *
*                                                                          *
***************************************************************************)
(*##*)

interface

uses
  SysUtils, Types, Classes, Graphics, WBMPImage;

function DoCmd(AIsRegistered: Boolean): Boolean;


implementation

uses
  GIFImage, util1, wmleditutil;

type  
  TCvrtEnv = class(TObject)
  private
    IsRegistered: Boolean;
    DitherMode: TDitherMode;
    outputpath: String;
    send2output,
    recurse,
    verbose,
    getQUERY_STRING,
    getInput,
    createHTTPheader,
    SkipIni,
    Print2Console,
    NoAlign,
    Negative,
    showhelp: Boolean;

    filelist: TStrings;
  public
    Count: Integer;
    constructor Create(AIsRegistered: Boolean);
    destructor Destroy; override;
    procedure Clear;
  end;

const
  DEF_BITMAPEXTS = '.ico.bmp.dib.jpeg.jpg.gif.wmf.emf';
  DEF_HTTPHEADER: String = 'HTTP/1.0 200 Ok'#13#10 +
    'Content-Type: image/vnd.wap.wbmp'#13#10#13#10;

procedure RaiseError(ACode: Integer; ACodeS: String);
begin
  Writeln(output, #13#10'Error ', ACode, ': ', ACodeS);
  Halt(ACode);
end;

function PrintCopyright(AIsRegistered: Boolean): String;
const
  R: array[Boolean] of String = ('evaluation version', 'Registered version');
begin
  Result:=
    'i2wbmp, wbmp file convertor. Copyright (c) 2002 Andrei Ivanov.'#13#10 +
    R[AIsRegistered] + #13#10+
    '  Should you have any questions concerning this program, please contact:'#13#10+
    '  ensen_andy@yahoo.com. Type i2wbmp -h to get list of command line options.'#13#10;

end;

function PrintUsage: String;
begin
  Result:=
    'Usage: i2wbmp [-?][-r][-m DitherMode][-o Path][-v] File(s)|FileMask|Directory'#13#10 +
    '  FileMask - file name/directory or mask; Path - output folder path'#13#10 +
    '  Options:  ? - this screen'#13#10 +
    '    r - recurse subfolders'#13#10 +
    '    o - output folder path'#13#10 +
    '    v - verbose output'#13#10 +
    '    c - send to output (do not store output files)'#13#10 +
    '    m - dithering mode:'#13#10 +
    '      Nearest(default)|FloydSteinberg|Stucki|Sierra|JaJuNI|SteveArche|Burkes'#13#10+
    '    g - get command line options from QUERY_STRING environment variable'#13#10 +
    '    p - get command line options from input'#13#10 +
    '    h - create HTTP header'#13#10 +
    '    d - skip default settings (don''t load i2wbmp.ini)'#13#10 +
    '    s - print result image to console'#13#10 +
    '    n - invert image (negative)'#13#10 +
    '    8 - no 8 bit align'#13#10 +    
    '    i - reserved'#13#10 +
    'Configuration file i2wbmp.ini can keep defaults.';

end;

const
  DitherModeStr: array[TDitherMode] of String[15] =
    ('Nearest',			// Nearest color matching w/o error correction
     'FloydSteinberg',		// Floyd Steinberg Error Diffusion dithering
     'Stucki',			// Stucki Error Diffusion dithering
     'Sierra',			// Sierra Error Diffusion dithering
     'JaJuNI',			// Jarvis, Judice & Ninke Error Diffusion dithering
     'SteveArche',		// Stevenson & Arche Error Diffusion dithering
     'Burkes'			// Burkes Error Diffusion dithering
    );

function GetDitherModeByName(const S: String; ADefDitherMode: TDitherMode): TDitherMode;
begin
  Result:= ADefDitherMode;
  if CompareText(s, 'Nearest') = 0
  then Result:= dmNearest;  // Nearest color matching w/o error correction
  if CompareText(s, 'FloydSteinberg') = 0
  then Result:= dmFloydSteinberg; // Floyd Steinberg Error Diffusion dithering
  if CompareText(s, 'Stucki') = 0
  then Result:= dmStucki; // Stucki Error Diffusion dithering
  if CompareText(s, 'Sierra') = 0
  then Result:= dmSierra; // Sierra Error Diffusion dithering
  if CompareText(s, 'JaJuNI') = 0
  then Result:= dmJaJuNI; // Jarvis, Judice & Ninke Error Diffusion dithering
  if CompareText(s, 'SteveArche') = 0
  then Result:= dmSteveArche; // Stevenson & Arche Error Diffusion dithering
  if CompareText(s, 'Burkes') = 0
  then Result:= dmBurkes; // Stevenson & Arche Error Diffusion dithering
end;

function GetDitherModeName(ADitherMode: TDitherMode): String;
begin
  case ADitherMode of
  dmNearest:           // Nearest color matching w/o error correction
    Result:= 'Nearest';
  dmFloydSteinberg:    // Floyd Steinberg Error Diffusion dithering
    Result:= 'FloydSteinberg';
  dmStucki:            // Stucki Error Diffusion dithering
    Result:= 'Stucki';
  dmSierra:            // Sierra Error Diffusion dithering
    Result:= 'Sierra';
  dmJaJuNI:            // Jarvis, Judice & Ninke Error Diffusion dithering
    Result:= 'JaJuNI';
  dmSteveArche:        // Stevenson & Arche Error Diffusion dithering
    Result:= 'SteveArche';
  dmBurkes:            // Burkes Error Diffusion dithering
    Result:= 'Burkes';
  end; { case }
end;

const
  OptionsHasExt: TSysCharSet = ['m', 'o', 'M', 'O'];

function ParseCmd(const AConfig: String; AOptionsHasExt: TSysCharSet; Rslt: TStrings): String;
var
  S, os: String;
  o: Char;
  filecount, p, i, L: Integer;
  state: Integer;
  Quoted: Boolean;
begin
  Rslt.Clear;
  S:= AConfig;
  state:= 0;
  i:= 1;
  filecount:= 0;
  L:= Length(S);
  // skip program name
  while i <= L do begin
    if S[i] = #32 then begin
      Inc(i);
      Break;
    end;
    Inc(i);
  end;
  Result:= Copy(S, 1, i - 2);

  Quoted:= False;
  // parse
  while i <= L do begin
    o:= S[i];
    case o of
      '''', '"': begin
          Quoted:= not Quoted;
          Inc(i);
        end;
      '-': begin
          case state of
            0: state:= 1;  // option started
          end;
          Inc(i);
        end;
      #0..#32: begin
          state:= 0;
          Inc(i);
        end;
      else begin
        case state of
          0:begin  // file name or mask
              p:= i;
              if Quoted then begin
                repeat
                  Inc(i);
                until (i > L) or (S[i] in ['''', '"', #0]);
                Quoted:= False;
              end else begin
                repeat
                  Inc(i);
                until (i > L) or (S[i] in [#0..#32, '-']);
              end;
              os:= Copy(s, p, i - p);
              Inc(filecount);
              Rslt.AddObject('=' + os, TObject(filecount));
            end;
          1: begin  // option
              if S[i] in AOptionsHasExt then begin  // option has next parameter
                //
                // skip spaces if exists
                Inc(i);
                while (i <= L) and (S[i] <= #32) do Inc(i);
                // get option's parameter
                p:= i;
                Quoted:= (i <= L) and (s[i] in ['''', '"']);
                if Quoted then begin
                  Inc(p);
                  repeat
                    Inc(i);
                  until (i > L) or (S[i] in [#0, '''', '"']);
                  os:= Copy(s, p, i - p);
                  Inc(i);
                  Quoted:= False;
                end else begin
                  repeat
                    Inc(i);
                  until (i > L) or (S[i] in [#0..#32, '-']);
                  os:= Copy(s, p, i - p);
                end;
                // add option
                Rslt.Add(o + '=' + os);
              end else begin
                // add option
                Rslt.Add(o + '=');
                Inc(i);
              end;
            end;
          else begin
            Inc(i);
          end;
        end; { case state }
        //
      end; { else case }
    end; { case }
  end;
end;

{ calc count of switches
}
function GetSwitchesCount(const ASwitches: TSysCharSet; opts: TStrings): Integer;
var
  i: Integer;
  s: String;
begin
  Result:= 0;
  for i:= 0 to opts.Count - 1 do begin
    s:= opts.Names[i];
    if (Length(s) > 0) and (s[1] in ASwitches)
    then Result:= Result + 1;
  end;
end;

{ extract switch values
}
function ExtractSwitchValue(ASwitches: TSysCharSet; opts: TStrings): String;
var
  i, l: Integer;
  s: String;
begin
  Result:= '';
  for i:= 0 to opts.Count - 1 do begin
    s:= opts.Names[i];
    l:= Length(s);
    if ((l > 0) and (s[1] in ASwitches))
      or ((l = 0) and (ASwitches = [])) then begin
      Result:= Copy(opts[i], l + 2, MaxInt);
    end;
  end;
end;

{ extract switch values
}
function ExtractSwitchValues(ASwitches: TSysCharSet; opts: TStrings; ARslt: TStrings): Integer;
var
  i, l: Integer;
  s: String;
begin
  Result:= 0;
  for i:= 0 to opts.Count - 1 do begin
    s:= opts.Names[i];
    l:= Length(s);
    if ((l > 0) and (s[1] in ASwitches))
      or ((l = 0) and (ASwitches = [])) then begin
      s:= Copy(opts[i], l + 2, MaxInt);
      ARslt.AddObject(s, opts.Objects[i]);
      Result:= Result + 1;
    end;
  end;
end;

function HTTPDecode(const AStr: String): String;
var
  Sp, Rp, Cp: PChar;
  S: String;
begin
  SetLength(Result, Length(AStr));
  Sp := PChar(AStr);
  Rp := PChar(Result);
//  Cp := Sp;
  try
    while Sp^ <> #0 do
    begin
      case Sp^ of
        '+': Rp^ := ' ';
        '%': begin
               // Look for an escaped % (%%) or %<hex> encoded character
               Inc(Sp);
               if Sp^ = '%' then
                 Rp^ := '%'
               else
               begin
                 Cp := Sp;
                 Inc(Sp);
                 if (Cp^ <> #0) and (Sp^ <> #0) then
                 begin
                   S := '$' + Cp^ + Sp^;
                   Rp^ := Chr(StrToInt(S));
                 end
                 else
                   RaiseError(3, 'Invalid encoded URL');
               end;
             end;
      else
        Rp^ := Sp^;
      end;
      Inc(Rp);
      Inc(Sp);
    end;
  except
    on E:EConvertError do
      RaiseError(3, 'Invalid encoded URL');
  end;
  SetLength(Result, Rp - PChar(Result));
end;

procedure ExtractHeaderFields(Separators, WhiteSpace: TSysCharSet; Content: PChar;
  Strings: TStrings; Decode: Boolean; StripQuotes: Boolean = False);
var
  Head, Tail: PChar;
  EOS, InQuote, LeadQuote: Boolean;
  QuoteChar: Char;

  function DoStripQuotes(const S: string): string;
  var
    I: Integer;
  begin
    Result := S;
    if StripQuotes then
      for I := Length(Result) downto 1 do
        if Result[I] in ['''', '"'] then
          Delete(Result, I, 1);
  end;

begin
  if (Content = nil) or (Content^ = #0) then Exit;
  Tail := Content;
  QuoteChar := #0;
  repeat
    while Tail^ in WhiteSpace + [#13, #10] do Inc(Tail);
    Head := Tail;
    InQuote := False;
    LeadQuote := False;
    while True do
    begin
      while (InQuote and not (Tail^ in [#0, #13, #10, '"'])) or
        not (Tail^ in Separators + [#0, #13, #10, '"']) do Inc(Tail);
      if Tail^ = '"' then
      begin
        if (QuoteChar <> #0) and (QuoteChar = Tail^) then
          QuoteChar := #0
        else
        begin
          LeadQuote := Head = Tail;
          QuoteChar := Tail^;
          if LeadQuote then Inc(Head);
        end;
        InQuote := QuoteChar <> #0;
        if InQuote then
          Inc(Tail)
        else Break;
      end else Break;
    end;
    if not LeadQuote and (Tail^ <> #0) and (Tail^ = '"') then
      Inc(Tail);
    EOS := Tail^ = #0;
    Tail^ := #0;
    if Head^ <> #0 then
      if Decode then
        Strings.Add(DoStripQuotes(HTTPDecode(Head)))
      else Strings.Add(DoStripQuotes(Head));
    Inc(Tail);
  until EOS;
end;

procedure EmptyNames(AName: String; AStrings: TStrings);
var
  i: Integer;
  p: Integer;
  s: String;
begin
  for i:= 0 to AStrings.Count - 1 do begin
    s:= AStrings[i];
    p:= Pos('=', s);
    if p = 0 then begin
      s:= s + '=';
      AStrings[i]:= s;
    end else begin
      if CompareText(AName, Copy(s, 1, p - 1)) = 0 then begin
        Delete(s, 1, p);
        AStrings[i]:= '=' + s;
      end;
    end;
  end;
end;

procedure Print2Output(const AFileIn: String;
  ADitherMode: TDitherMode; ATransformOptions: TTransformOptions);
var
  wbmpImg: TWBMPImage;
  Picture: TPicture;
  y, x: Integer;
begin
  Picture:= TPicture.Create;
  wbmpImg:= TWBMPImage.Create;
  wbmpImg.TransformOptions:= ATransformOptions;
  try
    Picture.LoadFromFile(AFileIn);
    with wbmpImg do begin
      DitherMode:= ADitherMode;
      Assign(Picture.Graphic);
      for y:= 0 to Height - 1 do begin
        for x:= 0 to Width - 1 do begin
          with wbmpImg.Bitmap.Canvas, CR(Pixels[x, y]) do begin
            if v[0]+v[1]+v[3] >= 3 * $FF div 2
            then Write(output, '*')
            else Write(output, ' ');
          end;
        end;
        Writeln(output);
      end;
    end;
  except
  end;
  wbmpImg.Free;
  Picture.Free;
end;


function ProcessFile(const AFN: String; AEnv: TObject): Boolean;
var
  fn, ext, op, np: String;
  StrmWBMP: TStream;
  ImageSize: TPoint;
  TransformOptions: TTransformOptions;
begin
  Result:= True;
//DEF_BITMAPEXTS
  ext:= ExtractFileExt(AFN);
  if Pos(LowerCase(ext), DEF_BITMAPEXTS) = 0
  then Exit;
  fn:= util1.ReplaceExt('wbmp', AFN);
  if (Length(TCvrtEnv(AEnv).outputpath) = 0) or (TCvrtEnv(AEnv).outputpath = '.')
  then op:= ''
  else op:= TCvrtEnv(AEnv).outputpath;

  fn:= ConcatPath(op, fn, '\');

  np:= ExtractFilePath(fn);
  if (Length(np) = 0) or DirectoryExists(np) then begin
    // folder exists
  end else begin
    // create folder
    if CreateDir(np) then begin
      if TCvrtEnv(AEnv).verbose
      then Writeln(output, Format('    Folder %s created.', [np]));
    end else begin
      if TCvrtEnv(AEnv).verbose
      then RaiseError(2, Format('Cannot create folder %s.', [np]));
    end;
  end;
  if TCvrtEnv(AEnv).verbose then begin
    Write(output, Format('    %s -> %s', [AFN, fn]));
  end;
  TCvrtEnv(AEnv).Count:= TCvrtEnv(AEnv).Count + 1;

  if not TCvrtEnv(AEnv).IsRegistered
  then TransformOptions:= TransformOptions + [toUnregistered];
  if TCvrtEnv(AEnv).Negative
  then TransformOptions:= TransformOptions + [toNegative];
  if TCvrtEnv(AEnv).NoAlign
  then TransformOptions:= TransformOptions - [toAlign8];

  try
    if TCvrtEnv(AEnv).send2output
    then StrmWBMP:= TStringStream.Create('')
    else StrmWBMP:= TFileStream.Create(fn, fmCreate);
  except
    RaiseError(4, Format('Cannot create file %s', [fn]));
  end;
  if TCvrtEnv(AEnv).createHTTPheader then begin
    StrmWBMP.Write(DEF_HTTPHEADER[1], Length(DEF_HTTPHEADER));
  end;
  if ConvertImage2WBMP(Afn, StrmWBMP, TCvrtEnv(AEnv).DitherMode, TransformOptions, ImageSize) then begin
  end;

  if TCvrtEnv(AEnv).send2output then begin
    Write(output, TStringStream(StrmWBMP).DataString);
  end else begin
  end;
  if TCvrtEnv(AEnv).verbose then begin
    Writeln(output, Format(' Size: %dx%d, %d bytes', [ImageSize.x, ImageSize.y, StrmWBMP.Size]));
  end;
  if TCvrtEnv(AEnv).Print2Console then begin
    Print2Output(Afn, TCvrtEnv(AEnv).DitherMode, TransformOptions);
  end;
  StrmWBMP.Free;
end;

function PrintSettings(AEnv: TCvrtEnv): String;
const
  R: array[Boolean] of String = ('', 'recurse subdirectories, ');
  V: array[Boolean] of String = ('', 'verbose output, ');
  G: array[Boolean] of String = ('', 'get options from QUERY_STRING, ');
  I: array[Boolean] of String = ('', 'read options from input, ');
  H: array[Boolean] of String = ('', 'create HTTP header, ');
  D: array[Boolean] of String = ('', 'ini file settings skipped, ');
  N: array[Boolean] of String = ('', 'negative, ');
  NA8: array[Boolean] of String = ('align 8 bit, ', 'no align, ');
  C: array[Boolean] of String = ('store files.', 'send to output.');
var
  p: Integer;
begin
  Result:=
    'Switches:'#13#10+
    '  output folder: ' + AEnv.outputpath + #13#10 +
    '  Dithering: ' + GetDitherModeName(AEnv.DitherMode) +#13#10 +
    '  ' + R[AEnv.recurse] + V[AEnv.verbose] + G[AEnv.getQUERY_STRING] +
    D[AEnv.SkipIni] + N[AEnv.Negative] + NA8[AEnv.NoAlign] +
    I[AEnv.getInput] + H[AEnv.createHTTPheader] + C[AEnv.send2output] + #13#10 +
    'File(s) or file mask:'#13#10;
  for p:= 0 to AEnv.filelist.Count - 1 do begin
    Result:= Result + '  ' + AEnv.filelist[p] + #13#10;
  end;
end;

function CheckParameters(AOpts: TStrings; AEnv: TCvrtEnv): Boolean;
var
  i: Integer;
  s: String;
begin
  ExtractSwitchValues([], Aopts, AEnv.filelist);
  { check '.', '..' and other directory specs }
  for i:= 0 to AEnv.filelist.Count - 1 do begin
    if DirectoryExists(AEnv.filelist[i]) then begin
      s:= ConcatPath(AEnv.filelist[i], '*.*', '\');
      AEnv.filelist[i]:= s;
    end;
  end;
  AEnv.outputpath:= ExtractSwitchValue(['o', 'O'], AOpts);
  AEnv.DitherMode:= GetDitherModeByName(ExtractSwitchValue(['m', 'M'], AOpts), dmNearest);
  AEnv.recurse:= GetSwitchesCount(['r', 'R'], AOpts) > 0;
  AEnv.verbose:= GetSwitchesCount(['v', 'V'], AOpts) > 0;
  AEnv.showhelp:= GetSwitchesCount(['?'], AOpts) > 0;
  AEnv.Print2Console:= GetSwitchesCount(['s', 'S'], AOpts) > 0;
  AEnv.send2output:= GetSwitchesCount(['c', 'C'], AOpts) > 0;
  AEnv.getQUERY_STRING:= GetSwitchesCount(['g', 'G'], AOpts) > 0;
  AEnv.getInput:= GetSwitchesCount(['p', 'P'], AOpts) > 0;
  AEnv.createHTTPheader:= GetSwitchesCount(['h', 'H'], AOpts) > 0;
  AEnv.SkipIni:= GetSwitchesCount(['d', 'D'], AOpts) > 0;
  AEnv.Negative:= GetSwitchesCount(['n', 'N'], AOpts) > 0;
  AEnv.NoAlign:= GetSwitchesCount(['8'], AOpts) > 0;

  if Length(AEnv.outputpath) = 0
  then AEnv.outputpath:= '.';
  Result:= DirectoryExists(AEnv.outputpath);
  if not Result
  then Writeln(output, Format('output folder %s does not exists', [AEnv.outputpath]))
  else Result:= (AEnv.filelist.Count > 0) or (AEnv.getQUERY_STRING or AEnv.getInput);
end;


constructor TCvrtEnv.Create(AIsRegistered: Boolean);
begin
  inherited Create;
  Count:= 0;
  filelist:= TStringList.Create;
  IsRegistered:= AIsRegistered;
end;

procedure TCvrtEnv.Clear;
begin
  Count:= 0;
  filelist.Clear;
end;

destructor TCvrtEnv.Destroy;
begin
  filelist.Free;
  inherited Destroy;
end;


function DoCmd(AIsRegistered: Boolean): Boolean;
label
  LSkipIni;
var
  f: Integer;
  config,
  configfn: String;
  cvrtEnv: TCvrtEnv;
  opts: TStrings;
  skipinicount: Integer;

begin
  skipinicount:= 0;
  cvrtEnv:= TCvrtEnv.Create(AIsRegistered);
  opts:= TStringList.Create;
  configfn:= ConcatPath(ExtractFilePath(ParamStr(0)), 'i2wbmp.ini', '\');
  if FileExists(configfn) then begin
    config:= util1.File2String(configfn);
  end else config:= '';
LSkipIni:
  Inc(skipinicount);
  f:= Pos(#32, CmdLine);
  if f = 0
  then f:= Length(CmdLine)+1;
  config:= Copy(CmdLine, 1, f - 1) + #32 + config + #32 + Copy(CmdLine, f + 1, MaxInt);
  ParseCmd(config, OptionsHasExt, opts);

  if (not CheckParameters(opts, cvrtEnv)) or (cvrtEnv.showhelp) then begin
    Writeln(output, PrintCopyright(AIsRegistered) + PrintUsage);
    cvrtEnv.Free;
    Result:= False;
    Exit;
  end;
  if cvrtEnv.SkipIni and (skipinicount = 1) then begin
    opts.Clear;
    cvrtEnv.Clear;
    config:= '';
    goto LSkipIni;
  end;

  if cvrtEnv.getQUERY_STRING then begin
    // read QUERY_STRING
    ExtractHeaderFields(['&'], [], PChar(GetEnvironmentVariable('QUERY_STRING')), opts, True, True);
    EmptyNames('src', opts);
    if not CheckParameters(opts, cvrtEnv) then begin
      RaiseError(6, 'Invalid parameters');
    end;
    cvrtEnv.verbose:= false;
//  cvrtEnv.send2output:= true;
//Writeln(output, '(((', opts.Text, ')))');
  end;
  if cvrtEnv.getInput then begin
    // read input
    f:= 1;
    while not EOF(input) do begin
      SetLength(config, f);
      Read(input, config[f]);
      Inc(f);
    end;
    ExtractHeaderFields(['&'], [], PChar(config), opts, True, True);
    EmptyNames('src', opts);
    if not CheckParameters(opts, cvrtEnv) then begin
      RaiseError(7, 'Invalid parameters');
    end;
    cvrtEnv.verbose:= false;
//  cvrtEnv.send2output:= true;
  end;

  if cvrtEnv.send2output
  then cvrtEnv.verbose:= false
  else Writeln(output, PrintCopyright(AIsRegistered));

  if cvrtEnv.verbose then begin
    Writeln(output, PrintSettings(cvrtEnv));
    Writeln('Process file(s):');
  end;
  for f:= 0 to cvrtEnv.filelist.Count - 1 do begin
    if cvrtEnv.verbose then Writeln(output, '  ', cvrtEnv.filelist[f]);
    if DirectoryExists(cvrtEnv.filelist[f]) then begin
      // directory
      Walk_Tree('*.*', cvrtEnv.filelist[f], faAnyFile, cvrtEnv.Recurse, ProcessFile, cvrtEnv);
    end else begin
      if FileExists(cvrtEnv.filelist[f]) then begin
        // file
        ProcessFile(cvrtEnv.filelist[f], cvrtEnv);
      end else begin
        // mask ?
        Walk_Tree(ExtractFileName(cvrtEnv.filelist[f]),
          ExtractFilePath(cvrtEnv.filelist[f]), faAnyFile, cvrtEnv.Recurse, ProcessFile, cvrtEnv);
      end;
    end;
  end;
  if not cvrtEnv.send2output
  then Writeln(output, #13#10, cvrtEnv.Count, ' file(s) done.');
  cvrtEnv.Free;
  opts.Free;
end;

end.
