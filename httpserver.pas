unit httpserver;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpserver, process, logger, httpprotocol;

type
  TApiServerCallback = class

    procedure OnRequest(Sender: TObject; var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
  end;

procedure APIServerStart();


var
  APIServer: TFPHttpServer;
  ApiServerCallback: TApiServerCallback;

implementation

uses global, frpcontroller, common;

procedure APIServerStart();
begin
  APIServer.Port := configJson.Integers['bind_port'];
  APIServer.Address := configJson.Strings['bind_addr'];
  APIServer.Active := True;
end;

procedure TApiServerCallback.OnRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.Content := '';

  //Auth
  if ARequest.GetHeader(hhAuthorization) <> AuthorizationValue then
  begin
    AResponse.Code := 403;
    Exit;
  end;

  //Router
  case ARequest.URI of
    '/api/start': begin
      if StartFrp() then begin
        AResponse.SetStatus(200);
      end else begin
        AResponse.SetStatus(500);
      end;
    end;
    '/api/stop': begin
      if StopFrp() then begin
        AResponse.SetStatus(200);
      end else begin
        AResponse.SetStatus(500);
      end;
    end;
    '/api/restart': begin
      StopFrp();
      if StartFrp() then begin
        AResponse.SetStatus(200);
      end else begin
        AResponse.SetStatus(500);
      end;
    end;
    '/api/update': begin
      if FileExists(FrpProcess.Executable+'.old') then DeleteFile(FrpProcess.Executable+'.old');
      RenameFile(FrpProcess.Executable, FrpProcess.Executable+'.old');
      if not DownloadFile(FrpProcess.Executable, 'http://api.muhanyun.cn/frp/frps_linux_amd64') then begin
        //Download Failed
        //Rollback
        if FileExists(FrpProcess.Executable) then DeleteFile(FrpProcess.Executable);
        RenameFile(FrpProcess.Executable+'.old', FrpProcess.Executable);
        AResponse.SetStatus(502);
      end else begin
        StartFrp();
        AResponse.SetStatus(200);
      end;
    end
    else AResponse.SetStatus(404);
  end;

  log.LogStatus(IntToStr(AResponse.Code)+' for client' + ARequest.RemoteAddress+' - '+ARequest.URI, 'ApiServerCallback.OnRequest');
end;

initialization
  ApiServerCallback := TApiServerCallback.Create;

  APIServer := TFPHttpServer.Create(nil);
  APIServer.ThreadMode := tmThread;
  APIServer.OnRequest := @ApiServerCallback.OnRequest;


finalization

  APIServer.Free;

end.
