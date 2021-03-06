unit Horse;

interface

uses IdHTTPWebBrokerBridge, Horse.Core, IdContext, Horse.HTTP, System.SysUtils, Horse.Router;

type
  EHorseCallbackInterrupted = Horse.HTTP.EHorseCallbackInterrupted;
  TProc = System.SysUtils.TProc;
  THorseList = Horse.HTTP.THorseList;
  THorseRequest = Horse.HTTP.THorseRequest;
  THorseHackRequest = Horse.HTTP.THorseHackRequest;
  THorseResponse = Horse.HTTP.THorseResponse;
  THorseHackResponse = Horse.HTTP.THorseHackResponse;
  THorseCallback = Horse.Router.THorseCallback;

  THorse = class(THorseCore)
  private
    FPort: Integer;
    FMaxConnections: Integer;
    FListenQueue: Integer;
    procedure OnAuthentication(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String;
      var VHandled: Boolean);
  protected
    procedure Initialize; override;
  public
    constructor Create; overload;
    constructor Create(APort: Integer); overload;
    property ListenQueue: Integer read FListenQueue write FListenQueue;
    property MaxConnections: Integer read FMaxConnections write FMaxConnections;
    property Port: Integer read FPort write FPort;
    procedure Start; override;
  end;

implementation

{ THorse }

uses Horse.Constants, Horse.WebModule, Web.WebReq, IdCustomTCPServer;

constructor THorse.Create(APort: Integer);
begin
  inherited Create;
  FPort := APort;
end;

procedure THorse.Initialize;
begin
  inherited;
  FListenQueue := IdListenQueueDefault;
  MaxConnections := 0;
end;

constructor THorse.Create;
begin
  inherited Create;
  FPort := DEFAULT_PORT;
end;

procedure THorse.OnAuthentication(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String;
  var VHandled: Boolean);
begin
  VHandled := True;
end;

procedure THorse.Start;
var
  LHTTPWebBroker: TIdHTTPWebBrokerBridge;
  LAttach: string;
begin
  inherited;
  WebRequestHandler.WebModuleClass := WebModuleClass;
  LHTTPWebBroker := TIdHTTPWebBrokerBridge.Create(nil);
  try
    try
      LHTTPWebBroker.OnParseAuthentication := OnAuthentication;

      LHTTPWebBroker.MaxConnections := FMaxConnections;
      LHTTPWebBroker.ListenQueue := FListenQueue;
      LHTTPWebBroker.DefaultPort := FPort;
      Writeln(Format(START_RUNNING, [FPort]));
      LHTTPWebBroker.Active := True;
      LHTTPWebBroker.StartListening;
      Write('Press return to stop ...');
      Read(LAttach);

      LHTTPWebBroker.Active := False;
      LHTTPWebBroker.Bindings.Clear;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    LHTTPWebBroker.free;
  end;
end;

end.