unit ObjectDebuggerFMXForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  ObjectDebuggerFMXFrame;

type
  TObjectDebuggerFMXForm = class(TForm)
    TFMXObjectDebuggerFrame1: TFMXObjectDebuggerFrame;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ObjectDebuggerFMXForm1: TObjectDebuggerFMXForm;

implementation

{$R *.fmx}

end.
