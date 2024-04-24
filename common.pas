unit common;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, logger;

const
  {$IfDef WINDOWS}
  frpsExecutable = 'frps.exe';
  {$Else}
  frpsExecutable = 'frps';
  {$EndIf}

function ExtractQuotedText(const S: string): string;

function DownloadFile(PTF: string; URL: string): boolean;

implementation

function ExtractQuotedText(const S: string): string;
var
  PosStart, PosEnd: integer;
begin
  Result := '';
  PosStart := Pos('"', S);
  if PosStart > 0 then
  begin
    PosEnd := Pos('"', S, PosStart + 1);
    if PosEnd > PosStart then
      Result := Copy(S, PosStart + 1, PosEnd - PosStart - 1);
  end;
end;

function DownloadFile(PTF: string; URL: string): boolean;
var
  client: TFPHTTPClient;
  save2: TFileStream;
begin
  try
    save2:=TFileStream.Create(PTF, fmCreate or fmOpenWrite);

    client := TFPHTTPClient.Create(nil);
    client.AddHeader('user-agent', 'Muhan Frp Node');
    client.Get(URL, save2);
    Result:=true;
  except
    on E: Exception do
    begin
      Log.LogError('An error occurred: ' + E.Message,
        'Function DownloadFile:' + PTF + ',' + URL);
      Result:=false;
    end;
  end;
  save2.Free;
  client.Free;
end;

end.
