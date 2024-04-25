program frpnode;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes { you can add units after this },
  SysUtils,
  fphttpserver,
  jsonparser,
  fpjson,
  global, common, frpcontroller, httpserver, opensslsockets, logger;

var
  FrpsDaemonThread: TFrpsDaemonThread;
begin
  //Read config
  ReadJsonConfig();
  ReadTomlConfig(configJson.Strings['frps_config_path']);

  InitFrpProcess;
  //StartFrp();

  FrpsDaemonThread := TFrpsDaemonThread.Create(false);
  FrpsDaemonThread.FreeOnTerminate := true;

  APIServerStart();

  WriteLn('Running. Press enter to exit.');
  ReadLn;
end.
