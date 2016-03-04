unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.StdCtrls, FMX.Controls.Presentation;

type
  TForm2 = class(TForm)
    RadioButton1: TRadioButton;
    Button1: TButton;
    ComboBox1: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.Button1Click(Sender: TObject);
begin
  Self.Visible := False; // So we can hide the form in iOS
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  Log.d('TForm2.FormShow');
end;

end.
