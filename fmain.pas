unit fmain;
(*##*)
(*******************************************************************************
*                                                                              *
*   F  M  A  I  N                                                             *
*   main form of CVRT2WBMP, part of CVRT2WBMP                                  *
*                                                                             *
*   Copyright (c) 2001-2008 Andrei Ivanov. All rights reserved.                *
*                                                                             *
*   DDE  Server cvrt2wbmp                                                      *
*        Topic  System                                                        *
*        Macros fileopen("filename1"[,"filename2"])                            *
*               folderopen("dirname1")                                        *
*   Conditional defines:                                                       *
*                                                                             *
*   History                                                                    *
*           Jun 07 2001                                                       *
*           May 01 2008                                                       *
*                                                                              *
*                                                                             *
*   Lines        :                                                             *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)
{$DEFINE USE_TWAIN}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtDlgs, StdCtrls, Menus, ComCtrls, StdActns, ActnList, ExtCtrls, clipbrd,
  Registry, FileCtrl,
  JPEG, GifImage, util1, utilwin, wbmputil, UtilHttp,
{$IFDEF USE_TWAIN}
  MultiTwain,
{$ENDIF}
  secure, wbmpimage, asciipic, scrollimg, FAbout, FWarning,
  ImgList, rtcShellHelper, rtcFolderTree, DdeMan;

const
  REGISTER_URL = 'http://www.regsoft.net/purchase.php3?productid=38958';
  REGISTER_HOME_URL = 'http://wbmp.commandus.com';
  REGISTER_HOWTO_URL = REGISTER_HOME_URL;
  REGISTER_README = 'readme.txt';
  REGISTER_PRODUCTCODE = 'cvrt2wbmp';
  REGISTER_REGSOFTPRODUCTCODE = 38958;
  PROG_NAME = 'WBMP convertor';

  { ads }
  MyBannerImg = 'http://www.lbe.ru/cgi-bin/banner/ensen?2';
  MyBannerHref = 'http://www.lbe.ru/cgi-bin/href/ensen?2';

  MyBannerHint     = 'If you want to remove this banner, press F4 to license program';
  SMSG_WARNING     = 'This feature is not avaliable in evaluation version.'#13#10'You can register your copy of CVRT2WBMP for $19 online:'#13#10'http://www.regsoft.net/purchase.php3?productid=38958';
  SMSG_THANKS      = 'Thank you!'#13#10'Please save message with your license key';
  SMSG_INVALIDKEY  = 'Sorry, entered key is invalid'#13#10'Please copy and paste license key from message'#13#10+
    'Note: Name and key are case sensitive';
  { registry constants }
  APPNAME = 'cvrt2wbmp';

  { version }
  LNVERSION = '1.0';
  { resource language }
  LNG = ''; { DLL language usa, 409 }
  { registry path }
  RGPATH = 'Software\ensen\'+APPNAME+'\'+ LNVERSION;
  ID_COMPANY       = 0;
  ID_USER          = 1;
  ID_CODE          = 2;

  ID_FolderTreeX   = 3;
  ID_PanelLeftX    = 4;
  ID_FormSizeXY    = 5;
  ID_Stretch       = 6;
  ID_Align8bit     = 7;
  ID_Negative      = 8;
  ID_AppendText    = 9;
  ID_AutoDither    = 10;
  ID_Directory     = 11;
  ID_DirectoryHeight = 12;

  ParameterNames: array[0..12] of String[15] = (
  'Company', 'Name', 'Code', 'FolderTreeX', 'FolderPanelX',
  'FormSizeXY', 'Stretch', 'Align8bit', 'Negative', 'AppendText', 'AutoDither',
  'LastDir', 'DirectoryHeight');

type
  TFormMain = class(TForm)
    PanelTop: TPanel;
    LDesc: TLabel;
    MainMenu1: TMainMenu;
    MFile: TMenuItem;
    MFileOpen: TMenuItem;
    MD1: TMenuItem;
    MFileSaveAs: TMenuItem;
    MFileSave: TMenuItem;
    MFileExit: TMenuItem;
    MEditEdit: TMenuItem;
    MEditCopy: TMenuItem;
    MEditPaste: TMenuItem;
    MD2: TMenuItem;
    MFileConvert: TMenuItem;
    ActionList1: TActionList;
    FileOpen: TAction;
    EditCopy: TEditCopy;
    EditPaste: TEditPaste;
    FileSave: TAction;
    FileSaveAs: TAction;
    FileExit: TAction;
    MSettings: TMenuItem;
    MSettingsViewStretch: TMenuItem;
    SettingsViewStretch: TAction;
    MD3: TMenuItem;
    MSettingsAlign8: TMenuItem;
    SettingsAlign8bit: TAction;
    HelpAbout: TAction;
    MHelp: TMenuItem;
    MHelpAbout: TMenuItem;
    MD4: TMenuItem;
    CBDitherMode: TComboBox;
    LDitherMode: TLabel;
    PopupMenuWBMP: TPopupMenu;
    FileSaveAsText: TAction;
    SaveasText1: TMenuItem;
    FileSaveAsAsText: TAction;
    MD5: TMenuItem;
    Saveasplaintext1: TMenuItem;
    Saveastext2: TMenuItem;
    About1: TMenuItem;
    MD7: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    MD6: TMenuItem;
    Open1: TMenuItem;
    SettingsAppendText: TAction;
    SettingsAppendtoExistingText: TMenuItem;
    FileViewText: TAction;
    Viewsavedastextfile1: TMenuItem;
    Viewsavedastextfile2: TMenuItem;
    FileScan: TAction;
    Scan1: TMenuItem;
    HelpRegister: TAction;
    MD8: TMenuItem;
    Register1: TMenuItem;
    HelpHowToRegister: TAction;
    Howtoregister1: TMenuItem;
    HelpWhatNew: TAction;
    Whatinregisteredversion1: TMenuItem;
    actRegisterGoWeb: TAction;
    actHowToRegister: TAction;
    actWhatNew: TAction;
    actEnterCode: TAction;
    ImageList1: TImageList;
    FileConvertAll: TAction;
    FileConvert: TAction;
    Convertall1: TMenuItem;
    PanelLeft: TPanel;
    ScrollBoxLeft: TScrollBox;
    SplitterVert: TSplitter;
    SettingsAutoDither: TAction;
    MSettingsAutoditherAfterLoading: TMenuItem;
    FileSaveAll: TAction;
    MD9: TMenuItem;
    Saveallimages1: TMenuItem;
    MD11: TMenuItem;
    CBFilter: TComboBox;
    LFilter: TLabel;
    actChangeFilter: TAction;
    actRebuildFileFilter: TAction;
    actValidateCode: TAction;
    actIntergateShell: TAction;
    Timer1: TTimer;
    PopupMenuBanner: TPopupMenu;
    popBannerRegister: TMenuItem;
    MD12: TMenuItem;
    actShowTextNoBanner: TAction;
    actShowBannerNoText: TAction;
    popShowBanner: TMenuItem;
    PopupMenuDirectory: TPopupMenu;
    DirRefresh: TAction;
    Refresh1: TMenuItem;
    SplitterEdit: TSplitter;
    SettingsFileAssociations: TAction;
    MD10: TMenuItem;
    Setfileassociations1: TMenuItem;
    actParseCommandLine: TAction;
    PanelDraw: TPanel;
    System: TDdeServerConv;
    SettingsNegative: TAction;
    SettingsNegative1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileExitExecute(Sender: TObject);
    procedure FileOpenExecute(Sender: TObject);
    procedure FileSaveAsExecute(Sender: TObject);
    procedure FileSaveExecute(Sender: TObject);
    procedure FileConvertExecute(Sender: TObject);
    procedure SettingsViewStretchExecute(Sender: TObject);
    procedure EditCopyExecute(Sender: TObject);
    procedure MEditPasteClick(Sender: TObject);
    procedure MEditEditClick(Sender: TObject);
    procedure SettingsAlign8bitExecute(Sender: TObject);
    procedure CBDitherModeChange(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure FileSaveAsTextExecute(Sender: TObject);
    procedure FileSaveAsAsTextExecute(Sender: TObject);
    procedure SettingsAppendTextExecute(Sender: TObject);
    procedure FileViewTextExecute(Sender: TObject);
    procedure SplitterVertMoved(Sender: TObject);
    procedure FileScanExecute(Sender: TObject);
    procedure HelpRegisterExecute(Sender: TObject);
    procedure actRegisterGoWebExecute(Sender: TObject);
    procedure actHowToRegisterExecute(Sender: TObject);
    procedure FileConvertAllExecute(Sender: TObject);
    procedure SettingsAutoDitherExecute(Sender: TObject);
    procedure OnClickImage(Sender: TObject);
    procedure FileSaveAllExecute(Sender: TObject);
    procedure actChangeFilterExecute(Sender: TObject);
    procedure actEnterCodeExecute(Sender: TObject);
    procedure actRebuildFileFilterExecute(Sender: TObject);
    procedure actValidateCodeExecute(Sender: TObject);
    procedure HelpWhatNewExecute(Sender: TObject);
    procedure HelpHowToRegisterExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actIntergateShellExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure actShowTextNoBannerExecute(Sender: TObject);
    procedure actShowBannerNoTextExecute(Sender: TObject);
    procedure popShowBannerClick(Sender: TObject);
    procedure DirRefreshExecute(Sender: TObject);
    procedure FolderTreeChange(Sender: TObject; Node: TTreeNode);
    procedure SplitterEditMoved(Sender: TObject);
    procedure SettingsFileAssociationsExecute(Sender: TObject);
    procedure actParseCommandLineExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SystemExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure SettingsNegativeExecute(Sender: TObject);
  private
    { Private declarations }
    FirstActivate: Boolean;
    ScrolledImages: TScrolledImages;
    ScrolledWBMPs: TScrolledImages;
    FFileFormatsList: TStrings;
    FCurDirImageFileNames: TStrings;
    FFileNameOut: String;
    FFileNameAsTextOut: String;
    FDitherMode: TDitherMode; // dmNearest dmFloydSteinberg dmStucki dmSierra dmJaJuNI dmSteveArche dmBurkes
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    FolderBrowseDialog: TFolderBrowseDialog;
    SaveDialog1: TSaveDialog;
    WBmp: TWBMPImage;
    FBanner: THttpGifLoader;      // ads
    procedure CreateBanner(AControl: TControl);       // ads

    procedure ScrollImagesOnProgressEvent(Sender: TObject; AWhat: Integer; const AMsg: string);
    procedure LoadFiles(AFiles: TStrings);
    procedure LoadFilesInFolder(AFolder: String);
    procedure EnableActionsByTag(ATag: Integer; AOn: Boolean);
    procedure DoResize(AScrolledImages: TScrolledImages; AWidth: Integer);
    function WarningIsNotRegistered: Boolean;
    function ShowWarnings(ACaption, AMsg: String): Boolean;
    procedure OnTerminateLoad(Sender: TObject);
    procedure OnTerminateDither(Sender: TObject);
    procedure OnClickFBanner(Sender: TObject);  // ads
  protected
    procedure ScrollBoxWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBoxWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure CMDialogKey(var Msg: TCMDialogKey); message CM_DIALOGKEY;
  public
    { Public declarations }
    FolderTree0: TrtcFolderTree;

    FParameters: TStrings;
    FRegistered: Boolean;
    function LoadIni: Boolean;
    function StoreIni(AKind: Integer): Boolean;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.DFM}

uses
  FRegister, ffileassoc;

function TFormMain.WarningIsNotRegistered: Boolean;
begin
  //
  Result:= True;
  FormWarning:= TFormWarning.Create(Nil);
  with FormWarning do begin
    Caption:= 'This feature is not available in evaluation version';
    MemoMessage.Text:= SMSG_WARNING;
    BRegister.Caption:= '&License';
    if ShowModal = mrOk then begin
      HelpRegisterExecute(Self);
    end;
  end;
  FormWarning.Free;
end;

function TFormMain.ShowWarnings(ACaption, AMsg: String): Boolean;
begin
  //
  Result:= True;
  FormWarning:= TFormWarning.Create(Nil);
  with FormWarning do begin
    Caption:= ACaption;
    MemoMessage.Text:= AMsg;
    BRegister.Caption:= '&Ok';
    if ShowModal = mrOk then begin
    end;
  end;
  FormWarning.Free;
end;

//------------------ TForm1 ------------------

{ load settings from registry }
function TFormMain.LoadIni: Boolean;
var
  i: Integer;
  Rg: TRegistry;

function RgPar(ParamName, DefaultValue: String): String;
var
  S: String;
begin
  try
    S:= Rg.ReadString(ParamName);
  except
  end;
  if S = ''
  then RgPar:= DefaultValue
  else RgPar:= S;
end;

procedure AddPar(ParamName, DefaultValue: String);
begin
  FParameters.Add(ParamName + '=' + RgPar(ParamName, DefaultValue));
end;

begin
  FParameters.Clear;
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_LOCAL_MACHINE;
  Rg.OpenKey(RGPATH, True);

  for i:= Low(ParameterNames) to High(ParameterNames) do begin
    AddPar(ParameterNames[i], '');
  end;
  {
  for i:= 0 to $F do begin
    AddPar(ParameterNames[ID_LASTPRODUCT]+'-'+sysutils.IntToHex(i, 1), '');
    S:= FParameters.Values[ParameterNames[ID_LASTPRODUCT]+'-'+sysutils.IntToHex(i, 1)];
    if Length(S) > 0
    then CBProduct.Items.Add(S);
  end;
  }
  Rg.Free;
  Result:= True;
end; { LoadIni }

function TFormMain.StoreIni(AKind: Integer): Boolean;
var
  Rg: TRegistry;
  i: Integer;
begin
  Result:= True;
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_LOCAL_MACHINE;
  Rg.OpenKey(RGPATH, True);
  case AKind of
  0:begin
    // all parameters except registration key
    for i:= Low(ParameterNames) to High(ParameterNames) do begin
      try
        if (ANSICompareText(ParameterNames[i], ParameterNames[ID_USER])=0) or
          (ANSICompareText(ParameterNames[i], ParameterNames[ID_CODE])=0)
        then Continue;
        Rg.WriteString(ParameterNames[i], FParameters.Values[ParameterNames[i]]);
      except
        Result:= False;
      end;
    end;
    end;
  1:begin
      // registration key only
      try
        Rg.WriteString(ParameterNames[ID_USER], FParameters.Values[ParameterNames[ID_USER]]);
        Rg.WriteString(ParameterNames[ID_CODE], FParameters.Values[ParameterNames[ID_CODE]]);
      except
        Result:= False;
      end;
    end;
  end; { case }
  Rg.Free;
end; { StoreIni }

procedure TFormMain.EnableActionsByTag(ATag: Integer; AOn: Boolean);
var
  i: Integer;
begin
  for i:= 0 to ActionList1.ActionCount - 1 do with TAction(ActionList1.Actions[i]) do begin
    if (TAction(ActionList1.Actions[i]).Tag and ATag) <> 0 then begin
      TAction(ActionList1.Actions[i]).Enabled:= AOn;
    end;
  end;
end;

procedure TFormMain.DoResize(AScrolledImages: TScrolledImages; AWidth: Integer);
begin
  if not Assigned(AScrolledImages)
  then Exit;
  with AScrolledImages do begin
    if AWidth <=0 then AWidth:= Abs(AWidth);
    if AWidth > 300 then AWidth:= 300;
    Width:= AWidth;
  end;
end;

procedure TFormMain.ScrollImagesOnProgressEvent(Sender: TObject; AWhat: Integer; const AMsg: string);
var
  simg: TScrolledImage;
begin
  if AWhat >= 0 then begin
    // do dither
    // ScrolledWBMPs.CurImageNo:= AWhat;
    // FileConvertExecute(Self);
    simg:= ScrolledWBMPs.ScrolledImage[AWhat];
    if Assigned(simg) then with simg do begin
      Left:= ScrolledImages.ScrolledImage[AWhat].Left + ScrolledImages.ScrolledImage[AWhat].Width;
      Top:= ScrolledImages.ScrolledImage[AWhat].Top;
      Width:= ScrolledImages.ScrolledImage[AWhat].Width;
      Height:= ScrolledImages.ScrolledImage[AWhat].Height;
    end;
  end;
  LDesc.Caption:= AMsg;
end;

procedure TFormMain.LoadFiles(AFiles: TStrings);
begin
  ScrolledImages.OnProgress:= ScrollImagesOnProgressEvent;
  ScrollBoxLeft.Visible:= False;
  ScrolledWBMPs.ImagesCount:= AFiles.Count;
  ScrolledImages.LoadFiles(AFiles, 0, ScrollBoxLeft.Width div 2);
  ScrollBoxLeft.Visible:= True;
end;

procedure SearchImageFiles(AFolder: String; AExtensions, ACurDirImageFileNames: TStrings);
var
  FindFileData: Windows._WIN32_FIND_DATAA;
  hFindFile: THandle;
  fn: String;
begin
  if Assigned(AExtensions)
  then ACurDirImageFileNames.Clear;

  hFindFile:= Windows.FindFirstFile(PChar(ConcatPath(AFolder, '*.*')), FindFileData);
  if hFindFile = INVALID_HANDLE_VALUE
  then Exit;

  if Assigned(AExtensions) then begin
    repeat
      if ((FILE_ATTRIBUTE_DIRECTORY+FILE_ATTRIBUTE_HIDDEN+FILE_ATTRIBUTE_OFFLINE+FILE_ATTRIBUTE_TEMPORARY+FILE_ATTRIBUTE_SYSTEM) and FindFileData.dwFileAttributes) = 0 then begin
        fn:= ExtractFileExt(FindFileData.cFileName); // contains dot "."
        if AExtensions.IndexOf(fn) >= 0
        then ACurDirImageFileNames.Add(ConcatPath(AFolder, FindFileData.cFileName));
      end;
    until not Windows.FindNextFile(hFindFile, FindFileData);
  end else begin
    repeat
      if ((FILE_ATTRIBUTE_DIRECTORY+FILE_ATTRIBUTE_HIDDEN+FILE_ATTRIBUTE_OFFLINE+FILE_ATTRIBUTE_TEMPORARY+FILE_ATTRIBUTE_SYSTEM) and FindFileData.dwFileAttributes) = 0 then begin
        ACurDirImageFileNames.Add(ConcatPath(AFolder, FindFileData.cFileName));
      end;
    until not Windows.FindNextFile(hFindFile, FindFileData);
  end;
  Windows.FindClose(hFindFile);
end;

procedure TFormMain.LoadFilesInFolder(AFolder: String);
begin
  ScrolledImages.TerminateLoad;
  ScrolledImages.TerminateDither;
  ScrolledWBMPs.TerminateLoad;
  ScrolledWBMPs.TerminateDither;

  if Assigned(ScrolledImages.LoaderThread)
  then Exit;

  SearchImageFiles(AFolder, FFileFormatsList, FCurDirImageFileNames);
  ScrolledImages.OnProgress:= ScrollImagesOnProgressEvent;
  ScrollBoxLeft.Visible:= False;
  ScrolledWBMPs.ImagesCount:= FCurDirImageFileNames.Count;
  ScrolledImages.LoadFiles(FCurDirImageFileNames, 0, ScrollBoxLeft.Width div 2);
  ScrollBoxLeft.Visible:= True;
end;

procedure TFormMain.OnTerminateLoad(Sender: TObject);
begin
//   DoResize(ScrolledImages, ScrolledImages.ImageMaxWidth);
  // allow commands:
  EnableActionsByTag(1, True);
  ScrolledImages.LoaderThread:= Nil;

  // dither
  if SettingsAutoDither.Checked
  then FileConvertAllExecute(Self);

  LDesc.Caption:= Format('%d image(s) loaded', [ScrolledImages.ImagesCount]);
end;

procedure TFormMain.OnTerminateDither(Sender: TObject);
begin
  // DoResize(ScrolledWBmps.CurImage, ScrolledImages.ImageMaxWidth);
  // allow commands:
  EnableActionsByTag(1+2, True);
  ScrolledWBMPs.DitherThread:= Nil;
  // start converting?
  LDesc.Caption:= Format('%d image(s) dithered', [ScrolledImages.ImagesCount]);
end;

procedure TFormMain.CMDialogkey;
 begin
   with ScrollBoxLeft.VertScrollBar do begin
     case Msg.CharCode of
       // Delphi takes care of Position < 0 or Position > Range
        VK_DOWN: Position:= Position + Increment; // down arrow key
        VK_UP: Position:= Position - Increment; // up arrow key
      else
         inherited;
     end;
   end;
 end;

procedure TFormMain.ScrollBoxWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBoxLeft.VertScrollBar do begin
    Position:= Position - Increment;
  end;
end;

procedure TFormMain.ScrollBoxWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBoxLeft.VertScrollBar do begin
    Position:= Position + Increment;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  R: TStrings;
begin
  FirstActivate:= True;
  R:= TStringList.Create;
  FParameters:= TStringList.Create;
  FDitherMode:= dmNearest;
  CBDitherMode.ItemIndex:= Ord(FDitherMode);
  // GetStringsFromGraphicFilter(Graphics.GraphicFilter(TGraphic), 0, R);
  // GIFIMAGE DISABLED IN THIS VERSION
  GetStringsFromGraphicFilter('All (*.jpg;*.jpeg;*.bmp;*.ico;*.emf;*.wmf;*.png;*.gif)|*.jpg;*.jpeg;*.bmp;*.ico;*.emf;*.wmf;*.png;*.gif|'+
    'WBMP Image (*.wbmp)|*.wbmp|JPEG Image File (*.jpeg;*.jpg)|*.jpeg;*.jpg|PNG Image File (*.png)|*.png|GIF Image File (*.gif)|*.gif|MS Win Bitmaps (*.bmp)|*.bmp|'+
    'Icons (*.ico)|*.ico|Enhanced Metafiles (*.emf)|*.emf|Metafiles (*.wmf)|*.wmf', 0, R);
  FolderTree0:= TrtcFolderTree.Create(Self);
  with FolderTree0 do begin
    OnChange:= FolderTreeChange;
    Parent:= PanelLeft;
    Name:= 'FolderTree0';
    Align:= alClient;
    FolderOptions:= [foMyComputer, foNetworkNeighborhood, foVirtualFirst];  //foFTPSite,
    Active:= True;
    DragKind:= dkDock;
    // DragMode:= dmAutomatic;
    UseDockManager:= False;
  end;
  // foFTPSite, foDatabase,
  CBFilter.Items.Assign(R);
  R.Clear;
  
  CBFilter.ItemIndex:= 0;
  FCurDirImageFileNames:= TStringList.Create;
  FFileFormatsList:= TStringList.Create;
  actRebuildFileFilterExecute(Self);

  WBmp:= TWBMPImage.Create;
  if not FRegistered
  then WBmp.TransformOptions:= WBmp.TransformOptions + [toUnregistered];

  ScrolledImages:= TScrolledImages.Create(ScrollBoxLeft, ScrollBoxLeft, Nil, OnTerminateLoad, OnTerminateDither, ImageList1);
  ScrolledWBMPs:= TScrolledImages.Create(ScrollBoxLeft, ScrollBoxLeft, Nil, OnTerminateLoad, OnTerminateDither, ImageList1);
  // wheels

  ScrollBoxLeft.OnMouseWheelDown:= ScrollBoxWheelDown;
  ScrollBoxLeft.OnMouseWheelUp:= ScrollBoxWheelUp;
  
  // assign OnClick handler
  ScrolledImages.OnClick:= OnClickImage;
  ScrolledWBMPs.OnClick:= OnClickImage;
  OpenPictureDialog1:= ExtDlgs.TOpenPictureDialog.Create(Self);
  SavePictureDialog1:= ExtDlgs.TSavePictureDialog.Create(Self);
  FolderBrowseDialog:= TFolderBrowseDialog.Create(Self);

  SaveDialog1:= TSaveDialog.Create(Self);
  LoadIni;
  //
  FormMain.Width:= StrToIntDef(GetToken(1, 'x', FParameters.Values[ParameterNames[ID_FormSizeXY]]),
    FormMain.Width);
  FormMain.Height:= StrToIntDef(GetToken(2, 'x', FParameters.Values[ParameterNames[ID_FormSizeXY]]),
    FormMain.Height);

  FolderTree0.Width:= StrToIntDef(FParameters.Values[ParameterNames[ID_FolderTreeX]], FolderTree0.Width);
  PanelLeft.Width:= StrToIntDef(FParameters.Values[ParameterNames[ID_PanelLeftX]], PanelLeft.Width);
  FolderTree0.Height:= StrToIntDef(FParameters.Values[ParameterNames[ID_DirectoryHeight]], FolderTree0.Height);

  // ID_Stretch, ID_Align8bit, ID_AppendText, ID_AutoDither
  // set default values
  if FParameters.Values[ParameterNames[ID_Align8bit]] = ''
  then FParameters.Values[ParameterNames[ID_Align8bit]]:= '1';
  if FParameters.Values[ParameterNames[ID_Negative]] = ''
  then FParameters.Values[ParameterNames[ID_Negative]]:= '0';
  if FParameters.Values[ParameterNames[ID_AutoDither]] = ''
  then FParameters.Values[ParameterNames[ID_AutoDither]]:= '1';
  MSettingsViewStretch.Checked:= FParameters.Values[ParameterNames[ID_Stretch]] = '1';
  SettingsAlign8bit.Checked:= FParameters.Values[ParameterNames[ID_Align8bit]] = '1';
  SettingsNegative.Checked:= FParameters.Values[ParameterNames[ID_Negative]] = '1';
  SettingsAppendText.Checked:= FParameters.Values[ParameterNames[ID_AppendText]] = '1';
  SettingsAutoDither.Checked:= FParameters.Values[ParameterNames[ID_AutoDither]] = '1';

  if SettingsNegative.Checked then WBmp.TransformOptions:= WBmp.TransformOptions + [toNegative];
  if not SettingsAlign8Bit.Checked then WBmp.TransformOptions:= WBmp.TransformOptions - [toAlign8];

  if FParameters.Values[ParameterNames[ID_Directory]] = ''
  then FParameters.Values[ParameterNames[ID_Directory]]:= SysUtils.GetCurrentDir;
  // ads
  CreateBanner(PanelTop);
  // validate license
  actValidateCodeExecute(Self);
  R.Free;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FBanner.Free;
  StoreIni(0);
  FolderTree0.Free;
  SaveDialog1.Free;
  FolderBrowseDialog.Free;
  SavePictureDialog1.Free;
  OpenPictureDialog1.Free;
  ScrolledWBMPs.Free;
  ScrolledImages.Free;
  WBmp.Free;
  FFileFormatsList.Free;
  FCurDirImageFileNames.Free;
  FParameters.Free;
end;

procedure TFormMain.FileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FileOpenExecute(Sender: TObject);
begin
  with OpenPictureDialog1 do begin
    // Set filter to all supported image formats
    Filter:= GraphicFilter(TGraphic);
    DefaultExt:= GraphicExtension(TGIFImage);
    // InitialDir:= '';
     // Use buffering since we have no control over the preview canvas.
    Exclude(GIFImageDefaultDrawOptions, goDirectDraw);
    Options:= Options+ [ofAllowMultiSelect];
    try
      if Execute then begin
        LoadFiles(Files);
      end;
    finally
      Include(GIFImageDefaultDrawOptions, goDirectDraw);
    end;
  end;
end;

procedure TFormMain.FileSaveAsExecute(Sender: TObject);
begin
  with SavePictureDialog1 do begin
    // Set filter to all supported image formats
    Filter:= 'WBMP|*.wbmp'; // GraphicFilter(TGraphic);
    DefaultExt:= '.wbmp';
     // Use buffering since we have no control over the preview canvas.
    Exclude(GIFImageDefaultDrawOptions, goDirectDraw);
    try
      if Execute then begin
        EnableActionsByTag(4, True);
        FFileNameOut:= FileName;
        FileSaveExecute(Sender);
      end;
    finally
      Include(GIFImageDefaultDrawOptions, goDirectDraw);
    end;
  end;
end;

procedure TFormMain.FileSaveExecute(Sender: TObject);
begin
  FileConvertExecute(Sender);
  WBMP.Assign(ScrolledWBMPs.CurImage.Picture.Graphic);
  Wbmp.SaveToFile(FFileNameOut);
end;

procedure TFormMain.FileConvertExecute(Sender: TObject);
begin
  if (not Assigned(ScrolledImages.CurImage)) or (not Assigned(ScrolledWBMPs.CurImage))
  then Exit;
  DoDither(ScrolledImages.CurImage, ScrolledWBMPs.CurImage, FDitherMode);
end;

procedure TFormMain.SettingsViewStretchExecute(Sender: TObject);
begin
  MSettingsViewStretch.Checked:= not MSettingsViewStretch.Checked;
  if MSettingsViewStretch.Checked
  then FParameters.Values[ParameterNames[ID_Stretch]]:= '1'
  else FParameters.Values[ParameterNames[ID_Stretch]]:= '0';
  // Image2.Stretch:= MSettingsViewStretch.Checked;
end;

procedure TFormMain.EditCopyExecute(Sender: TObject);
var
  ClpFormat : Word;
  ClpData: DWORD;
  ClpPalette : HPalette;
begin
//
//  Clipboard.Assign(Image1.Picture.Bitmap);
  if not Assigned(ScrolledImages.CurImage)
  then Exit;

  ScrolledImages.CurImage.Picture.Graphic.SaveToClipBoardFormat(ClpFormat, ClpData, ClpPalette);
  ClipBoard.SetAsHandle(ClpFormat, ClpData);
end;

procedure TFormMain.MEditPasteClick(Sender: TObject);
begin
  if not Assigned(ScrolledImages.CurImage)
  then Exit;

  if ClipBoard.HasFormat(CF_BITMAP)
  then ScrolledImages.CurImage.Picture.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(CF_BITMAP), 0);
