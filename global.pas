unit global;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson, logger;

var
  configJson: TJSONObject;
  AuthorizationValue: string;

procedure ReadJsonConfig();
procedure ReadTomlConfig(path: string);

implementation

uses common;

procedure ReadJsonConfig();
var
  json: TextFile;
  buffer: string;
  S: string = '';
begin
  AssignFile(json, 'config.json');
  Reset(json);
  while not EOF(json) do begin
    ReadLn(json, buffer);
    AppendStr(S, buffer);
  end;
  configJson := GetJSON(S) as TJSONObject;
end;

procedure ReadTomlConfig(path: string);
var
  tfile: TextFile;
  buffer: string;
begin
  AssignFile(tfile, path);
  Reset(tfile);
  while not EOF(tfile) do begin
    ReadLn(tfile, buffer);
    if Pos('path', buffer) = 1 then begin
       AuthorizationValue := 'Bearer '+ExtractQuotedText(buffer);
       Break;
    end;
  end;

end;

finalization
configJson.Free;

end.
