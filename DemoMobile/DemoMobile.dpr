program DemoMobile;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit3 in 'Unit3.pas' {Form3},
  FormMessage in '..\FormMessage.pas' {MessageForm},
  ObjectDebuggerFMXFrame in '..\ObjectDebuggerFMXFrame.pas' {FMXObjectDebuggerFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TMessageForm, MessageForm);
  Application.CreateForm(TFMXObjectDebuggerFrame, FMXObjectDebuggerFrame);
  Application.Run;
end.
