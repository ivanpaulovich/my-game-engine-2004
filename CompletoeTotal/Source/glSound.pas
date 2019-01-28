(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glSound                                 *)
(*                                                     *)
(*******************************************************)

unit glSound;

interface

uses
  Windows, Classes, SysUtils, ActiveX, glError, glConst, DirectMusic, DXUtil;

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
  TSound = class
  private
    FhWnd: HWND;
    FSound: IDirectMusicSegment8;
    FLoader: IDirectMusicLoader8;
    FPerformance: IDirectMusicPerformance8;
    function InitSoundSystem: HRESULT;
  public
    constructor Create(hWnd: HWND);
    destructor Destroy;
    function LoadFromFile(FileName: string): HRESULT;
    function Play: HRESULT;
    function Stop: HRESULT;
  end;

  (* TSoundItem *)

  PSoundItem = ^TSoundItem;
  TSoundItem = class
  private
    FSound: IDirectMusicSegment8;
    FPerformance: IDirectMusicPerformance8;
    FName: string;
  public
    constructor Create;
    destructor Destroy;
  end;

  (* TSoundSystem *)

  PSoundSystem = ^TSoundSystem;
  TSoundSystem = class
  private
    FhWnd: HWND;
    FLoader: IDirectMusicLoader8;
    FPerformance: IDirectMusicPerformance8;
    function InitSoundSystem: HRESULT;
  public
    constructor Create(hWnd: HWND);
    destructor Destroy;
    function LoadFromFile(FileName: PChar; GameSound: TSoundItem): HRESULT;
    function Play(GameSound: TSoundItem): HRESULT;
    function Stop(GameSound: TSoundItem): HRESULT;
  end;

  (* TSoundList *)

  PSoundList = ^TSoundList;
  TSoundList = class
  private
    FListSound: TList;
    FSoundSystem: TSoundSystem;
  public
    constructor Create(hWnd: HWND);
    destructor Destroy;
    function Add(FileName: string; Name: string = ''): HRESULT; overload;
    function Add(FileNames: array of string; Names: array of string): HRESULT; overload;
    function Play(Index: Integer): HRESULT; overload;
    function Play(Collection: array of Integer): HRESULT; overload;
    function Play(Name: string): HRESULT; overload;
    function Play(Collection: array of string): HRESULT; overload;
    function Stop(Index: Integer): HRESULT; overload;
    function Stop(Collection: array of Integer): HRESULT; overload;
    function Stop(Name: string): HRESULT; overload;
    function Stop(Collection: array of string): HRESULT; overload;
    class function GetSoundList: PSoundList;
  end;

var
  Sounds: TSoundList = nil;

implementation

uses
  glUtil, glApplication;

var
  CountSound: Integer = 0;

  (* TSound *)

constructor TSound.Create;
begin
  FSound := nil;
  FLoader := nil;
  FPerformance := nil;
  FhWnd := hWnd;
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

