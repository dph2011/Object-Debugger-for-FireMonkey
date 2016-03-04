unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Colors;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    {Private declarations}
  public
    {Public declarations}
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


uses
  ObjectDebuggerFMXFrame
    , Unit2 // Form2
    ;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // TODO In iOS, need to find someone of keeping debug form on top or of bringing it back to the top.
  FMXObjectDebuggerFrame.Visible := True;
  FMXObjectDebuggerFrame.BringToFront;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Log.d('TForm1.FormShow');

  if nil = FMXObjectDebuggerFrame then
    FMXObjectDebuggerFrame := TFMXObjectDebuggerFrame.Create(Self);

  AddObject(FMXObjectDebuggerFrame);
  with FMXObjectDebuggerFrame do
  begin
    Visible := True;
    BringToFront;
    Position.X := 0;
    Position.Y := 0;
    Height := Self.ClientHeight;
    Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight, TAnchorKind.akTop, TAnchorKind.akBottom];
  end;

{$IFNDEF IOS}
  Form2.Show;
{$ENDIF}
end;

initialization

end.
