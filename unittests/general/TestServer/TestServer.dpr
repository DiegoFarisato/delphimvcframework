﻿program TestServer;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  {$IF Defined(HTTPSYS)}
  MVCFramework.HTTPSys.WebBrokerBridge,
  {$ENDIF}
  {$IF Defined(MSWindows)}
  Winapi.Windows,
  {$ENDIF }
  {$IF not Defined(HTTPSYS)}
  IdHTTPWebBrokerBridge,
  {$ENDIF}
  Web.WebReq,
  Web.WebBroker,
  MVCFramework.Commons,
  MVCFramework.Console,
  WebModuleUnit in 'WebModuleUnit.pas' {MainWebModule: TWebModule},
  TestServerControllerU in 'TestServerControllerU.pas',
  TestServerControllerExceptionU in 'TestServerControllerExceptionU.pas',
  SpeedMiddlewareU in 'SpeedMiddlewareU.pas',
  TestServerControllerPrivateU in 'TestServerControllerPrivateU.pas',
  AuthHandlersU in 'AuthHandlersU.pas',
  BusinessObjectsU in '..\..\..\samples\commons\BusinessObjectsU.pas',
  TestServerControllerJSONRPCU in 'TestServerControllerJSONRPCU.pas',
  RandomUtilsU in '..\..\..\samples\commons\RandomUtilsU.pas',
  MVCFramework.Tests.Serializer.Entities in '..\..\common\MVCFramework.Tests.Serializer.Entities.pas',
  FDConnectionConfigU in '..\..\common\FDConnectionConfigU.pas',
  Entities in '..\Several\Entities.pas',
  EntitiesProcessors in '..\Several\EntitiesProcessors.pas';

{$R *.res}

procedure Logo(APort: Integer);
var
  lEngine: String;
begin
{$IF Defined(HTTPSYS)}
  lEngine := 'HTTP.sys';
{$ELSE}
  lEngine := 'INDY';
{$ENDIF};
  ResetConsole();
  Writeln;
  TextBackground(TConsoleColor.Black);
  TextColor(TConsoleColor.Red);
  Writeln(' ██████╗ ███╗   ███╗██╗   ██╗ ██████╗    ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗');
  Writeln(' ██╔══██╗████╗ ████║██║   ██║██╔════╝    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗');
  Writeln(' ██║  ██║██╔████╔██║██║   ██║██║         ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝');
  Writeln(' ██║  ██║██║╚██╔╝██║╚██╗ ██╔╝██║         ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗');
  Writeln(' ██████╔╝██║ ╚═╝ ██║ ╚████╔╝ ╚██████╗    ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║');
  Writeln(' ╚═════╝ ╚═╝     ╚═╝  ╚═══╝   ╚═════╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝');
  Writeln(' ');
  TextColor(TConsoleColor.White);
  Write('PLATFORM: ');
  {$IF Defined(Win32)} Writeln('WIN32'); {$ENDIF}
  {$IF Defined(Win64)} Writeln('WIN64'); {$ENDIF}
  {$IF Defined(Linux64)} Writeln('Linux64'); {$ENDIF}
  TextColor(TConsoleColor.Yellow);
  Writeln('DMVCFRAMEWORK VERSION: ', DMVCFRAMEWORK_VERSION);
  TextColor(TConsoleColor.White);
  Writeln(Format('Starting HTTP Server or port %d', [APort]));
  TextColor(TConsoleColor.Red);
  TextBackground(TConsoleColor.Gray);
  Writeln(''.PadRight(30,'*'));
  WriteLn('* ' + ('Engine: ' + lEngine).PadRight(27) + '*');
  Writeln(''.PadRight(30,'*'));
  ResetConsole();
end;

{$IF Defined(HTTPSYS)}

procedure RunServer(APort: Integer);
var
  LServer: TMVCHTTPSysWebBrokerBridge;
begin
  Logo(APort);
  LServer := TMVCHTTPSysWebBrokerBridge.Create;
  try
    // LServer.OnParseAuthentication := TMVCParseAuthentication.OnParseAuthentication;
    LServer.Port := APort;
    LServer.UseSSL := False;
    LServer.UseCompression := True;
    LServer.Active := True;
    { more info about MaxConnections
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_MaxConnections.html }
    // LServer.MaxConnections := 0;
    { more info about ListenQueue
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_ListenQueue.html }
    // LServer.ListenQueue := 200;
    Writeln('Press RETURN to stop the server');
    WaitForReturn;
    TextColor(TConsoleColor.Red);
    Writeln('Server stopped');
    ResetConsole();
  finally
    LServer.Free;
  end;
end;

{$ELSE}

procedure RunServer(APort: Integer);
var
  LServer: TIdHTTPWebBrokerBridge;
begin
  Logo(APort);
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.OnParseAuthentication := TMVCParseAuthentication.OnParseAuthentication;
    LServer.DefaultPort := APort;
    LServer.Active := True;
    LServer.MaxConnections := 0;
    LServer.ListenQueue := 200;
    Writeln('Press RETURN to stop the server');
    WaitForReturn;
    TextColor(TConsoleColor.Red);
    Writeln('Server stopped');
    ResetConsole();
  finally
    LServer.Free;
  end;
end;

{$ENDIF}

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    if WebRequestHandler <> nil then
      WebRequestHandler.WebModuleClass := WebModuleClass;
    RunServer(9999);
  except
    on E: Exception do
    begin
      TextColor(TConsoleColor.Red);
      TextBackground(TConsoleColor.Black);
      Writeln(E.ClassName, ': ', E.Message);
      TextColor(TConsoleColor.White);
    end;
  end;

end.
