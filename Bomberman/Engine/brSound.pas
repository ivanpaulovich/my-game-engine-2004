(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: brSound                                 *)
(*                                                     *)
(*******************************************************)

unit brSound;

interface

uses
  Windows, Classes, SysUtils, ActiveX, DirectMusic, DXUtil;

const
  SOUNDERROR_MUSICLOADER = $85000001;
  SOUNDERROR_MUSICPERFORMANCE = $85000002;
  SOUNDERROR_INITAUDIO = $85000003;
  SOUNDERROR_PATH = $85000004;
  SOUNDERROR_VOLUME = $85000005;
  SOUNDERROR_LOAD = $85000006;
  SOUNDERROR_DOWNLOAD = $85000007;
  SOUNDERROR_NOSEGMENT = $85000008;
  SOUNDERROR_PLAYFAIL = $85000009;

type

  (* TSound *)

  PSound = ^TSound;
  TSound = class(TCollectionItem)
  private
    FName: string[255];
    FFileName: string[255];
    FSound: IDirectMusicSegment8;
    FLoader: IDirectMusicLoader8;
    FPerformance: IDirectMusicPerformance8;
    function InitSoundSystem: HRESULT;
    function GetName: string;
    procedure SetName(Value: string);
    function GetFileName: string;
    procedure SetFileName(Value: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy;
    function LoadFromFile(FileSound: string): Boolean;
    function Play: Boolean;
    function Stop: Boolean;
    property Name: string read GetName write SetName;
    property FileName: string read GetFileName write SetFileName;
  end;

  (* TSounds *)

  TSounds = class(TCollection)
  private
    function IndexOf(Name: string): TSound;
    function GetItem(Index: Integer): TSound;
  public
    function Add: TSound;
    function AddEx(FileName: string; Name: string): TSound;
    function Find(const Name: string): TSound;
    property Item[Index: Integer]: TSound read GetItem;
  end;

implementation

uses
  brForms;

var
  Initialized: Boolean = False;
  
constructor TSound.Create;
begin
  inherited Create(Collection);

  FSound := nil;
  FLoader := nil;
  FPerformance := nil;
  if not Initialized then
    InitSoundSystem;
end;

destructor TSound.Destroy;
begin
  if Assigned(FSound) then
    if Assigned(FPerformance) then
      FSound.Unload(FPerformance);

  FSound := nil;
  FLoader := nil;
  FPerformance := nil;
end;

function TSound.InitSoundSystem: HRESULT;
var
  FPath: IDirectMusicAudioPath8;
begin
  CoInitialize(nil);

  if (Failed(CoCreateInstance(CLSID_DirectMusicLoader, nil,
    CLSCTX_INPROC, IID_IDirectMusicLoader8, FLoader))) then
  begin
    Result := SOUNDERROR_MUSICLOADER;
    Exit;
  end;

  if (Failed(CoCreateInstance(CLSID_DirectMusicPerformance, nil,
    CLSCTX_INPROC, IID_IDirectMusicPerformance8, FPerformance))) then
  begin
    Result := SOUNDERROR_MUSICPERFORMANCE;
    Exit;
  end;

  if (Failed(FPerformance.InitAudio(nil, nil, Window.Handle, DMUS_APATH_DYNAMIC_STEREO,
    4, DMUS_AUDIOF_ALL, nil))) then
  begin
    Result := SOUNDERROR_INITAUDIO;
    Exit;
  end;

  if (Failed(FPerformance.GetDefaultAudioPath(FPath))) then
  begin
    Result := SOUNDERROR_PATH;
    Exit;
  end;

  if (Failed(FPath.SetVolume(0, 0))) then
  begin
    Result := SOUNDERROR_VOLUME;
  end;

  Initialized := True;
  Result := S_OK;
end;

function TSound.LoadFromFile(FileSound: string): Boolean;
var
  WFileName: array[0..511] of WChar;
begin
  Result := False;

  if FileExists(FileSound) then
    SaveLog(Format(EVENT_FOUND, [FileSound]))
  else
    raise EError.Create(Format(ERROR_NOTFOUND, [FileSound]));

  FFileName := FileSound;

  if not Assigned(FLoader) then
  begin
    raise EError.Create(ERROR_MUSICLOADER);
    Exit;
  end;

  if not Assigned(FPerformance) then
  begin
    raise EError.Create(ERROR_MUSICPERFORMANCE);
    Exit;
  end;

  if Assigned(FSound) then
  begin
    FSound.Unload(FPerformance);
    FSound._Release;
    FSound := nil;
  end;

  DXUtil_ConvertGenericStringToWide(WFileName, PChar(FileSound), 512);

  if (FAILED(FLoader.LoadObjectFromFile(CLSID_DirectMusicSegment, IID_IDirectMusicSegment8,
    WFileName, FSound))) then
  begin
    raise EError.Create(ERROR_LOAD);
    Exit;
  end;

  if (FAILED(FSound.Download(FPerformance))) then
  begin
    raise EError.Create(ERROR_DOWNLOAD);
    Exit;
  end;

  Result := True;
end;

function TSound.Play;
begin
  Result := False;

  if not Assigned(FPerformance) then
  begin
    raise EError.Create(ERROR_MUSICPERFORMANCE);
    Exit;
  end;

  if not Assigned(FSound) then
  begin
    raise EError.Create(ERROR_NOSEGMENT);
    Exit;
  end;

  if Failed(FPerformance.PlaySegment(FSound, DMUS_SEGF_DEFAULT or DMUS_SEGF_SECONDARY, 0, nil)) then
  begin
    raise EError.Create(ERROR_PLAYFAIL);
    Exit;
  end;

  Result := True;
end;

function TSound.Stop;
begin
  Result := FPerformance.Stop(FSound, nil, 0, 0) = S_OK;
end;

function TSound.GetName: string;
begin
  Result := FName;
end;

procedure TSound.SetName(Value: string);
begin
  FName := Value;
end;

function TSound.GetFileName: string;
begin
  Result := FileName;
end;

procedure TSound.SetFileName(Value: string);
begin
  FFileName := Value;
  LoadFromFile(Value);
end;

function TSounds.IndexOf(Name: string): TSound;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if GetItem(I).Name = Name then
    begin
      Result := GetItem(I);
      Exit;
    end;
  end;

  Result := nil;
end;

function TSounds.GetItem(Index: Integer): TSound;
begin
  Result := inherited Items[Index] as TSound;
end;

function TSounds.Add: TSound;
begin
  Result := inherited Add as TSound;
end;

function TSounds.AddEx(FileName: string; Name: string): TSound;
begin
  Result := inherited Add as TSound;
  Result.Name := Name;
  Result.FFileName := FileName;
  Result.LoadFromFile(FileName);
end;

function TSounds.Find(const Name: string): TSound;
begin
  Result := IndexOf(Name);
  if Result = nil then
    raise EError.Create(Format(ERROR_NOTFOUND, [Name]));
end;

end.
