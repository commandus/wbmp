unit
  fmain;
(*##*)
(***************************************************************************
*                                                                         *
*   i  2  w  b  m  p    m  a  i  n                                         *
*                                                                         *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                   *
*   wbmp image convertor                                                  *
*   Conditional defines:                                                   *
*                                                                         *
*   Default path: /2wbmp/                                                  *
*                                                                         *
*   Parameters:                                                            *
*   src=[alias|folder]filename                                            *
*   [dither=Nearest|FloydSteinberg|Stucki|Sierra|JaJuNI|SteveArche|Burkes] *
*   [negative=1|0]                                                        *
*   [noAlign=1|0]                                                          *
*                                                                         *
*   Registry:                                                              *
*   HKEY_LOCAL_MACHINE\Software\ensen\i2wbmp\1.0\                         *
*     DefDitherMode, as dither parameter, default 'nearest'                *
*     DefWBMP default wbmp image up to 4016 bytes long binary             *
*       (if errors occured)                                                *
*     \Virtual Roots - contains aliases in addition ti IIS (PWS)          *
*                                                                          *
*                                                                         *
*   HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\            *
*      Parameters\Virtual Roots                                           *
*                                                                          *
*   E:\Inetpub\Scripts\i2wbmp.dll                                         *
*                                                                          *
*   Revisions    : Apr 15 2002                                            *
*   Last fix     : Apr 15 2002                                             *
*   Lines        : 188                                                    *
*   History      :                                                         *
*   Printed      : ---                                                    *
*                                                                          *
***************************************************************************)
(*##*)

interface

uses
  SysUtils, Classes, HTTPApp, Windows, Registry, GifImage,
  util1, secure, wmleditutil, wbmpimage, cmdcvrt;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1WebActionItem1Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
    procedure WebModule1WebActionItem2Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
    PathsList,
    SLAlias: TStrings;
    DefDitherMode: TDitherMode;
    procedure ValidateW3SvcColon;
    function Alias2FileName(const AFn: String): String;
    function GetQueryField(const AName: String): String;
    function IsRegistered: Boolean;
  public
    { Public declarations }
    FRegistered: Boolean;
    property QFld[const name: String]: String read GetQueryField;
  end;

var
  WebModule1: TWebModule1;

implementation

{$R *.DFM}

const
  fpSCRIPT        = 0;
  fpPatternPath   = 1;
  fpDefDitherMode = 2;
  fpUser          = 3;
  fpCode          = 4;
  fpDefWBMP       = 5;
  
  LNVERSION = '1.0';
  RGPATH = '\Software\ensen\i2wbmp\'+ LNVERSION;  //
  RGW2SVCALIAS = '\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots';
  CVRTRGPATH = '\Software\ensen\cvrt2wbmp\1.0';

procedure TWebModule1.ValidateW3SvcColon;
var
  i, L: Integer;
  S: String;
begin
  for i:= 0 to SLAlias.Count - 1 do begin
    repeat
      S:= SLAlias.Names[i];
      L:= Length(S);
      if (L < 0) or (not(S[L] in [#0..#32, ',']))
      then Break;
      S:= SLAlias[i];
      Delete(S, L, 1);
      SLAlias[i]:= S;
    until False;
  end;
  // set default "current" directory
  if SLAlias.Values[''] = ''
  then SLAlias.Add('=' + PathsList[fpPatternPath]);
  // set default "root" directory
  if SLAlias.Values['/'] = ''
  then SLAlias.Add('/=' + PathsList[fpPatternPath]);
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

procedure TWebModule1.WebModule1WebActionItem1Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  s: String;
  DitherMode: TDitherMode;
  TransformOptions: TTransformOptions;
  ImageSize: TPoint;
  strm: TStream;
begin
  Handled:= True;
  Response.ContentType:= 'image/vnd.wap.wbmp';
  Response.Title:= 'i2wbmp';
  DitherMode:= GetDitherModeByName(QFld['dither'], DefDitherMode);
  TransformOptions:= [toAlign8];
  if not FRegistered
  then TransformOptions:= TransformOptions + [toUnregistered];

  if StrToIntDef(QFld['negative'], 0) > 0
  then TransformOptions:= TransformOptions + [toNegative];
  if StrToIntDef(QFld['noAlign'], 0) > 0
  then TransformOptions:= TransformOptions - [toAlign8];
  strm:= TStringStream.Create('');

  s:= Alias2FileName(QFld['src']);
  Response.DerivedFrom:= ReplaceExt('wbmp', s);
  if ConvertImage2WBMP(s, strm, DitherMode, TransformOptions, ImageSize) then begin
    Response.Content:= TStringStream(strm).DataString;
  end;
  if Length(Response.Content) = 0 then begin
    Response.StatusCode:= 404;
    Response.ReasonString:= 'iwbmp error: file "' + s +'" not found.';
    Response.LogMessage:=  Response.LogMessage + ' , error: file "' + s +'" not found.';
    Response.Content:= PathsList[fpDefWBMP];
  end;
  Response.ContentLength:= Length(Response.Content);
  // Response.Content:= s + #13#10 + QFld['src'] + #13#10 + Request.QueryFields.Values['src'];
  strm.Free;
end;

procedure TWebModule1.WebModule1WebActionItem2Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
const
  RegisteredStr: array[Boolean] of String = ('Evaluation version', 'This version is registered to %s');

begin
  Handled:= True;
  Response.ContentType:= 'text/plain';

  Response.Content:= 'Bitmap image to wbmp convertor ' + LNVERSION + #13#10 +
    Format(RegisteredStr[FRegistered], [PathsList[fpUser]]) + #13#10 +
    'Copyright © 2002 Andrei Ivanov. All rights reserved.'#13#10 +
    'Should you have any questions concerning this program, please contact: mailto:ensen_andy@yahoo.com'#13#10#13#10 +
    'Default ContentType: image/vnd.wap.wbmp'#13#10#13#10 +
    'src (file name (virtual roots available listed below)): bmp, jpeg, ico, wmf and wbmp'#13#10 +
    '  Note: if relative file name used, DLL looking for Referer, Referer: ' + Request.Referer + #13#10 +
    'dither (dithering modes available): Nearest|FloydSteinberg|Stucki|Sierra|JaJuNI|SteveArche|Burkes'#13#10 +
    'noalign (disable align width to 8 pixels): 1|0'#13#10 +
    'negative (produce negative image): 1|0'#13#10#13#10 +

   'Settings:'#13#10#13#10+
    'Default dithering: '+ GetDitherModeName(DefDitherMode) + #13#10#13#10+
    'web server aliases: '#13#10 + SLAlias.Text + #13#10;
{
    'User: ' + PathsList[fpUser] + #13#10 +
    'Code: ' + PathsList[fpCode] + #13#10;
}
end;

procedure TWebModule1.WebModuleCreate(Sender: TObject);
var
  S: String;
  FN: array[0..MAX_PATH- 1] of Char;
  rg: TRegistry;
begin
  rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_LOCAL_MACHINE;
  Rg.OpenKeyReadOnly(RGPATH);

  PathsList:= TStringList.Create;
  SetString(S, FN, GetModuleFileName(hInstance, FN, SizeOf(FN)));
  // fpSCRIPT (0) Script name используется для ссылок в HTML
  PathsList.Add(S);
  // fpPatternPath (1), if not specified or wrong folder - is2sql.DLL location
  PathsList.Add(ExtractFilePath(S));
  // fpDefDitherMode (2) default dithering mode
  PathsList.Add(rg.ReadString('DefDitherMode'));

  Rg.OpenKeyReadOnly(CVRTRGPATH);
  // fpUser (3) user name
  PathsList.Add(rg.ReadString('Name'));
  // fpCode (4) code
  PathsList.Add(rg.ReadString('Code'));
  // fpDefWBMP (5) default
  SetLength(s, 4016);
  SetLength(s, rg.ReadBinaryData('DefWBMP', s[1], Length(s)));
  // set default dithering mode
  DefDitherMode:= GetDitherModeByName(PathsList[fpDefDitherMode], dmNearest);
  SLAlias:= TStringList.Create;
  AddEntireKey(RGW2SVCALIAS, SLAlias);
  AddEntireKey(RGPATH+'\Virtual Roots', SLAlias);
  ValidateW3SvcColon;
  rg.Free;
  FRegistered:= IsRegistered;
end;

function TWebModule1.Alias2FileName(const AFn: String): String;
begin
  if util1.IsAbsolutePath(AFn) then begin
    // absolute path i.e. /icons or \path or E:\path
    Result:= util1.ConCatAliasPath(SLAlias, PathsList[fpPatternPath], AFn);
  end else begin
    // relative path
    Result:= util1.ConcatPath(Self.Request.Referer, AFn, '/')
    //if Pos('..', AFn) > 0  then Result:= '' // return nothing, no '../..'
  end;
end;

function TWebModule1.GetQueryField(const AName: String): String;
begin
  with Request do begin
    if MethodType = mtPost
    then Result:= ContentFields.Values[AName]
    else Result:= QueryFields.Values[AName];
  end;
end;

function TWebModule1.IsRegistered: Boolean;
var
  S: String;
begin
  // calculate hash
  S:= 'enzi' + 'cvrt2wbmp' + PathsList[fpUser];
  Result:= PathsList[fpCode] = secure.GetMD5Digest(PChar(S), Length(S), 36);
end;

procedure TWebModule1.WebModuleDestroy(Sender: TObject);
begin
  SLAlias.Free;
  PathsList.Free;
end;

end.
