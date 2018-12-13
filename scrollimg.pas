unit scrollimg;
(*##*)
(*******************************************************************************
*                                                                              *
*   S  C  R  O  L  I  M  G                                                    *
*   image collections, part of CVRT2WBMP                                       *
*                                                                             *
*   Copyright (c) 2001-2008 Andrei Ivanov. All rights reserved.                *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   History                                                                    *
*           Jun 07 2001                                                       *
*           May 01 2008                                                        *
*                                                                             *
*   Lines        :                                                             *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Classes, SysUtils, Controls, StdCtrls, ExtCtrls, Graphics,
  GifImage, wbmpimage;

type
  TScrolledImagesProgressEvent = procedure (Sender: TObject; AWhat: Integer; const Msg: string) of object;

  TImageLoaderInfo = record
    Name: String[255];
    No: Integer;
    R: TRect;
  end;

  TScrolledImage = class(TObject)
  private
    FOwner: TComponent;
    FParent: TWinControl;
    FImageList: TImageList;
    FOnClick: TNotifyEvent;
    FId: Integer;
    FPanBitmap: TBitmap;
    FFileName: String;
    function GetLeft: Integer;
    procedure SetLeft(ALeft: Integer);
    function GetTop: Integer;
    procedure SetTop(ATop: Integer);
    function GetWidth: Integer;
    procedure SetWidth(AWidth: Integer);
    function GetHeight: Integer;
    procedure SetHeight(AHeight: Integer);
    function GetVisible: Boolean;
    procedure SetVisible(AVisible: Boolean);
    procedure RedirectClick(Sender: TObject);
  public
    Pnl: TPanel;
    Img: TImage;
    constructor Create(AOwner: TComponent; AParent: TWinControl; APanBitmap: TBitmap; AImageList: TImageList; AOnClick: TNotifyEvent);
    destructor Destroy; override;
    procedure LoadFromFile(var AImageLoaderInfo: TImageLoaderInfo);
    property FileName: String read FFileName;
  published
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Visible: Boolean read GetVisible write SetVisible;
    property Id: Integer read FId write FId;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TScrolledImages = class;

  TScrolledImagesLoaderThread = class (TThread)
  private
    FLoadLeft,
    FLoadWidth: Integer;
    FImageLoaderInfo: TImageLoaderInfo;
    FScrolledImages: TScrolledImages;
    FFiles: TStrings;
  public
    constructor Start(ACreateSuspended: Boolean; AScrolledImages: TScrolledImages;
      AFiles: TStrings; ALoadLeft, ALoadWidth: Integer);
    procedure Execute; override;
    procedure LoadImageToForm;  // uses FCurrentLoadImageNo inside TThread.Synchronize method
  end;

  TScrolledImagesDitherThread = class (TThread)
  private
    FLoadLeft,
    FLoadWidth: Integer;
    FImageLoaderInfo: TImageLoaderInfo;
    FSrcScrolledImages,
    FDestScrolledImages: TScrolledImages;
    FDitherMode: TDitherMode;
  public
    constructor Start(ACreateSuspended: Boolean; ASrcScrolledImages, ADestScrolledImages: TScrolledImages;
      ADitherMode: TDitherMode; ALoadLeft, ALoadWidth: Integer);
    procedure Execute; override;
    procedure DitherImageToForm; // uses FCurrentDitherImageNo inside TThread.Synchronize method
  end;

  TScrolledImages = class (TObject)
  private
    FPanBitmap: TBitmap;
    FOnTerminateLoad: TNotifyEvent;
    FOnTerminateDither: TNotifyEvent;
    FLoaderThread: TScrolledImagesLoaderThread;
    FDitherThread: TScrolledImagesDitherThread;
    FOnProgress: TScrolledImagesProgressEvent;
    FOwner: TComponent;
    FParent: TWinControl;
    FCurImageNo: Integer;
    FImageList: TImageList;
    FScrolledImages: array of TScrolledImage;
    FOnClick: TNotifyEvent;
    function GetCurImage: TImage;
    procedure SetCurImageNo(ACurNo: Integer);
    function GetScrolledImage(AImgNo: Integer): TScrolledImage;
    function GetImage(AImgNo: Integer): TImage;
    function GetCurScrolledImage: TScrolledImage;
    function GetImagesCount: Integer;
    procedure SetImagesCount(ANewValue: Integer);
    function GetWidth: Integer;
    procedure SetWidth(AWidth: Integer);
  public
    constructor Create(AOwner: TComponent; AParent: TWinControl; APanBitmap: TBitmap;
      AOnTerminateLoad, AOnTerminateDither: TNotifyEvent; AImageList: TImageList);
    destructor Destroy; override;
    procedure LoadFiles(AFiles: TStrings; ALoadLeft, ALoadWidth: Integer);
    procedure Dither(ASrc: TScrolledImages; ADitherMode: TDitherMode;
      ALoadLeft, ALoadWidth: Integer);
    function TerminateLoad: Boolean;
    function TerminateDither: Boolean;
    function ImageMaxWidth: Integer;
    function GetImageNoByCoords(X, Y: Integer): Integer;
    procedure ArrangeImages;

    property ScrolledImage[AImgNo: Integer]: TScrolledImage read GetScrolledImage;
    property Image[AImgNo: Integer]: TImage read GetImage;
    property CurImageNo: Integer read FCurImageNo write SetCurImageNo;
    property CurScrolledImage: TScrolledImage read GetCurScrolledImage;
    property CurImage: TImage read GetCurImage;

    property LoaderThread: TScrolledImagesLoaderThread read FLoaderThread write FLoaderThread;
    property DitherThread: TScrolledImagesDitherThread read FDitherThread write FDitherThread;

    property ImagesCount: Integer read GetImagesCount write SetImagesCount;

    property OnProgress: TScrolledImagesProgressEvent read FOnProgress write FOnProgress;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property Width: Integer read GetWidth write SetWidth;
  end;

//------------------ utility functions ------------------

procedure DoDither(SrcImage, DestImage: TImage; ADitherMode: TDitherMode);

implementation

type
  BA = array[0..1] of Byte;
  LogPal = record
    lpal: TLogPalette;
    dummy: packed array[1..255] of TPaletteEntry;
  end;

//------------------ utility functions ------------------

procedure DoDither(SrcImage, DestImage: TImage; ADitherMode: TDitherMode);
const
  ColorReduction: TColorReduction = rmPalette; // rmMonochrome;
var
  SysPal: LogPal;
  TmpBitmap: TBitmap;
begin
  if not Assigned(SrcImage)
  then Exit;
  if not Assigned(DestImage)
  then Exit;

  SysPal.lPal.palVersion:= $300;
  SysPal.lPal.palNumEntries:= 2;
  with SysPal.lpal.palPalEntry[0] do begin
    peRed:= 0;
    peGreen:= 0;
    peBlue:= 0;
    peFlags:= PC_NOCOLLAPSE;
  end;
  with SysPal.dummy[1] do begin
    peRed:= $FF;
    peGreen:= $FF;
    peBlue:= $FF;
    peFlags:= PC_NOCOLLAPSE;
  end;
  TmpBitmap:= TBitmap.Create;
  with SrcImage.Picture do begin
    {
    if (Graphic is TMetafile) or (Graphic is TIcon) then begin
      TmpBitmap.Width:= Graphic.Width;
      TmpBitmap.Height:= Graphic.Height;
      TmpBitmap.Canvas.Draw(0, 0, Graphic);
    end else begin
      TmpBitmap.Assign(Graphic);
    end;
    }
    TmpBitmap.Width:= Graphic.Width;
    TmpBitmap.Height:= Graphic.Height;
    TmpBitmap.Canvas.Draw(0, 0, Graphic);
  end;
  TmpBitmap:= GifImage.ReduceColors(TmpBitmap, ColorReduction, ADitherMode, 1, CreatePalette(SysPal.lpal));
  with TmpBitmap do begin
    HandleType:= bmDIB;
    PixelFormat:= pf1bit;
    Palette:= CreatePalette(SysPal.lpal);
  end;
  DestImage.Picture.Assign(TmpBitmap);
  TmpBitmap.Free;
end;

//------------------ TScrolledImage ------------------

constructor TScrolledImage.Create(AOwner: TComponent; AParent: TWinControl;
  APanBitmap: TBitmap; AImageList: TImageList; AOnClick: TNotifyEvent);
begin
  inherited Create;
  FPanBitmap:= APanBitmap;

  FId:= -1;
  FOwner:= AOwner;
  FParent:= AParent;
  FImageList:= AImageList;

  Pnl:= TPanel.Create(AOwner);
  Pnl.Visible:= False;
  Pnl.Parent:= AParent;
  Pnl.Align:= alNone;

  Img:= TImage.Create(Pnl);
  Img.Parent:= Pnl;
  Img.Center:= True;
  Img.Stretch:= False;
  Img.Align:= alClient;

  Pnl.OnClick:= RedirectClick;
  Img.OnClick:= RedirectClick;
  FOnClick:= AOnClick;
end;

procedure TScrolledImage.RedirectClick(Sender: TObject);
begin
  if Assigned(FOnClick)
  then FOnClick(Self); // not Sender!
end;

function TScrolledImage.GetLeft: Integer;
begin
  Result:= Pnl.Left;
end;

procedure TScrolledImage.SetLeft(ALeft: Integer);
begin
  Pnl.Left:= ALeft;
  Img.Left:= Pnl.BevelWidth;
end;

function TScrolledImage.GetTop: Integer;
begin
  Result:= Pnl.Top;
end;

procedure TScrolledImage.SetTop(ATop: Integer);
begin
  Pnl.Top:= ATop;
  Img.Top:= Pnl.BevelWidth;
end;

function TScrolledImage.GetWidth: Integer;
begin
  Result:= Pnl.Width;
end;

procedure TScrolledImage.SetWidth(AWidth: Integer);
begin
  Pnl.Width:= AWidth;
  Img.Width:= Pnl.Width + 2 * (Pnl.BevelWidth + 1);
end;

function TScrolledImage.GetHeight: Integer;
begin
  Result:= Pnl.Height;
end;

procedure TScrolledImage.SetHeight(AHeight: Integer);
begin
  Pnl.Height:= AHeight;
  Img.Height:= Pnl.Height + 2 * (Pnl.BevelWidth + 1);
end;

function TScrolledImage.GetVisible: Boolean;
begin
  Result:= Pnl.Visible;
end;

procedure TScrolledImage.SetVisible(AVisible: Boolean);
begin
  Pnl.Visible:= AVisible;
end;

procedure TScrolledImage.LoadFromFile(var AImageLoaderInfo: TImageLoaderInfo);
var
  x, y: Integer;
begin
  FFileName:= AImageLoaderInfo.Name;
  Img.Picture.LoadFromFile(FFileName);
  {
  x:= (FPanImage.Width - Img.Picture.Graphic.Width) div 2;
  y:= FPanImage.Height;
  FPanImage.Height:= FPanImage.Height + 2 * Img.Picture.Graphic.Height;
  FPanImage.Canvas.Draw(x, y, Img.Picture.Graphic);
  }
  Left:= AImageLoaderInfo.R.Left;
  Top:= AImageLoaderInfo.R.Top;
//  Width:= Img.Picture.Graphic.Width + 2 * (Pnl.BevelWidth + 1);
  Width:= AImageLoaderInfo.R.Right;
  Height:= Img.Picture.Graphic.Height + 2 * (Pnl.BevelWidth + 1);

  AImageLoaderInfo.R.Top:= Top + Height;

  Img.Hint:= Format('%s'#13#10'%dx%d', [ExtractFileName(AImageLoaderInfo.Name),
    Img.Picture.Width, Img.Picture.Height]);
  Img.ShowHint:= True;
end;

destructor TScrolledImage.Destroy;
begin
  // Lbl and Img is child of Pnl, so can do Pnl.Free
  Img.Free;
  Pnl.Free;
  inherited Destroy;
end;

//------------------ TScrolledImagesLoaderThread ------------------

constructor TScrolledImagesLoaderThread.Start(ACreateSuspended: Boolean; AScrolledImages: TScrolledImages;
      AFiles: TStrings; ALoadLeft, ALoadWidth: Integer);
begin
  FScrolledImages:= AScrolledImages;
  FFiles:= AFiles;
  FLoadLeft:= ALoadLeft;
  FLoadWidth:= ALoadWidth;
  inherited Create(ACreateSuspended);
end;

// uses FCurrentLoadImageNo inside TThread.Synchronize method
procedure TScrolledImagesLoaderThread.LoadImageToForm;
begin
  with FScrolledImages.ScrolledImage[FImageLoaderInfo.No] do begin
    try
      LoadFromFile(FImageLoaderInfo);
      if Assigned(FScrolledImages.FOnProgress) then begin
        with Img.Picture do if Graphic is TMetafile then begin
          FScrolledImages.FOnProgress(Self, FImageLoaderInfo.No, Format('%s %s %dx%d', [TMetafile(Graphic).Description,
            TMetafile(Graphic).CreatedBy, Graphic.Width, Graphic.Height]));
        end else begin
          FScrolledImages.FOnProgress(Self, FImageLoaderInfo.No, Format('%dx%d', [Graphic.Width, Graphic.Height]));
        end;
      end;
    except
      if Assigned(FScrolledImages.FOnProgress) then begin
        FScrolledImages.FOnProgress(Self, -1, Format('; Broken file %s', [FImageLoaderInfo.Name]));
      end;
    end;
  end;
end;

procedure TScrolledImagesLoaderThread.Execute;
var
  f: Integer;
begin
  with FImageLoaderInfo do begin
    R.Left:= FLoadLeft;
    R.Top:= 0;
    R.Right:= FLoadWidth;
    R.Bottom:= 0; // FScrolledImages.Height;
  end;
  with FScrolledImages do begin
    // ImagesCount:= FFiles.Count; - cannot create win controls from thread: HWND loss.
    for f:= 0 to ImagesCount - 1 do begin
      if Terminated
      then Break;
      with FImageLoaderInfo do begin
        No:= f;  // pass parameters thru record
        Name:= FFiles[f];
      end;
      if FileExists(FImageLoaderInfo.Name) then begin
        Synchronize(LoadImageToForm);
      end else begin
        if Assigned(FOnProgress) then begin
          FOnProgress(Self, -1, Format('Load %s with errors', [FImageLoaderInfo.Name]));
        end;
        CurImage.Picture.Bitmap.FreeImage;
      end;
    end;
  end;
end;

//------------------ TScrolledImagesDitherThread ------------------

constructor TScrolledImagesDitherThread.Start(ACreateSuspended: Boolean; ASrcScrolledImages, ADestScrolledImages: TScrolledImages;
  ADitherMode: TDitherMode; ALoadLeft, ALoadWidth: Integer);
begin
  FSrcScrolledImages:= ASrcScrolledImages;
  FDestScrolledImages:= ADestScrolledImages;
  FDitherMode:= ADitherMode;
  FLoadLeft:= ALoadLeft;
  FLoadWidth:= ALoadWidth;
  inherited Create(ACreateSuspended);
end;

// uses FCurrentDitherImageNo inside TThread.Synchronize method
procedure TScrolledImagesDitherThread.DitherImageToForm;
begin
  try
    DoDither(FSrcScrolledImages.Image[FImageLoaderInfo.No],
      FDestScrolledImages.Image[FImageLoaderInfo.No], FDitherMode);
    if Assigned(FDestScrolledImages.FOnProgress) then begin
      with FDestScrolledImages.ScrolledImage[FImageLoaderInfo.No].Img.Picture do if Graphic is TMetafile then begin
        FDestScrolledImages.FOnProgress(Self, FImageLoaderInfo.No, Format('%s %s %dx%d', [TMetafile(Graphic).Description,
          TMetafile(Graphic).CreatedBy, Graphic.Width, Graphic.Height]));
      end else begin
        FDestScrolledImages.FOnProgress(Self, FImageLoaderInfo.No, Format('%dx%d', [Graphic.Width, Graphic.Height]));
      end;
    end;
  except
    if Assigned(FDestScrolledImages.FOnProgress) then begin
      FDestScrolledImages.FOnProgress(Self, -1, Format('; Cannot dither %d', [FImageLoaderInfo.No]));
    end;
  end;
end;

procedure TScrolledImagesDitherThread.Execute;
var
  f: Integer;
begin
  with FDestScrolledImages do begin
    // ImagesCount:= FFiles.Count; - cannot create win controls from thread: HWND loss.
    for f:= 0 to ImagesCount - 1 do begin
      if Terminated
      then Break;
      FImageLoaderInfo.No:= f;
      Synchronize(DitherImageToForm); // uses FCurrentDitherImageNo inside TThread.Synchronize method
    end;
  end;
end;

//------------------ TScrolledImages ------------------

constructor TScrolledImages.Create(AOwner: TComponent; AParent: TWinControl;
  APanBitmap: TBitmap; AOnTerminateLoad, AOnTerminateDither: TNotifyEvent; AImageList: TImageList);
begin
  inherited Create;
  FPanBitmap:= APanBitmap;
  FOnTerminateLoad:= AOnTerminateLoad;
  FOnTerminateDither:= AOnTerminateDither;
  FOwner:= AOwner;
  FParent:= AParent;
  FImageList:= AImageList;
  SetLength(FScrolledImages, 0);
  FLoaderThread:= Nil;
  FDitherThread:= Nil;
  FOnClick:= Nil;
end;

destructor TScrolledImages.Destroy;
begin
  TerminateLoad;
  SetLength(FScrolledImages, 0);
  inherited;
end;

// TScrolledImages.LoadFiles implementation

function TScrolledImages.TerminateLoad: Boolean;
begin
  Result:= False;
  if Assigned(FLoaderThread) then with FLoaderThread do begin
    Terminate;
    WaitFor;
    FLoaderThread:= Nil;
    Result:= True;
  end;
end;

function TScrolledImages.TerminateDither: Boolean;
begin
  Result:= False;
  if Assigned(FDitherThread) then with FDitherThread do begin
    Terminate;
    WaitFor;
    FDitherThread:= Nil;
    Result:= True;
  end;
end;

procedure TScrolledImages.LoadFiles(AFiles: TStrings; ALoadLeft, ALoadWidth: Integer);
begin
  if Assigned(FLoaderThread)
  then Exit; // allready started
  // allocate room
  ImagesCount:= AFiles.Count;
  // start loading images
  FLoaderThread:= TScrolledImagesLoaderThread.Start(False, Self, AFiles,
    ALoadLeft, ALoadWidth);
  FLoaderThread.OnTerminate:= FOnTerminateLoad;
end;

procedure TScrolledImages.Dither(ASrc: TScrolledImages; ADitherMode: TDitherMode;
  ALoadLeft, ALoadWidth: Integer);
begin
  if Assigned(FDitherThread)
  then Exit; // allready started
  // start dithering images
  FDitherThread:= TScrolledImagesDitherThread.Start(False, ASrc, Self, ADitherMode,
    ALoadLeft, ALoadWidth);
  FDitherThread.OnTerminate:= FOnTerminateDither;
end;


function TScrolledImages.GetCurImage: TImage;
begin
  if (FCurImageNo < 0) or (FCurImageNo >= Length(FScrolledImages)) then begin
    Result:= Nil;
    Exit;
  end;
  Result:= FScrolledImages[FCurImageNo].Img;
end;

function TScrolledImages.GetScrolledImage(AImgNo: Integer): TScrolledImage;
begin
  if (AImgNo < 0) or (AImgNo >= Length(FScrolledImages)) then begin
    Result:= Nil;
    Exit;
  end;
  Result:= FScrolledImages[AImgNo];
end;

function TScrolledImages.GetImage(AImgNo: Integer): TImage;
begin
  if (AImgNo < 0) or (AImgNo >= Length(FScrolledImages)) then begin
    Result:= Nil;
    Exit;
  end;
  Result:= FScrolledImages[AImgNo].Img;
end;

function TScrolledImages.GetCurScrolledImage: TScrolledImage;
begin
  Result:= GetScrolledImage(FCurImageNo);
end;

function TScrolledImages.GetImagesCount: Integer;
begin
  Result:= Length(FScrolledImages);
end;

procedure TScrolledImages.SetImagesCount(ANewValue: Integer);
var
  p, AOldValue: Integer;
begin
  AOldValue:= Length(FScrolledImages);
  // delete old images if new qty is less than previous
  for p:= ANewValue to AOldValue - 1 do begin
    FScrolledImages[p].Free;
  end;
  // set new array bounds
  SetLength(FScrolledImages, ANewValue);
  // allocate new ones if new qty is larger than previous
  for p:= AOldValue to ANewValue - 1 do begin
    FScrolledImages[p]:= TScrolledImage.Create(FOwner, FParent, FPanBitmap, FImageList, FOnClick);
  end;
  // make invisible and assign Click event handler
  for p:= AOldValue to ANewValue - 1 do with FScrolledImages[p] do begin
    Id:= p;
    Visible:= True;
  end;
  // check pointer
  if Length(FScrolledImages) = 0 then FCurImageNo:= -1 else begin
    if FCurImageNo < 0
    then FCurImageNo:= 0;
    if FCurImageNo > ANewValue
    then FCurImageNo:= ANewValue - 1;
  end;
end;

function TScrolledImages.ImageMaxWidth: Integer;
var
  p: Integer;
begin
  Result:= 0;
  for p:= 0 to ImagesCount - 1 do begin
    with FScrolledImages[p].Img.Picture.Graphic do begin
      if Result < Width
      then Result:= Width;
    end;
  end;
end;

function TScrolledImages.GetImageNoByCoords(X, Y: Integer): Integer;
var
  p: Integer;
begin
  Result:= -1;
  for p:= 0 to ImagesCount - 1 do begin
    with FScrolledImages[p] do begin
      if (x >= Left) and (x < Left+Width) and (y >= Top) and (y < Top+Height) then begin
        Result:= p;
        Exit;
      end;
    end;
  end;
end;

function TScrolledImages.GetWidth: Integer;
begin
  Result:= 0;
  if ImagesCount <=0
  then Exit;
  Result:= FScrolledImages[0].Pnl.Width;
end;

procedure TScrolledImages.SetWidth(AWidth: Integer);
var
  p: Integer;
begin
  for p:= 0 to ImagesCount - 1 do begin
    FScrolledImages[p].Width:= AWidth;
  end;
end;

procedure TScrolledImages.SetCurImageNo(ACurNo: Integer);
var
  cl: TColor;
begin
  // if FCurImageNo = ACurNo then Exit;

  if (ACurNo < 0) or (ACurNo >= ImagesCount) then begin
    FCurImageNo:= -1;
    Exit;
  end;
  // show selection
  // cl:= FScrolledImages[ACurNo].Pnl.Color;
  FScrolledImages[FCurImageNo].Pnl.Color:= clBtnFace;

  // set value
  FCurImageNo:= ACurNo;
  if (FCurImageNo >= 0) and (FCurImageNo<ImagesCount)
  then FScrolledImages[FCurImageNo].Pnl.Color:= clHighlight;

end;

procedure TScrolledImages.ArrangeImages;
var
  p, y: Integer;
begin
  y:= 0;
  for p:= 0 to ImagesCount - 1 do begin
    with FScrolledImages[p].Img do begin
      Left:= 0;
      Top:= y;
      Inc(y, Height);
    end;
    Inc(y, 4);  // delimiter space
  end;
end;

end.
