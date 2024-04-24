unit frpcontroller;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, process, StreamIO;

var
  FrpProcess: TProcess;

function StartFrp(): boolean;
function StopFrp(): boolean;
procedure InitFrpProcess();

type
  TFrpsDaemonThread = class(TThread)
    procedure Execute; override;
  end;

implementation

uses global, common, logger;

function StartFrp(): boolean;
begin
  Log.LogStatus('Starting frps', 'frpcontroller');
  if FrpProcess.Running then
  begin
    Log.LogError('Canceled starting frps: already running', 'frpcontroller');
    exit(False);
  end;

  try
    FrpProcess.Execute;
  except
    on E: Exception do
    begin
      Log.LogError('Exception on starting Frps: ' + E.Message, 'frpcontroller');
      Exit(False);
    end;

  end;

  Result := True;
end;

function StopFrp(): boolean;
begin
  Log.LogStatus('Terminating frps', 'frpcontroller');
  if not FrpProcess.Running then
  begin
    Log.LogError('Canceled terminating frps: not running', 'frpcontroller');
    exit(False);
  end;
  Result := FrpProcess.Terminate(0);
end;

procedure InitFrpProcess();
begin
  FrpProcess.Executable := configJson.Strings['frps_directory'] +
    PathDelim + frpsExecutable;
  FrpProcess.Parameters.Add('-c');
  FrpProcess.Parameters.Add(configJson.Strings['frps_config_path']);
  FrpProcess.CurrentDirectory := configJson.Strings['frps_directory'];
end;

procedure TFrpsDaemonThread.Execute();
var
  buffer: string;
  C: integer;
begin
  buffer := '';
  while True do
  begin
    Sleep(1000);

    if not Assigned(FrpProcess.Output) then continue;

    with FrpProcess.Output do begin
      C:=NumBytesAvailable;
      if C > 0 then begin
        SetLength(buffer, C);
        Read(buffer[1], C);
        Log.LogStatus(buffer, 'FrpProcessMonitor');
      end;
    end;


  end;

end;

initialization
  FrpProcess := TProcess.Create(nil);
  FrpProcess.Options := [poUsePipes];


finalization
  FrpProcess.Free;

end.
