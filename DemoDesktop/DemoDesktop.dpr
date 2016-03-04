program DemoDesktop;

uses
  System.StartUpCopy,
  FMX.Forms,
  ObjectDebuggerFMXFrame in '..\ObjectDebuggerFMXFrame.pas' {FMXObjectDebuggerFrame: TFrame} ,
  FormMessage in '..\FormMessage.pas' {MessageForm} ,
  Unit5 in 'Unit5.pas' {Form5} ,
  ObjectDebuggerFMXForm in 'ObjectDebuggerFMXForm.pas' {ObjectDebuggerFMXForm};

{$R *.res}


begin
  Application.Initialize;
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TMessageForm, MessageForm);
  Application.CreateForm(TObjectDebuggerFMXForm, ObjectDebuggerFMXForm1);
  Application.Run;

end.
