unit glMap;

interface

uses
  Windows, SysUtils, glError, glConst;

type

  (* THeader *)

  PHeader = ^THeader;
  THeader = record
    Version: Integer;
    Description: string[255];
    Width, Height: Integer;
  end;

  (* TMap *)

  PMap = ^TMap;
  TMap = class
  private
    FHeader: THeader;
    FLoaded: Boolean;
  public
    constructor Create;
    function SaveToFile(const FileName: string; Buffer: array of Integer): Boolean;
    function LoadFromFile(const FileName: string; Buffer: array of Integer): Boolean;
  end;

implementation

constructor TMap.Create;
begin
  FHeader.Version := 1;
  FHeader.Description := ' ';
  FHeader.Width := 19;
  FHeader.Height := 14;
end;

function TMap.SaveToFile(const FileName: string; Buffer: array of Integer): Boolean;
var
  Header: file of THeader;
  Tile: file of Integer;
  I: Integer;
begin
  AssignFile(Header, FileName);
  ReWrite(Header);
  Write(Header, FHeader);
  CloseFile(Header);

  AssignFile(Tile, FileName);
  Reset(Tile);
  Seek(Tile, SizeOf(FHeader));

  for I := 0 to (FHeader.Width * FHeader.Height) - 1 do
    Write(Tile, Buffer[I]);

  CloseFile(Tile);
end;

function TMap.LoadFromFile(const FileName: string; Buffer: array of Integer): Boolean;
begin

end;

end.