end;

procedure TFormMain.MEditEditClick(Sender: TObject);
begin
  EditPaste.Enabled:= Clipboard.HasFormat(CF_WBMP) or Clipboard.HasFormat(CF_BITMAP);
end;

procedure TFormMain.SettingsAlign8bitExecute(Sender: TObject);
begin
  SettingsAlign8bit.Checked:= not SettingsAlign8bit.Checked;
  if SettingsAlign8bit.Checked
  then FParameters.Values[ParameterNames[ID_Align8Bit]]:= '1'
  else FParameters.Values[ParameterNames[ID_Align8Bit]]:= '0';

  if SettingsAlign8bit.Checked
  then WBmp.TransformOptions:= WBmp.TransformOptions + [toAlign8]
  else WBmp.TransformOptions:= WBmp.TransformOptions - [toAlign8];
end;

procedure TFormMain.SettingsNegativeExecute(Sender: TObject);
begin
  SettingsNegative.Checked:= not SettingsNegative.Checked;
  if SettingsNegative.Checked
  then FParameters.Values[ParameterNames[ID_Negative]]:= '1'
  else FParameters.Values[ParameterNames[ID_Negative]]:= '0';

  if SettingsNegative.Checked
  then WBmp.TransformOptions:= WBmp.TransformOptions + [toNegative]
  else WBmp.TransformOptions:= WBmp.TransformOptions - [toNegative];