function TSound.InitSoundSystem;
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

  if (Failed(FPerformance.InitAudio(nil, nil, FhWnd, DMUS_APATH_DYNAMIC_STEREO,
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

  Result := S_OK;
end;

function TSound.LoadFromFile;
var
  WFileName: array[0..511] of WChar;
begin
  if not Assigned(FLoader) then
  begin
    Result := SOUNDERROR_MUSICLOADER;
    raise EError.Create(ERROR_MUSICLOADER);
    Exit;
  end;

  if not Assigned(FPerformance) then
  begin
    Result := SOUNDERROR_MUSICPERFORMANCE;
    raise EError.Create(ERROR_MUSICPERFORMANCE);
    Exit;
  end;

  if Assigned(FSound) then
  begin
    FSound.Unload(FPerformance);
    FSound._Release;
    FSound := nil;
  end;

  DXUtil_ConvertGenericStringToWide(WFileName, PChar(FileName), 512);

  if (FAILED(FLoader.LoadObjectFromFile(CLSID_DirectMusicSegment, IID_IDirectMusicSegment8,
    WFileName, FSound))) then
  begin
    Result := SOUNDERROR_LOAD;
    raise EError.Create(ERROR_LOAD);
    Exit;
  end;

  if (FAILED(FSound.Download(FPerformance))) then
  begin
    Result := SOUNDERROR_DOWNLOAD;
    raise EError.Create(ERROR_DOWNLOAD);
    Exit;
  end;

  Result := S_OK;
end;

function TSound.Play;
begin
  if not Assigned(FPerformance) then
  begin
    Result := SOUNDERROR_MUSICPERFORMANCE;
    raise EError.Create(ERROR_MUSICPERFORMANCE);
    Exit;
  end;

  if not Assigned(FSound) then
  begin
    Result := SOUNDERROR_NOSEGMENT;
    raise EError.Create(ERROR_NOSEGMENT);
    Exit;
  end;

  if Failed(FPerformance.PlaySegment(FSound, DMUS_SEGF_DEFAULT or DMUS_SEGF_SECONDARY, 0, nil)) then
  begin
    Result := SOUNDERROR_PLAYFAIL;
    raise EError.Create(ERROR_PLAYFAIL);
    Exit;
  end;

  Result := S_OK;
end;

function TSound.Stop;
begin
  Result := FPerformance.Stop(FSound, nil, 0, 0);
end;

  (* TSoundItem *)

constructor TSoundItem.Create;
begin
  FName := Format('Sound%d', [CountSound]);
  Inc(CountSound);
  FSound := nil;
  FPerformance := nil;
end;

destructor TSoundItem.Destroy;
begin
  if Assigned(FSound) then
    if Assigned(FPerformance) then
      FSound.Unload(FPerformance);

  FSound := nil;
end;

  (* TSoundSystem *)

constructor TSoundSystem.Create;
begin
  FLoader := nil;
  FPerformance := nil;
  FhWnd := hWnd;
end;

destructor TSoundSystem.Destroy;
begin
  if Assigned(FLoader) then
    FLoader := nil;
  if Assigned(FPerformance) then
    FPerformance := nil;
end;

function TSoundSystem.InitSoundSystem;
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

  if (Failed(FPerformance.InitAudio(nil, nil, FhWnd, DMUS_APATH_DYNAMIC_STEREO,
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

  Result := S_OK;
end;

function TSoundSystem.LoadFromFile;
var
  WFileName: array[0..511] of WChar;
begin
  if not Assigned(FLoader) then
  begin
    Result := SOUNDERROR_MUSICLOADER;
    raise EError.Create(ERROR_MUSICLOADER);
    Exit;
  end;

  if not Assigned(FPerformance) then
  begin
    Result := SOUNDERROR_MUSICPERFORMANCE;
    raise EError.Create(ERROR_MUSICPERFORMANCE);
    Exit;
  end;

  if Assigned(GameSound.FSound) then
  begin
    GameSound.FSound.Unload(FPerformance);
    GameSound.FSound._Release;
    GameSound.FSound := nil;
  end;

  DXUtil_ConvertGenericStringToWide(WFileName, FileName, 512);

  if (FAILED(FLoader.LoadObjectFromFile(CLSID_DirectMusicSegment, IID_IDirectMusicSegment8,
    WFileName, GameSound.FSound))) then
  begin
    Result := SOUNDERROR_LOAD;
    raise EError.Create(ERROR_LOAD);
    Exit;
  end;

  GameSound.FPerformance := FPerformance;

  if (FAILED(GameSound.FSound.Download(FPerformance))) then
  begin
    Result := SOUNDERROR_DOWNLOAD;
    raise EError.Create(ERROR_DOWNLOAD);
    Exit;
  end;

  Result := S_OK;
end;

function TSoundSystem.Play;
begin
  if not Assigned(FPerformance) then
  begin
    Result := SOUNDERROR_MUSICPERFORMANCE;
    raise EError.Create(ERROR_MUSICPERFORMANCE);
    Exit;
  end;

  if not Assigned(GameSound.FSound) then
  begin
    Result := SOUNDERROR_NOSEGMENT;
    raise EError.Create(ERROR_NOSEGMENT);
    Exit;
  end;

  if Failed(FPerformance.PlaySegment(GameSound.FSound, DMUS_SEGF_DEFAULT or DMUS_SEGF_SECONDARY, 0, nil)) then
  begin
    Result := SOUNDERROR_PLAYFAIL;
    raise EError.Create(ERROR_PLAYFAIL);
    Exit;
  end;

  Result := S_OK;
end;

function TSoundSystem.Stop;
begin
  Result := FPerformance.Stop(GameSound.FSound, nil, 0, 0);
end;

constructor TSoundList.Create;
begin
  SaveLog(Format(EVENT_TALK, ['TSoundList.Create']));

  if Assigned(Sounds) then
    raise ELogError.Create(Format(ERROR_EXISTS, ['TSoundList']))
  else
    SaveLog(Format(EVENT_CREATE, ['TSoundList']));
  Sounds := Self;

  FListSound := TList.Create;
  FSoundSystem := TSoundSystem.Create(hWnd);
  FSoundSystem.InitSoundSystem;
end;

destructor TSoundList.Destroy;
begin
  FListSound.Free;
end;

function TSoundList.Add(FileName: string; Name: string = ''): HRESULT;
begin
  FListSound.Add(TSoundItem.Create);
  if Length(Name) > 0 then
  begin
    Dec(CountSound);
    TSoundItem(FListSound[FListSound.Count - 1]).FName := Name;
  end;
  if FSoundSystem.LoadFromFile(PChar(FileName), TSoundItem(FListSound[FListSound.Count - 1])) = SOUNDERROR_LOAD then
    raise EError.Create(Format(ERROR_NOTFOUND,[FileName]))
  else
    SaveLog(Format(EVENT_FOUND,[FileName]));
end;

function TSoundList.Add(FileNames: array of string; Names: array of string): HRESULT;
var
  I: Integer;
begin
  for I := 0 to Length(FileNames) - 1 do
    if Length(Names) > I then
      Add(FileNames[I], Names[I]);
end;

function TSoundList.Play(Index: Integer): HRESULT;
begin
  Result := FSoundSystem.Play(TSoundItem(FListSound[Index]));
end;

function TSoundList.Play(Collection: array of Integer): HRESULT;
var
  I: Integer;
begin
  for I := 0 to Length(Collection) - 1 do
    Result := FSoundSystem.Play(TSoundItem(FListSound[Collection[I]]));
end;

function TSoundList.Play(Name: string): HRESULT;
var
  I: Integer;
begin
  for I := 0 to FListSound.Count - 1 do
  begin
    if TSoundItem(FListSound[I]).FName = Name then
    begin
      Result := FSoundSystem.Play(TSoundItem(FListSound[I]));
      Exit;
    end;
  end;
end;

function TSoundList.Play(Collection: array of string): HRESULT;
var
  I: Integer;
begin
  for I := 0 to Length(Collection) - 1 do
    if TSoundItem(FListSound[I]).FName = Collection[I] then
      Result := FSoundSystem.Play(TSoundItem(FListSound[I]));
end;

function TSoundList.Stop(Index: Integer): HRESULT;
begin
  Result := FSoundSystem.Stop(TSoundItem(FListSound[Index]));
end;

function TSoundList.Stop(Collection: array of Integer): HRESULT;
var
  I: Integer;
begin
  for I := 0 to Length(Collection) - 1 do
    Result := FSoundSystem.Stop(TSoundItem(FListSound[I]));
end;

function TSoundList.Stop(Name: string): HRESULT;
var
  I: Integer;
begin
  for I := 0 to FListSound.Count - 1 do
  begin
    if TSoundItem(FListSound[I]).FName = Name then
    begin
      Result := FSoundSystem.Stop(TSoundItem(FListSound[I]));
      Exit;
    end;
  end;
end;

function TSoundList.Stop(Collection: array of string): HRESULT;
var
  I: Integer;
begin
  for I := 0 to Length(Collection) - 1 do
    if TSoundItem(FListSound[I]).FName = Collection[I] then
      Result := FSoundSystem.Stop(TSoundItem(FListSound[I]));
end;

class function TSoundList.GetSoundList;
begin
  Result := @Sounds;
end;

initialization
  Sounds := TSoundList.Create(Application.Handle);
  
end.
