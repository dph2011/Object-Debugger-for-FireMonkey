unit FormMessage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TMessageForm = class(TForm)
    ButtonOK: TButton;
    Button2: TButton;
  private
    {Private declarations}
    TopPanel: TPanel;
  public
    {Public declarations}
    procedure AddPanel(panel: TPanel);
    procedure ShowMessage(str, caption: string);
  end;

var
  MessageForm: TMessageForm;

implementation

{$R *.fmx}


uses
  FMX.Memo // TMemo
    ;

procedure TMessageForm.AddPanel(panel: TPanel);
var
  margin: Single;
begin
  if (nil <> TopPanel) and (TopPanel.Parent = Self) then
  begin
    Self.RemoveObject(TopPanel);
    FreeAndNil(TopPanel);
  end;

  Self.AddObject(panel);
  panel.Position.X := 0;
  panel.Position.Y := 0;
  panel.Width := Self.Width;
  margin := Self.ClientHeight - (ButtonOK.Position.Y + ButtonOK.Height);
  panel.Height := Self.ClientHeight - 2 * margin - ButtonOK.Height;

  panel.Align := TAlignLayout.None;
  panel.Anchors := [TAnchorKind.akTop, TAnchorKind.akBottom, TAnchorKind.akLeft, TAnchorKind.akRight];

  TopPanel := panel;
end;

procedure TMessageForm.ShowMessage(str, caption: string);
var
  P: TPanel;
  Memo1: TMemo;
begin
  P := TPanel.Create(Self);
  try
    //middle of the screen
    Self.Left := round(Screen.Width / 2 - 125);
    Self.Top := round(Screen.Height / 2 - 150);
    Self.caption := caption;

    AddPanel(P);
    Memo1 := TMemo.Create(P);
    with Memo1 do
    begin
      Parent := P;
      Width := P.Width - 30;
      Height := P.Height - 30;
      ReadOnly := True;
      Position.X := 15;
      Position.Y := 15;
      WordWrap := True;
      Align := TAlignLayout.None;
      Anchors := [TAnchorKind.akTop, TAnchorKind.akBottom, TAnchorKind.akLeft, TAnchorKind.akRight];
      Lines.Text := str;
    end;
    // Plain old ShowModal not supported on Android so use newer version with support for callback.
    Self.ShowModal(
      procedure(ModalResult: TModalResult)
      begin
        Self.Visible := False;
      end);
  finally

  end;
end;

end.