end;

procedure TFormMain.CBDitherModeChange(Sender: TObject);
begin
  FDitherMode:= TDitherMode(CBDitherMode.ItemIndex);
  FileConvertAllExecute(Self);
end;

procedure TFormMain.HelpAboutExecute(Sender: TObject);
begin
  AboutBox:= FAbout.TAboutBox.Create(Self);
  if AboutBox.ShowModal = mrOk then begin
  end;
  AboutBox.Free;
end;

procedure TFormMain.FileSaveAsTextExecute(Sender: TObject);
begin
  with SaveDialog1 do begin
    // Set filter to all supported image formats
    Filter:= 'Text files (*.txt)|*.txt|All files (*.*)|*.*';
    DefaultExt:= '.txt';
    try
      if Execute then begin
        EnableActionsByTag(8, True);
        FFileNameAsTextOut:= FileName;
        FileSaveAsAsTextExecute(Self);
      end;
    finally
    end;
  end;
end;

procedure TFormMain.FileSaveAsAsTextExecute(Sender: TObject);
var
  Bitmap: TBitmap;
  S: String;
  OFile: TFileStream;
begin
  FileConvertExecute(Sender);
  // save converted file to plain text file FFileNameAsTextOut
  Bitmap:= TBitmap.Create;
  Bitmap.Assign(ScrolledWBMPs.CurImage.Picture.Graphic);
  s:= asciipic.Bitmap2ASCII(Bitmap, asciipic.GrayScaleChars1);
  // util1.String2File(FFileNameAsTextOut, S);
  try
    if FileExists(FFileNameAsTextOut) and (FParameters.Values[ParameterNames[ID_AppendText]] = '1') then begin
      OFile:= TFileStream.Create(FFileNameAsTextOut, fmOpenReadWrite);
      OFile.Position:= OFile.Size;
    end else begin
      OFile:= TFileStream.Create(FFileNameAsTextOut, fmCreate);
    end;
    OFile.Write(S[1], Length(S));
    OFile.Free;
  finally
  end;
  Bitmap.Free;
