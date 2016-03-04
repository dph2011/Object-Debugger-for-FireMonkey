unit Unit5;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, System.Rtti, FMX.Menus,
  FMX.Ani, FMX.Grid, FMX.Layouts, FMX.ComboEdit, FMX.Controls.Presentation,
  FMX.Edit, FMX.ListView, FMX.TabControl, FMX.ListBox, ObjectDebuggerFMXFrame,
  FMX.Colors, FMX.ScrollBox, FMX.Memo;

type
  TForm5 = class(TForm)
    Edit1: TEdit;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    ColorPanel1: TColorPanel;
    ComboColorBox1: TComboColorBox;
    procedure FormShow(Sender: TObject);
  private
    {Private declarations}
  public
    {Public declarations}
  end;

var
  Form5: TForm5;

implementation

{$R *.fmx}


uses
  ObjectDebuggerFMXForm;

procedure TForm5.FormShow(Sender: TObject);
begin
  ObjectDebuggerFMXForm1.Show;
end;

end.
