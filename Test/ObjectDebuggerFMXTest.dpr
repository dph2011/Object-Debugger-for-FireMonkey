program ObjectDebuggerFMXTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  FormMessage in '..\FormMessage.pas' {MessageForm},
  ObjectDebuggerFMXFrame in '..\ObjectDebuggerFMXFrame.pas' {FMXObjectDebuggerFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TMessageForm, MessageForm);
  Application.CreateForm(TFMXObjectDebuggerFrame, FMXObjectDebuggerFrame);
  Application.Run;
end.