end;

procedure TFormMain.SettingsAppendTextExecute(Sender: TObject);
begin
  SettingsAppendText.Checked:= not SettingsAppendText.Checked;
  if SettingsAppendText.Checked
  then FParameters.Values[ParameterNames[ID_AppendText]]:= '1'
  else FParameters.Values[ParameterNames[ID_AppendText]]:= '0';
end;

procedure TFormMain.FileViewTextExecute(Sender: TObject);
begin
  util1.EExecuteFile(FFileNameAsTextOut);
end;

procedure TFormMain.SplitterVertMoved(Sender: TObject);
begin
  // save tree position
  FParameters.Values[ParameterNames[ID_FolderTreeX]]:= IntToStr(FolderTree0.Width);
  FParameters.Values[ParameterNames[ID_PanelLeftX]]:= IntToStr(PanelLeft.Width);
  if not Assigned(ScrolledImages.CurImage)
  then Exit;
  // DoResize(ScrolledImages, ScrolledImages.ImageMaxWidth);
end;

{$IFDEF USE_TWAIN}
procedure TFormMain.FileScanExecute(Sender: TObject);
const
  TMPBITMAPFN = 'ScannedImage.bmp';
var
  i, dibsCount: Integer;
  TestDib: THandle;
begin
  if TWAIN_SelectImageSource(0) = 0
  then Exit;
  TWAIN_AcquireNative(0, 0);    // hdib:=
  dibsCount:= TWAIN_GetNumDibs;
  // set new images
  ScrolledImages.ImagesCount:= dibsCount;
  for i:= 0 to dibsCount - 1 do begin
    TestDib:= TWAIN_GetDib(0);
    CopyDibIntoImage(TestDib, ScrolledImages.CurImage);
    ScrolledImages.CurImage.Picture.SaveToFile(TMPBITMAPFN);
    TWAIN_FreeNative(TestDib);
  end;
  // clear temporary file
  // if dibsCount > 0 then DeleteFile(TMPFOLDER+TMPBITMAP);
  //?!!
    DoResize(ScrolledImages, ScrolledImages.ImageMaxWidth);
  // allow commands:
  EnableActionsByTag($10, True);
  ScrolledImages.LoaderThread:= Nil;

  // dither
  if FParameters.Values[ParameterNames[ID_AutoDither]] = '1'
  then FileConvertAllExecute(Self);

  EnableActionsByTag(2, True);
end;

{$ELSE}

procedure TFormMain.FileScanExecute(Sender: TObject);
begin
  //
end;
{$ENDIF}

procedure TFormMain.HelpRegisterExecute(Sender: TObject);
begin
  //
  if (not FRegistered) or (MessageDlg(Format('Your program %s is licensed to %s.'#13#10+
      'Do you want continue anyway?', [PROG_NAME, FParameters.Values[ParameterNames[ID_USER]]]), mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin
    FormRegister:= TFormRegister.Create(Self);
    if FormRegister.ShowModal = mrOK then with FParameters, FormRegister do begin
      // ActEnterCodeExecute; Values[ParameterNames[ID_USER]]:= EUserName.Text;      Values[ParameterNames[ID_CODE]]:= ERegCode.Text;
    end;
    FormRegister.Free;
  end;
end;

procedure TFormMain.actRegisterGoWebExecute(Sender: TObject);
begin
  //
  util1.EExecuteFile(REGISTER_URL);
end;

procedure TFormMain.actHowToRegisterExecute(Sender: TObject);
begin
  //
  util1.EExecuteFile(REGISTER_HOWTO_URL);
end;

procedure TFormMain.FileConvertAllExecute(Sender: TObject);
begin
  EnableActionsByTag(2+8, False);
  // EnableActionsByTag(1, True);
  ScrolledWBMPs.Dither(ScrolledImages, FDitherMode, ScrollBoxLeft.Width div 2, ScrollBoxLeft.Width div 2);
end;

procedure TFormMain.SettingsAutoDitherExecute(Sender: TObject);
begin
  SettingsAutoDither.Checked:= not SettingsAutoDither.Checked;
  if SettingsAutoDither.Checked
  then FParameters.Values[ParameterNames[ID_AutoDither]]:= '1'
  else FParameters.Values[ParameterNames[ID_AutoDither]]:= '0';
end;

procedure TFormMain.OnClickImage(Sender: TObject);
begin
  //  sender is TScrolledImage
  if Sender is TScrolledImage then with Sender as TScrolledImage do begin
    ScrolledWBMPs.CurImageNo:= (Sender as TScrolledImage).Id;
    ScrolledImages.CurImageNo:= (Sender as TScrolledImage).Id;
  end;
end;

procedure TFormMain.FileSaveAllExecute(Sender: TObject);
var
  i: Integer;
begin
  if not FRegistered then begin
    WarningIsNotRegistered;
    Exit;
  end;
  // save all wbmp images
  // choose folder
  with FolderBrowseDialog do begin
    Title:= 'Choose folder to store converted WBMPs';
    // Directory:= '';
    if Execute(Self) then begin
      EnableActionsByTag(4, False);  // disable save (FFileNameOut corrupted)
      for i:= 0 to ScrolledImages.ImagesCount - 1 do begin
        ScrolledImages.CurImageNo:= i;
        FFileNameOut:= ConcatPath(Directory, ReplaceExt('.wbmp', ScrolledImages.ScrolledImage[i].FileName));
        FileSaveExecute(Sender);
      end;
    end;
  end;
end;

procedure TFormMain.actChangeFilterExecute(Sender: TObject);
begin
  actRebuildFileFilterExecute(Self);
  DirRefreshExecute(Self);
end;

procedure TFormMain.actEnterCodeExecute(Sender: TObject);
begin
  // store entered code and validate
  FParameters.Values[ParameterNames[ID_USER]]:= FormRegister.EUserName.Text;
  FParameters.Values[ParameterNames[ID_CODE]]:= FormRegister.ERegCode.Text;
  // store ini
  StoreIni(1);
  // validate
  actValidateCodeExecute(Self);
  if FRegistered then begin
    ShowWarnings('Thank you!', SMSG_THANKS);
  end else begin
    ShowWarnings('Misprint', SMSG_INVALIDKEY);
  end;
end;

procedure TFormMain.actRebuildFileFilterExecute(Sender: TObject);
var
  R: TStrings;
begin
  R:= TStringList.Create;
  GetStringsFromGraphicFilter(CBFilter.Text, 2, R);
  FFileFormatsList.Assign(R);
  R.Free;
end;

procedure TFormMain.HelpWhatNewExecute(Sender: TObject);
begin
  if FileExists(REGISTER_README)
  then util1.EExecuteFile(REGISTER_README)
  else begin
    if MessageDlg(Format('Can''t find %s.'#13#10'Do you want visit CVRT2WBMP home page'#13#10+
      '%s'#13#10'right now?', [REGISTER_README, REGISTER_HOME_URL]),
      mtConfirmation, [mbYes, mbNo], 0) = mrYes
    then util1.EExecuteFile(REGISTER_HOME_URL)
  end;
end;

procedure TFormMain.HelpHowToRegisterExecute(Sender: TObject);
begin
  if FileExists(REGISTER_README)
  then util1.EExecuteFile(REGISTER_README)
  else begin
    if MessageDlg(Format('Can''t find %s.'#13#10'Do you want visit CVRT2WBMP home page'#13#10+
      '%s'#13#10'right now?', [REGISTER_README, REGISTER_HOME_URL]),
      mtConfirmation, [mbYes, mbNo], 0) = mrYes
    then util1.EExecuteFile(REGISTER_HOME_URL)
  end;
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  FParameters.Values[ParameterNames[ID_FormSizeXY]]:= Format('%dx%d', [Self.Width, Self.Height]);
  CenterX(PanelTop.Width, FBanner);
end;

// validate registration code
procedure TFormMain.actValidateCodeExecute(Sender: TObject);
var
  S: String;
begin
  // calculate hash
  S:= 'enzi' + 'cvrt2wbmp' + FParameters.Values[ParameterNames[ID_USER]];
  FRegistered:= FParameters.Values[ParameterNames[ID_CODE]] = secure.GetMD5Digest(PChar(S), Length(S), 36);
  if FRegistered then begin
    Caption:= APPNAME + ' v.'+ LNVERSION;
    PanelTop.Height:= 25;
    Timer1.Enabled:= False;
  end else begin
    Caption:= APPNAME + ', evaluation version '+ LNVERSION;
    // show ads
    PanelTop.Height:= 86;
    CenterX(PanelTop.Width, FBanner);
//    Timer1.Enabled:= True;  GIF ERROR
  end;
end;

procedure TFormMain.CreateBanner(AControl: TControl);
begin
  FBanner:= THttpGifLoader.Create(Self);
  with FBanner do begin
    Parent:= TWinControl(AControl);
    Top:= 25;
    Width:= 468;
    Height:= 60;
    CenterX(AControl.Width, FBanner);
    url:= MyBannerImg;
    Stretch:= True;
    Hint:= MyBannerHint;
    Cursor:= crHandPoint;
    OnClick:= OnClickFBanner;
    ReadProxySettings;
    NextTimeOutSec:= 120;
    TimeOutSec:= NextTimeOutSec div 2;
    AdsText(468, 60, 'WBMP convertor', Picture);
    // Picture.LoadFromFile('banner.gif');
  end;
end;

procedure TFormMain.OnClickFBanner(Sender: TObject);
begin
  util1.EExecuteFile(MyBannerHref);
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
var
  S: String;
begin
  if popShowBanner.Checked then begin
    FBanner.Started:= (not FRegistered) and util1.IsIPPresent;
  end else begin
    DateTimeToString(S, LongDateFormat, Now);
    AdsText(468, 60, S, FBanner.Picture);
  end;
end;

procedure TFormMain.actShowTextNoBannerExecute(Sender: TObject);
begin
  // do not show banner
end;

procedure TFormMain.actShowBannerNoTextExecute(Sender: TObject);
begin
  // show banner
end;

procedure TFormMain.popShowBannerClick(Sender: TObject);
begin
  popShowBanner.Checked:= not popShowBanner.Checked;
  if popShowBanner.Checked then begin
    actShowBannerNoTextExecute(Self)
  end else begin
    actShowTextNoBannerExecute(Self);
    WarningIsNotRegistered;
    AdsText(468, 60, 'WBMP convertor', FBanner.Picture);
  end;
end;

procedure TFormMain.DirRefreshExecute(Sender: TObject);
begin
  // reload images
  FParameters.Values[ParameterNames[ID_Directory]]:= FolderTree0.Directory;
  EnableActionsByTag(2, False);
  if FirstActivate
  then FirstActivate:= False
  else LoadFilesInFolder(FolderTree0.Directory);
end;

procedure TFormMain.FolderTreeChange(Sender: TObject; Node: TTreeNode);
begin
  DirRefreshExecute(Self);
end;

procedure TFormMain.SplitterEditMoved(Sender: TObject);
begin
  FParameters.Values[ParameterNames[ID_DirectoryHeight]]:= IntToStr(FolderTree0.Height);
end;

procedure TFormMain.actIntergateShellExecute(Sender: TObject);
begin
  // Windows Explorer shell integration
end;

procedure TFormMain.SettingsFileAssociationsExecute(Sender: TObject);
var
  i: Integer;
  R: TStrings;
begin
  FormFileAssociations:= TFormFileAssociations.Create(Self);
  R:= TStringList.Create;
  with FormFileAssociations do begin
    CheckListBoxFileTypes.Items.Assign(CBFilter.Items);
    CheckListBoxFileTypes.Items.Delete(0);
    if ShowModal = mrOk then with CheckListBoxFileTypes do begin
      for i:= 0 to Items.Count - 1 do begin
        if Checked[i] then begin
          R.Clear;
          GetStringsFromGraphicFilter(CheckListBoxFileTypes.Items[i], 2, R);
          utilwin.InstallFileExt(R[0], '2wbmp'+R[0], '2wbmp image', 0,
            '2bmpView', 'View with cvrt2wbmp', Application.ExeName, '%1',
            'cvrt2wbmp', 'System', 'fileopen("%1")', False, False);
        end;
      end;
    end;
  end;
  R.Free;
  FormFileAssociations.Free;
end;

procedure TFormMain.actParseCommandLineExecute(Sender: TObject);
var
  HaveFolder: Integer;
  p: Integer;
  R: TStrings;
begin
  R:= TStringList.Create;
  if ParamCount = 0 then begin
    FirstActivate:= False; // allow to load directory
    FolderTree0.Directory:= FParameters.Values[ParameterNames[ID_Directory]];
  end else begin
    // parse command line
    HaveFolder:= 0;
    for p:= 1 to ParamCount do begin
      if FileCtrl.DirectoryExists(ParamStr(p)) then begin
        HaveFolder:= p;
        Break;
      end else begin
        if FileExists(ParamStr(p))
        then R.Add(ParamStr(p));
      end;
    end;
    if HaveFolder>0 then begin
      FirstActivate:= False; // allow to load directory
      FolderTree0.Directory:= ParamStr(HaveFolder);
    end
    else LoadFiles(R);
  end;
  R.Free;
end;

procedure TFormMain.FormActivate(Sender: TObject);
begin
  if FirstActivate then begin
    actParseCommandLineExecute(Self);
    // FirstActivate set to false in actDirRefreshExecute()
  end;
end;

procedure TFormMain.SystemExecuteMacro(Sender: TObject; Msg: TStrings);
var
  i, p0, p1: Integer;
  cmd, Macro: String;
  R: TStrings;
begin
  // open files thru DDE
  R:= TStringList.Create;
  for i:= 0 to Msg.Count - 1 do begin
    // parse command - 1. macro name 2. parameter list ("par 1", "par 2")
    Macro:= Trim(Msg[i]);
    p0:= Pos('(', Macro);
    p1:= Pos(')', Macro);
    if (p0 = 0) or (p0 >= p1)
    then Break;
    cmd:= Trim(Copy(Macro, 1, p0-1));
    // get list of parameters
    R.CommaText:= Trim(Copy(Macro, p0+1, p1-p0-1));
    if AnsiCompareText(cmd, 'fileopen') = 0 then begin
      LoadFiles(R);
    end;
    if AnsiCompareText(cmd, 'folderopen') = 0 then begin
      if R.Count > 0
      then FolderTree0.Directory:= R[0];
    end;
  end;
  R.Free;
end;


end.
