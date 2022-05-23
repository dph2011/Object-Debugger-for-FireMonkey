unit ObjectDebuggerFMXFrame;

{*******************************
  {    Delphi ObjectDebugger - FMX  Version
  {    MPL 2.0 License
  {    Copyright 2016 Daniel Horn
  {    dph@softwarecraftsman.org
  { *******************************}
{
  NOTES

  This is essentially a FireMonkey version of the Object Debugger (for VCL) by Marco Cantu.
  (For those who are interested in comparing the two implementations, an attempt was made to use names
  similar to those in the VCL version.)

  Some differences and items to note include:

  1) The RTTI code works on several platforms: not only Windows but also Mac OS X, iOS, and Android.
  The changes needed to accomplish this included using TypInfo calls such as GetTypeName and GetPropName and
  adding a routine for reading bytes as a "ShortString" and converting it to a string (the ShortString type does not exist on iOS and Android).


  2) Besides using FireMonkey, the chief UI difference is that the main component is a TFrame instead of a TForm.
  This gives more flexibility, especially if one intends to use this in a mobile app (in which more than one form may not be visible).
  More specifically, if the form you want to inspect belongs to:
  a) an iOS or Android app:
  you will want to add this frame directly to that form; otherwise, you have no clear way to see both the form and the ObjectDebugger at the same time;
  b) a Windows or Mac desktop app:
  you will probably prefer to put the ObjectDebugger frame in its own window so as not to change the layout of the form.

  Because it is a frame and not a form, it makes more sense to provide a menu via a TPopupMenu (invoked by a right mouse click) rather
  than a TMainMenu.


  3) This has been tested on Windows 10 (32 bit app on 64 bit Windows), Mac OS X (SDK 10.11.2 on 10.11.3),
  iOS Simulator 9.2 (iPad Air 2), and Android (SDK 24.3.3 32bit on Samsung SM-T217S running Android 4.4.2).
  While the RTTI code works on all platforms, the emphasis on UI has been for Windows and Mac.
  Developers using this component on iOS or Android will probably want to make adjustments to the UI.


  4) Evidently, the FireMonkey TStringGrid component does not generate OnVScrollChange and OnHScrollChange events on the Mac.
  The simple solution to this is just use the OnViewportPositionChange event handler instead in FireMonkey apps.


  5) Since the FMX ShowMessage messagebox does not let you assign a caption, we provide a simple replacement, FormMessage;
  in addition to acting like ShowMessage replacement, it can also be used to display a TPanel.


  6) Some OnMouseDown event handlers are now performed in OnMouseUp instead.  One reason for doing this is that
  FireMonkey is not happy when, e.g., a FMX.Dialogs.ShowMessage call is made in OnMouseDown (after closing the message, it seems to be awaiting an OnMouseUp event).


  7) The PlaceControl logic mimics that used in the VCL version.
  Perhaps a better solution would have been to replace it with something like
  https://delphiscience.wordpress.com/2012/11/21/tvariantcolumn-for-firemonkey-grid-different-cell-types-in-the-same-column/



  TODO

  Search for "TODO" below for more comments.

  TODO What should be used for the Fonts and Colors dialog boxes?

  TODO Replace the listview used for for editing set properties.
  Or, at least, make the current one used more visually appealing;  it should stand out more obviously when visible on the main property inspector.

  TODO Make Frame dockable/undockable if this is deemed to have any value.

  TODO This component should probably be a singleton object in any application.


  QUESTIONS

  1) Bug in original? : Should line
  sgProp.Objects [1, nRow] := nil;
  in UpdateData, actuallly read:
  sgData.Objects [1, nRow] := nil;

  2) Is it possible to hide just the horizontal scrollbar of a stringgrid?

  3) What additional useful information should be displayed in the Data stringgrid?


  References:
  http://wiert.me/2013/09/05/delphi-mobile-nextgen-compiler-unsupported-data-types-means-unsupported-rtti-as-well/
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  System.Rtti, FMX.Grid, FMX.Layouts, FMX.TabControl, FMX.Menus //
    , FMX.Controls.Presentation, FMX.Edit, FMX.ComboEdit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.ScrollBox, FMX.Ani, FMX.Memo, FMX.Grid.Style, System.Actions, FMX.ActnList //
    , FMX.StdCtrls // TPanel
    , System.TypInfo //TPropList, PPropInfo
    ;

type
  TSGObjects = array [0 .. 2] of array of Pointer;

type
  TFMXObjectDebuggerFrame = class(TFrame)
    cbForms: TComboBox;
    cbComps: TComboBox;
    Timer1: TTimer;
    TabControl1: TTabControl;
    sgProp: TStringGrid;
    TabItemProperties: TTabItem;
    TabItemEvents: TTabItem;
    TabItemData: TTabItem;
    StringColumn1: TStringColumn;
    sgEvt: TStringGrid;
    sgData: TStringGrid;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    ComboCursor: TComboEdit;
    ComboColor: TComboEdit;
    ComboEnum: TComboEdit;
    EditNum: TEdit;
    EditCh: TEdit;
    EditStr: TEdit;
    ListSet: TListView;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItemVisible: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    Panel1: TPanel;
    procedure cbFormsChange(Sender: TObject);
    procedure cbCompsChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure sgPropDblClick(Sender: TObject);
    procedure sgPropSelectCell(Sender: TObject; const ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure MenuItemRefreshFormsClick(Sender: TObject);
    procedure MenuItemRefreshComponentsClick(Sender: TObject);
    procedure ListSetClick(Sender: TObject);
    procedure RefreshOnExit(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditChExit(Sender: TObject);
    procedure EditNumExit(Sender: TObject);
    procedure EditStrExit(Sender: TObject);
    procedure ComboCursorChange(Sender: TObject);
    procedure ComboColorChange(Sender: TObject);
    procedure ComboColorDblClick(Sender: TObject);
    procedure ComboEnumChange(Sender: TObject);
    procedure ComboEnumDblClick(Sender: TObject);
    procedure MenuItemInfoClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemRefreshValuesClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditNumKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure sgDataSelectCell(Sender: TObject; const ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgPropResize(Sender: TObject);
    procedure sgResize(Sender: TObject);
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure MenuItemVisibleClick(Sender: TObject);
    procedure sgPropHeaderClick(Column: TColumn);
    procedure sgEvtHeaderClick(Column: TColumn);
    procedure sgDataHeaderClick(Column: TColumn);
    procedure sgPropViewportPositionChange(Sender: TObject;
      const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
    procedure sgPropTap(Sender: TObject; const Point: TPointF);
  private
    {Private declarations}
    FCopyright: string;
    //current form: TForm or TDataModule
    CurrForm: TComponent;
    //the current component
    CurrComp: TComponent;
    //the real component (if a subproperty is active)
    RealComp: TComponent;
    //are we editing a subproperty?
    EditingSub: Boolean;
    //current property
    CurrProp: PPropInfo;
    //current row in props grid
    CurrRow: Integer;
    //edit box has been modified?
    EditModified: Boolean;

    // TODO A better way to do this would be to extend the FireMonkey TStringGrid to include something similar to the Objects field of the VCL TStringGrid
    // or else use a different stringgrid that already includes it (TMS?).
    sgPropObjects: TSGObjects;
    sgEvtObjects: TSGObjects;
    sgDataObjects: TSGObjects;

    // Current row in grids
    CurrRowEvt: Integer;
    CurrRowData: Integer;

    ctrlToMove: TControl;

    procedure UpdateFormsCombo;
    procedure UpdateCompsCombo;
    procedure UpdateProps;
    procedure UpdateData;

    procedure EditStringList(Str: TStrings);

    procedure AddToComboColor(const S: String);
    function GetStringGridObjects(sg: TStringGrid): TSGObjects;
    procedure PlaceControl(Ctrl: TControl; sg: TStringGrid; ACol, ARow: Integer);
    procedure PlaceControlAgain;
    procedure Initialize;

  public
    {Public declarations}
    constructor Create(AOwner: TComponent); override;
    property ClientWidth: Single read GetWidth; //TODO: return something else?
    property ClientHeight: Single read GetHeight; //TODO: return something else?
  
  published
    property Copyright: string read FCopyright;
    property Anchors; // Make Anchors property visible.
  end;

var
  FMXObjectDebuggerFrame: TFMXObjectDebuggerFrame;

implementation

{$R *.fmx}

uses
  System.Math // IntPower
    , System.UIConsts // ColorToString
    , FMX.Platform // TPlatformServices
    , FormMessage // MessageForm
    ;

const
  VersionDescription = 'Object Debugger for Delphi 10 Seattle - FMX Version';
  VersionRelease = 'Release 5.50';
  CopyrightString = 'Copyright (c) 2016 Daniel Horn';

type
  // TypeInfo does not work for enum unless it starts at 0 and increases.
  // Just used for getting strings which are names of cursors.
  TMyCursor = (
    crDefault, //= 0,
    crNone, //= -1,
    crArrow, //= -2,
    crCross, //= -3,
    crIBeam, //= -4,
    crSize, //= -22, // 5 in this enum but actually -22
    crSizeNESW, //= -6,
    crSizeNS, //= -7,
    crSizeNWSE, //= -8,
    crSizeWE, //= -9,
    crUpArrow, //= -10,
    crHourGlass, //= -11,
    crDrag, //= -12,
    crNoDrop, //= -13,
    crHSplit, //= -14,
    crVSplit, //= -15,
    crMultiDrag, //= -16,
    crSQLWait, //= -17,
    crNo, //= -18,
    crAppStart, //= -19,
    crHelp, //= -20,
    crHandPoint, //= -21,
    crSizeAll //= -22
    );

function GetPropValAsString(Obj: TObject; PropInfo: PPropInfo): string; forward;
function MyColorToString(Color: TColor): string; forward;
function MyCursorToString(Cursor: TCursor): string; forward;
procedure SetCursor(crCursor: TCursor); forward;

function SetToString(Value: Cardinal; pti: PTypeInfo): string; forward;
procedure ListEnum(pti: PTypeInfo; sList: TStrings; ShowIndex: Boolean); forward;
procedure ListEnum2(pti: PTypeInfo; sList: TAppearanceListViewItems; ShowIndex: Boolean); forward;
function IsBitOn(Value: Integer; Bit: Byte): Boolean; forward;
procedure ShowRTTI(pti: PTypeInfo; sList: TStrings); forward;
procedure ShowRttiDetail(pti: PTypeInfo); forward;

{fill the FormsCombo with the names of the forms of the
  current project keep the curent element selected, unless it
  has been destroyed. In this last case use the MainForm
  as selected form.}
procedure TFMXObjectDebuggerFrame.UpdateFormsCombo;
var
  I, nForm, Pos: Integer;
  Form: TCommonCustomForm;
begin
  //  Log.d('TCantObjDebFMXForm.UpdateFormsCombo');

  SetCursor(TCursor(crHourGlass));

  cbForms.Items.BeginUpdate;
  try
    cbForms.Items.Clear;
    //for each form of the program
    for nForm := 0 to Screen.FormCount - 1 do
    begin
      Form := Screen.Forms[nForm];
      // Add all forms, but don't add the debugger frame (per below).
      cbForms.Items.AddObject(
        Format('%s (%s)', [Form.Caption, Form.ClassName]),
        Form);
    end;
    //for each data module
    for I := 0 to Screen.DataModuleCount - 1 do
      cbForms.Items.AddObject(
        Format('%s (%s)',
        [Screen.DataModules[I].Name,
        Screen.DataModules[I].ClassName]),
        Screen.DataModules[I]);
    //re-select the current form, if exists
    if not Assigned(CurrForm) then
      CurrForm := Application.MainForm;
    Pos := cbForms.Items.IndexOfObject(CurrForm);
    if Pos < 0 then
    begin
      //was a destroyed form, retry...
      CurrForm := Application.MainForm;
      Pos := cbForms.Items.IndexOfObject(CurrForm);
    end;
    cbForms.ItemIndex := Pos;
  finally
    cbForms.Items.EndUpdate;
    SetCursor(TCursor(crDefault));
  end;

  UpdateCompsCombo;
end;

procedure TFMXObjectDebuggerFrame.UpdateCompsCombo;
var
  nComp, Pos: Integer;
  Comp: TComponent;
begin
  try
    cbComps.Items.BeginUpdate;

    cbComps.Items.Clear;
    cbComps.Items.AddObject(Format('%s: %s',
      [CurrForm.Name, CurrForm.ClassName]), CurrForm);
    for nComp := 0 to CurrForm.ComponentCount - 1 do
    begin
      Comp := CurrForm.Components[nComp];

      // Don't add debugger frame
      if Comp <> Self then
        cbComps.Items.AddObject(Format('%s: %s',
          [Comp.Name, Comp.ClassName]), Comp);
    end;
    //reselect the current component, if any
    if not Assigned(CurrComp) then
      CurrComp := CurrForm;
    Pos := cbComps.Items.IndexOfObject(CurrComp);
    if Pos < 0 then
      Pos := cbComps.Items.IndexOfObject(CurrForm);
    if cbComps.ItemIndex <> Pos then
      cbComps.ItemIndex := Pos;
  finally
    cbComps.Items.EndUpdate;
  end;

  UpdateProps;
  UpdateData;
end;

procedure TFMXObjectDebuggerFrame.UpdateProps;
//update property and event pages
var
  PropList, SubPropList: TPropList;
  NumberOfProps, NumberOfSubProps, //total number of properties
  nProp, nSubProp, //property loop counter
  nRowProp, nRowEvt: Integer; //items actually added
  SubObj: TPersistent;
begin
  try
    //reset the type
    sgProp.ColumnByIndex(1).Header := '';
    sgEvt.ColumnByIndex(1).Header := '';

    //get the number of properties
    NumberOfProps := GetTypeData(CurrComp.ClassInfo).PropCount;
    //exaggerate in size...
    sgProp.RowCount := NumberOfProps;
    sgEvt.RowCount := NumberOfProps;

    SetLength(sgPropObjects[0], sgProp.RowCount);
    SetLength(sgPropObjects[1], sgProp.RowCount);
    SetLength(sgEvtObjects[0], sgEvt.RowCount);
    SetLength(sgEvtObjects[1], sgEvt.RowCount);

    //get the list of properties and sort it
    GetPropInfos(CurrComp.ClassInfo, @PropList);
    SortPropList(@PropList, NumberOfProps);

    //show the name of each property
    //adding it to the proper page
    nRowProp := 0;
    nRowEvt := 0;
    for nProp := 0 to NumberOfProps - 1 do
    begin
      //if it is a real property
      if PropList[nProp].PropType^.Kind <> tkMethod then
      begin
        //name
        sgProp.Cells[0, nRowProp] := GetPropName(PropList[nProp]);

        //value
        sgProp.Cells[1, nRowProp] := GetPropValAsString(
          CurrComp, PropList[nProp]);
        //data
        sgPropObjects[0, nRowProp] := PropList[nProp];
        sgPropObjects[1, nRowProp] := nil;

        //move to the next line
        Inc(nRowProp);

        //if the property is a class
        if (PropList[nProp].PropType^.Kind = tkClass) then
        begin
          SubObj := TPersistent(GetOrdProp(
            CurrComp, PropList[nProp]));
          if (SubObj <> nil) and not(SubObj is TComponent) then
          begin
            NumberOfSubProps := GetTypeData(SubObj.ClassInfo).PropCount;
            if NumberOfSubProps > 0 then
            begin
              //add plus sign
              sgProp.Cells[0, nRowProp - 1] := '+' +
                sgProp.Cells[0, nRowProp - 1];
              //add space for subproperties...
              sgProp.RowCount := sgProp.RowCount + NumberOfSubProps;
              SetLength(sgPropObjects[0], sgProp.RowCount);
              SetLength(sgPropObjects[1], sgProp.RowCount);

              //get the list of subproperties and sort it
              GetPropInfos(SubObj.ClassInfo, @SubPropList);
              SortPropList(@SubPropList, NumberOfSubProps);
              //show the name of each subproperty
              for nSubProp := 0 to NumberOfSubProps - 1 do
              begin
                //if it is a real property
                if SubPropList[nSubProp].PropType^.Kind <> tkMethod then
                begin
                  //name (indented)
                  sgProp.Cells[0, nRowProp] :=
                    '    ' + GetPropName(SubPropList[nSubProp]);
                  //value
                  sgProp.Cells[1, nRowProp] := GetPropValAsString(
                    SubObj, SubPropList[nSubProp]);
                  //data
                  sgPropObjects[0, nRowProp] :=
                    TObject(SubPropList[nSubProp]);
                  sgPropObjects[1, nRowProp] := SubObj;
                  Inc(nRowProp);
                end; //if
              end; //for
            end;
          end;
        end; //adding subproperties
      end
      else //it is an event
      begin
        //name
        sgEvt.Cells[0, nRowEvt] := GetPropName(PropList[nProp]);
        //value
        sgEvt.Cells[1, nRowEvt] := GetPropValAsString(
          CurrComp, PropList[nProp]);
        //data
        sgEvtObjects[0, nRowEvt] := TObject(PropList[nProp]);
        //next
        Inc(nRowEvt);
      end;
    end; //for
    //set the actual rows
    sgProp.RowCount := nRowProp;
    sgEvt.RowCount := nRowEvt;
    SetLength(sgPropObjects[0], sgProp.RowCount);
    SetLength(sgPropObjects[1], sgProp.RowCount);
    SetLength(sgEvtObjects[0], sgEvt.RowCount);
    SetLength(sgEvtObjects[1], sgEvt.RowCount);

  except
    on E: Exception do
      Log.d(E.ClassName + ': ' + E.Message);
  end;
end;

procedure TFMXObjectDebuggerFrame.UpdateData;
var
  nRow: Integer;

  procedure AddLine(Name, Value: string; pti: PTypeInfo);
  begin
    sgData.Cells[0, nRow] := Name;
    sgData.Cells[1, nRow] := Value;
    sgDataObjects[0, nRow] := Pointer(pti);
    //sgPropObjects[1, nRow] := nil;   // TODO Bug in original VCL code?
    sgDataObjects[1, nRow] := nil;
    Inc(nRow);
  end;

begin
  //reset type
  sgEvt.ColumnByIndex(1).Header := '';

  nRow := 0;
  //exaggerate...
  sgData.RowCount := 15;
  SetLength(sgDataObjects[0], sgData.RowCount);
  SetLength(sgDataObjects[1], sgData.RowCount);

  //add component runtime properties
  AddLine('ComponentCount',
    IntToStr(CurrComp.ComponentCount),
    TypeInfo(Integer));
  {useless... AddLine ('ComponentState', SetToString (
    Byte (CurrComp.ComponentState),  TypeInfo (TComponentState)));}
  AddLine('ComponentIndex',
    IntToStr(CurrComp.ComponentIndex),
    TypeInfo(Integer));
  AddLine('ComponentStyle',
    SetToString(Byte(CurrComp.ComponentStyle),
    TypeInfo(TComponentStyle)),
    TypeInfo(TComponentStyle));
  if CurrComp.Owner <> nil then
    if CurrComp.Owner = Application then
      AddLine('Owner',
        'Application',
        TypeInfo(TComponent))
    else
      AddLine('Owner',
        CurrComp.Owner.Name,
        TypeInfo(TComponent))
  else //owner = nil
    AddLine('Owner',
      'none',
      TypeInfo(TComponent));
  //add control runtme properties
  if CurrComp is TControl then
    with TControl(CurrComp) do
    begin
      //Just to add something...
      //(Might be relevant sometimes if different from ComponentIndex)
      AddLine('TabOrder',
        IntToStr(TabOrder),
        TypeInfo(Int16));
      (*
        // TODO Is there something comparable in FireMonkey worth showing here?
        AddLine('ControlState',
        SetToString(Cardinal(ControlState), TypeInfo(TControlState)),
        TypeInfo(TControlState));
        AddLine('ControlStyle',
        SetToString(Cardinal(ControlStyle), TypeInfo(TControlStyle)),
        TypeInfo(TControlStyle));
      *)
      if Parent <> nil then
        AddLine('Parent',
          Parent.Name,
          TypeInfo(TFmxObject))
      else
        AddLine('Parent',
          'none',
          TypeInfo(TFmxObject));
      {3.0 only: AddLine ('WindowProc', IntToStr (Integer (WindowProc)));}
    end;

  AddLine('ChildrenCount',
    IntToStr(ChildrenCount),
    TypeInfo(Integer));

  (*
    // TODO Is there something comparable in FireMonkey worth showing here?
    // add win control runtime properties
    if nil <> (CurrComp as INativeControl) then
    with CurrComp as INativeControl do
    begin
    // AddLine ('Brush', // show handle + style + color ?
    AddLine('Handle',
    '$' + IntToHex(NativeUint(Handle), 8),
    TypeInfo(TFmxHandle));
    // 3.0 only: AddLine ('ParentWindow (Handle)', IntToHex (ParentWindow, 16));
    AddLine('Showing',
    GetEnumName(TypeInfo(Boolean), Integer(Showing)),
    TypeInfo(Boolean));
    end;
  *)
  //set the actual number of rows
  sgData.RowCount := nRow;
  SetLength(sgDataObjects[0], sgData.RowCount);
  SetLength(sgDataObjects[1], sgData.RowCount);
end;

procedure TFMXObjectDebuggerFrame.cbCompsChange(Sender: TObject);
begin
  //select the new component
  if (-1 = cbComps.ItemIndex) then
    Exit;

  CurrComp := cbComps.Items.Objects[
    cbComps.ItemIndex] as TComponent;

  //update the grids
  UpdateProps;
  UpdateData;
end;

procedure TFMXObjectDebuggerFrame.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //never close the form...
  Action := TCloseAction.caMinimize;
end;

constructor TFMXObjectDebuggerFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCopyright := CopyrightString;

  if not(csDesigning in ComponentState) then
  begin
    Initialize;
  end;
end;

// If this were a form, you'd put this into the OnCreate handler.
procedure TFMXObjectDebuggerFrame.Initialize;
var
  I: TMyCursor;
begin
  CurrForm := nil;
  CurrComp := nil;
  RealComp := nil;
  EditingSub := False;

  //set first line
  sgProp.ColumnByIndex(0).Header := 'Property Type: (click for detail)';
  sgEvt.ColumnByIndex(0).Header := 'Property Type: (click for detail)';
  sgData.ColumnByIndex(0).Header := 'Property Type:';

  //show the first page
  TabControl1.ActiveTab := TabItemProperties;

  //fill input combos
  for I := crDefault to crSizeAll do
    ComboCursor.Items.Add(MyCursorToString(TCursor(-Ord(I)))); // Note negative used.

  GetColorValues(AddToComboColor);

  Self.Visible := True;

  Timer1.Enabled := True;
end;

procedure TFMXObjectDebuggerFrame.AddToComboColor(const S: String);
begin
  ComboColor.Items.Add(S);
end;

procedure TFMXObjectDebuggerFrame.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  Show;
  UpdateFormsCombo;
end;

// TODO Add way of invoking local menu for mobile apps (eg, long press).
procedure TFMXObjectDebuggerFrame.FrameMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  ptPopup, pt: TPointF;
begin
  if Button <> TMouseButton.mbRight then
    Exit;

  ptPopup.X := X + Self.Position.X;
  ptPopup.Y := Y + Self.Position.Y;

  pt := (Root as TCommonCustomForm).ClientToScreen(ptPopup);
  PopupMenu1.Popup(pt.X, pt.Y);
end;

procedure TFMXObjectDebuggerFrame.ListSetClick(Sender: TObject);
var
  Value: Word;
  I: Integer;
begin
  if (nil = CurrComp) or (nil = CurrProp) then
    Exit;

  Value := 0;
  //update the value, scanning the list
  for I := 0 to ListSet.Items.count - 1 do
    if ListSet.Items[I].Checked then
      Value := Value + Round(IntPower(2, I));
  SetOrdProp(CurrComp, CurrProp, Value);
end;

procedure TFMXObjectDebuggerFrame.MenuItemAboutClick(Sender: TObject);
begin
  //Show an about box
  MessageForm.ShowMessage(VersionDescription + #13 + VersionRelease + #13#13 + CopyrightString, 'About...');
end;

procedure TFMXObjectDebuggerFrame.MenuItemInfoClick(Sender: TObject);
begin
  MessageForm.ShowMessage(VersionDescription
    + #13
    + CopyrightString
    + #13#13
    + 'Based on version 5.0 of the (VCL) Object Debugger for Delphi by Marco Cantù'
    + #13#13 +
    'Usage: Select the form and component you are interested in ' +
    '(the form is also listed among its components); the grid will display ' +
    'the published properties and events as well as some mode data for the component. '#13#13 +
    'Clicking on the first line in the grid will display RTTI information for ' +
    'the last property selected.'#13#13 +
    'Clicking on a value activates its editor (if available). ' +
    'Editors include: numbers, strings, characters, ' +
    'enumerations, sets, cursors, colors (double-click), ' +
    'string lists (double click).',
    'Information...');
end;

procedure TFMXObjectDebuggerFrame.MenuItemRefreshComponentsClick(Sender: TObject);
begin
  UpdateCompsCombo;
end;

procedure TFMXObjectDebuggerFrame.MenuItemRefreshFormsClick(Sender: TObject);
begin
  UpdateFormsCombo;
end;

procedure TFMXObjectDebuggerFrame.MenuItemRefreshValuesClick(Sender: TObject);
begin
  UpdateProps;
end;

// The first time you select this menu item, this frame will be hidden.
// If you want to make it visible again, your app or parent form will need
// an action to set its Visible property to True; in this case,
// remember to set this menuitem's IsChecked property to True as well.
procedure TFMXObjectDebuggerFrame.MenuItemVisibleClick(Sender: TObject);
begin
  MenuItemVisible.IsChecked := not MenuItemVisible.IsChecked;

  Self.Visible := MenuItemVisible.IsChecked;
end;

procedure TFMXObjectDebuggerFrame.sgResize(Sender: TObject);
begin
  with Sender as TStringGrid do
  begin
    ColumnByIndex(1).Width := ClientWidth - ColumnByIndex(0).Width;
  end;
end;

procedure TFMXObjectDebuggerFrame.sgPropHeaderClick(Column: TColumn);
var
  PropInfo: PPropInfo;
begin
  //  Log.d('sgPropHeaderClick');

  if (sgProp.ColumnByIndex(1).Header <> '') then
  begin
    PropInfo := PPropInfo(sgPropObjects[0, CurrRow]);
    ShowRttiDetail(PropInfo.PropType^);
  end;
end;

procedure TFMXObjectDebuggerFrame.sgEvtHeaderClick(Column: TColumn);
var
  PropInfo: PPropInfo;
begin
  //  Log.d('sgEvtHeaderClick');

  if (sgEvt.ColumnByIndex(1).Header <> '') then
  begin
    PropInfo := PPropInfo(sgEvtObjects[0, CurrRowEvt]);
    ShowRttiDetail(PropInfo.PropType^);
  end;
end;

procedure TFMXObjectDebuggerFrame.sgDataHeaderClick(Column: TColumn);
begin
  //  Log.d('sgDataHeaderClick');

  if (sgData.ColumnByIndex(1).Header <> '') then
  begin
    ShowRttiDetail(PTypeInfo(sgDataObjects[0, CurrRowData]));
  end;
end;

procedure TFMXObjectDebuggerFrame.sgPropDblClick(Sender: TObject);
begin
  //  Log.d('sgPropDblClick');

  if CurrProp <> nil then
  begin
    if GetTypeName(CurrProp.PropType^) = 'TFont' then
    begin
      MessageForm.ShowMessage('Font dialog support not yet supported.', 'Fonts');
      (*TODO
        FontDialog1.Font.Assign(
        TFont(GetOrdProp(CurrComp, CurrProp)));
        if FontDialog1.Execute then
        begin
        TFont(GetOrdProp(CurrComp, CurrProp)).
        Assign(FontDialog1.Font);
        UpdateProps;
        end;
      *)
    end;

    //string list editor...
    if GetTypeName(CurrProp.PropType^) = 'TStrings' then
      EditStringList(TStrings(
        GetOrdProp(CurrComp, CurrProp)));
  end;
end;

procedure TFMXObjectDebuggerFrame.sgPropTap(Sender: TObject; const Point: TPointF);
begin
  // Mobile tap performs same operation as mouse double click.
  sgPropDblClick(nil);
end;

procedure TFMXObjectDebuggerFrame.RefreshOnExit(Sender: TObject);
begin
  //  Log.d('RefreshOnExit: ' + Sender.ToString);

  sgProp.Cells[1, CurrRow] := GetPropValAsString(CurrComp, CurrProp);
  (Sender as TControl).Visible := False;
  if EditingSub then
    CurrComp := RealComp;
end;

function TFMXObjectDebuggerFrame.GetStringGridObjects(sg: TStringGrid): TSGObjects;
begin
  if (sgProp = sg) then
    Exit(sgPropObjects)
  else if (sgEvt = sg) then
    Exit(sgEvtObjects)
  else if (sgData = sg) then
    Exit(sgDataObjects);

  Assert(False, '*** Unexpected condition reached. ***');
end;

// Something like this really should be a TStringGrid method.
function CellRect(sg: TStringGrid; Col, Row: Integer): TRectF;
const
  // TODO To make this function more general purpose, this should be determined at runtime.
  HeaderVisible = True;
  // TODO Should be determined at runtime if needed, ie, if cell in last column and only if the vertical scrollbar is visible.
  margin = 25;
var
  Column: TColumn;
begin
  Column := sg.ColumnByIndex(Col);

  Result.Left := Column.Position.X - sg.ViewportPosition.X;
  // Subtract a little in case vertical scrollbar is visible.
  // In general, only do this if cell is in the last column and the scrollbar is visible.
  Result.Right := Result.Left + Column.Width - margin;

  Result.Top := Row * sg.RowHeight - sg.ViewportPosition.Y;
  if HeaderVisible then
    Result.Top := Result.Top + sg.RowHeight;

  Result.Bottom := Result.Top + sg.RowHeight;

  if Result.Bottom > sg.{Client}Height then //TODO: commented out "Client" to compile, use other?
  begin
    // This may cause problems with display if user scrolls after selecting cell, but still an improvement over not doing it.
    // Need to add event to check for this condition after scrolling.
    Result.Bottom := sg.{Client}Height; //TODO: commented out "Client" to compile, use other?
  end;

  //Log.d('(' + FloatToStr(Result.Left) + ', ' + FloatToStr(Result.Top) + ') x (' + FloatToStr(Result.Right) + ', ' +  FloatToStr(Result.Bottom) + ')');
end;

procedure TFMXObjectDebuggerFrame.PlaceControl(Ctrl: TControl; sg: TStringGrid; ACol, ARow: Integer);
begin
  // Save previous edit if necessary.
  if (nil <> ctrlToMove) and (Ctrl <> ctrlToMove) and (ctrlToMove.Visible) then
    RefreshOnExit(ctrlToMove);

  Ctrl.BringToFront;
  Ctrl.Visible := True;
  // Only place on second column.
  Ctrl.BoundsRect := CellRect(sg, 1, ARow);
  (Root as TCommonCustomForm).Focused := Ctrl;

  ctrlToMove := Ctrl;
end;

// Used to reposition the edit control after scrolling or resizing the stringgrid.
procedure TFMXObjectDebuggerFrame.PlaceControlAgain;
begin
  if (nil <> ctrlToMove) and (ctrlToMove.Visible) then
    PlaceControl(ctrlToMove, sgProp, 1, sgProp.Selected);
end;

procedure TFMXObjectDebuggerFrame.sgPropViewportPositionChange(Sender: TObject;
  const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
begin
  //  Log.d('sgPropViewportPositionChange');

  PlaceControlAgain;
end;

procedure TFMXObjectDebuggerFrame.sgPropResize(Sender: TObject);
begin
  sgResize(Sender);

  PlaceControlAgain;
end;

procedure TFMXObjectDebuggerFrame.sgPropSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  sg: TStringGrid;
  sgObjects: TSGObjects;
  ppInfo: PPropInfo;
  I: Integer;

begin
  //  Log.d('sgPropSelectCell');

  sg := Sender as TStringGrid; // Should always be sgProp or sgEvt

  sgObjects := GetStringGridObjects(sg);

  //get the data and show it in the first line
  ppInfo := PPropInfo(sgObjects[0, ARow]); //TODO: can throw Range Check Error
  if (ppInfo = nil) then
    Exit;

  sg.ColumnByIndex(1).Header := GetTypeName(ppInfo.PropType^);

  if sg = sgEvt then
  begin
    CurrRowEvt := ARow;
    Exit;
  end;

  if (nil <> ctrlToMove) and (CurrRow <> ARow) then
    ctrlToMove.Visible := False;

  CurrRow := ARow;
  //if second column activate the proper editor
  if ACol = 1 then
  begin
    CurrProp := ppInfo;
    CurrRow := ARow;
    //if it is a subproperty, select the value of
    //the property as the current component
    if sgObjects[1, ARow] <> nil then
    begin
      RealComp := CurrComp;
      EditingSub := True;
      CurrComp := TComponent(sgObjects[1, ARow]);
    end
    else
      CurrComp := cbComps.Items.Objects[
        cbComps.ItemIndex] as TComponent;

    /// /////// depending on the type, show up an editor
    case ppInfo.PropType^.Kind of

      tkInteger:
        /// /////////////////////////////////////
        begin
          if GetTypeName(ppInfo.PropType^) = 'TCursor' then
          begin
            ComboCursor.Text := GetPropValAsString(CurrComp, ppInfo);
            PlaceControl(ComboCursor, sg, ACol, ARow);
          end
          else if GetTypeName(ppInfo.PropType^) = 'TColor' then
          begin
            ComboColor.Tag := GetOrdProp(CurrComp, ppInfo);
            ComboColor.Text := GetPropValAsString(CurrComp, ppInfo);
            PlaceControl(ComboColor, sg, ACol, ARow)
          end
          else
          begin
            EditNum.Text := GetPropValAsString(CurrComp, ppInfo);
            PlaceControl(EditNum, sg, ACol, ARow);
            EditModified := False;
          end;
        end;

      tkChar:
        /// /////////////////////////////////////////
        begin
          EditCh.Text := GetPropValAsString(CurrComp, ppInfo);
          PlaceControl(EditCh, sg, ACol, ARow);
          EditModified := False;
        end;

      tkEnumeration:
        /// //////////////////////////////////
        begin
          ComboEnum.Clear;
          ListEnum(ppInfo.PropType^, ComboEnum.Items, False);
          ComboEnum.ItemIndex := ComboEnum.Items.IndexOf(
            GetPropValAsString(CurrComp, ppInfo));
          PlaceControl(ComboEnum, sg, ACol, ARow);
        end;

      tkString, tkLString, tkUString, tkWString:
        /// ///////////////////////
        begin
          EditStr.Text := GetPropValAsString(
            CurrComp, ppInfo);
          PlaceControl(EditStr, sg, ACol, ARow);
          EditModified := False;
        end;

      tkSet:
        /// /////////////////////////////////////
        begin
          ListSet.Items.Clear;
          ListEnum2(
            GetTypeData(ppInfo.PropType^).CompType^,
            ListSet.Items, False);
          //select the "on" items
          for I := 0 to ListSet.Items.count - 1 do
            ListSet.Items[I].Checked := IsBitOn(GetOrdProp(CurrComp, ppInfo), I);
          PlaceControl(ListSet, sg, ACol, ARow);
          ListSet.Height := ListSet.Height * 8;
        end;
      //tkClass: //// see double click...
    end;
  end;
end;

procedure TFMXObjectDebuggerFrame.sgDataSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  sg: TStringGrid;
  sgObjects: TSGObjects;
  ptInfo: PTypeInfo;
begin
  //  Log.d('sgDataSelectCell');

  sg := Sender as TStringGrid; // Should always be sgData
  if (ARow >= sg.RowCount) or (0 > ARow) then
    Exit;

  sgObjects := GetStringGridObjects(sg);

  ptInfo := PTypeInfo(sgObjects[0, ARow]);
  if Assigned(ptInfo) then
  begin
    sg.ColumnByIndex(1).Header := GetTypeName(ptInfo);
  end
  else
  begin
    sg.ColumnByIndex(1).Header := '';
  end;

  CurrRowData := ARow;
end;

//create and show a dialog box a string list editor..
procedure TFMXObjectDebuggerFrame.EditStringList(Str: TStrings);
var
  F: TForm;
  P: TPanel;
  I: Integer;
  Memo1: TMemo;
begin
  F := MessageForm;
  P := TPanel.Create(F);
  try
    //middle of the screen
    F.Left := round(Screen.Width / 2 - 125);
    F.Top := round(Screen.Height / 2 - 150);
    F.Caption := 'StringList Editor for ' + GetPropName(CurrProp);

    (F as TMessageForm).AddPanel(P);
    Memo1 := TMemo.Create(P);
    with Memo1 do
    begin
      Parent := P;
      Width := P.Width - 30;
      Height := P.Height - 30;
      Position.X := 15;
      Position.Y := 15;
      Align := TAlignLayout.None;
      Anchors := [TAnchorKind.akTop, TAnchorKind.akBottom, TAnchorKind.akLeft, TAnchorKind.akRight];
      for I := 0 to Str.count - 1 do
        Lines.Add(Str[I]);
    end;
    // Plain old ShowModal not supported on Android so use newer version with support for callback.
    F.ShowModal(
      procedure(ModalResult: TModalResult)
      var
        I: Integer;
      begin
        if ModalResult = mrOk then
        begin
          Str.Clear;
          for I := 0 to Memo1.Lines.count - 1 do
            Str.Add(Memo1.Lines[I]);
        end;
      end);
  finally

  end;
end;

procedure TFMXObjectDebuggerFrame.cbFormsChange(Sender: TObject);
begin
  if (-1 = cbForms.ItemIndex) then
    Exit;

  //save the current form or data module
  CurrForm := cbForms.Items.Objects[
    cbForms.ItemIndex] as TComponent;
  //update the list of components
  UpdateCompsCombo;
end;

procedure TFMXObjectDebuggerFrame.ComboColorChange(Sender: TObject);
var
  Color: Integer;
begin
  if IdentToColor(ComboColor.Text, Color) then
    ComboColor.Tag := Color
  else
    Color := TColor(ComboColor.Tag);
  SetOrdProp(CurrComp, CurrProp, Color);
end;

procedure TFMXObjectDebuggerFrame.ComboColorDblClick(Sender: TObject);
var
  Color: Integer;
  //ColName: string;
  //nItem: Integer;
begin
  if not IdentToColor(ComboColor.Text, Color) then
    Color := TColor(ComboColor.Tag);

  MessageForm.ShowMessage('Color dialog support not yet supported.', 'Color');
  (*TODO
    ColorDialog1.Color := Color;
    if ColorDialog1.Execute then
    begin
    ComboColor.Tag := ColorDialog1.Color;
    ColName := ColorToString (ColorDialog1.Color);
    nItem := ComboColor.Items.IndexOf (ColName);
    if nItem >= 0 then
    ComboColor.ItemIndex := nItem
    else
    ComboColor.Text := ColName;
    ComboColorChange (ComboColor);
    end;
    end;
  *)
end;

procedure TFMXObjectDebuggerFrame.ComboCursorChange(Sender: TObject);
begin
  // TODO Do nothing for crNone or let exception be thrown?
  // Or just not include crNone in list?
  if 'crNone' = ComboCursor.Text then
    Exit;
  SetOrdProp(CurrComp, CurrProp,
    StringToCursor(ComboCursor.Text));
end;

procedure TFMXObjectDebuggerFrame.ComboEnumChange(Sender: TObject);
begin
  SetOrdProp(CurrComp, CurrProp,
    GetEnumValue(CurrProp.PropType^, ComboEnum.Text));
end;

procedure TFMXObjectDebuggerFrame.ComboEnumDblClick(Sender: TObject);
begin
  with ComboEnum do
    if ItemIndex < Items.count - 1 then
      ItemIndex := ItemIndex + 1
    else
      ItemIndex := 0;
  ComboEnumChange(ComboEnum);
end;

procedure TFMXObjectDebuggerFrame.EditChange(Sender: TObject);
begin
  EditModified := True;
end;

procedure TFMXObjectDebuggerFrame.EditChExit(Sender: TObject);
var
  Ch: Char;
begin
  try
    if EditModified then
    begin
      if Length(EditCh.Text) = 1 then
        Ch := EditCh.Text[1]
      else if EditCh.Text[1] = '#' then
        Ch := Char(StrToInt(Copy(
          EditCh.Text, 2, Length(EditCh.Text) - 1)))
      else
        raise EConvertError.Create('Error');
      SetOrdProp(CurrComp, CurrProp, Word(Ch));
    end;
    RefreshOnExit(Sender);
  except
    on EConvertError do
    begin
      MessageForm.ShowMessage('Not a valid character', 'Error');
      EditCh.SetFocus;
    end;
  end;
end;

procedure TFMXObjectDebuggerFrame.EditNumExit(Sender: TObject);
begin
  try
    if EditModified then
      SetOrdProp(CurrComp, CurrProp, StrToInt(EditNum.Text));
    RefreshOnExit(Sender);
  except
    on EConvertError do
    begin
      MessageForm.ShowMessage('Not a number', 'Error');
      EditNum.SetFocus;
    end;
  end;
end;

procedure TFMXObjectDebuggerFrame.EditNumKeyDown(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  // [DCC Warning] ObjectDebuggerFMXForm.pas(1144): W1000 Symbol 'CharInSet' is deprecated: 'Use TCharHelper functionality'
  if not CharInSet(KeyChar, ['0' .. '9', #8]) then // Include backspace, don't need to include tab #9
    KeyChar := #0;
end;

procedure TFMXObjectDebuggerFrame.EditStrExit(Sender: TObject);
begin
  try
    if EditModified then
      SetStrProp(CurrComp, CurrProp, EditStr.Text);
  finally
    RefreshOnExit(Sender);
  end;
end;

//support function: get the form (or data module)
//owning the component
function GetOwnerForm(Comp: TComponent): TComponent;
begin
  while not(Comp is TForm) and
    not(Comp is TDataModule) do
    Comp := Comp.Owner;
  Result := Comp;
end;

//from the Bits1 example (Chapter 1)
function IsBitOn(Value: Integer; Bit: Byte): Boolean;
begin
  Result := (Value and (1 shl Bit)) <> 0;
end;

//support function: convert set value
//into a string as in the Object Inspector

function SetToString(Value: Cardinal; pti: PTypeInfo): string;
var
  Res: String; //result
  BaseType: PTypeInfo;
  I: Integer;
  Found: Boolean;
begin
  Found := False;
  //open the expression
  Res := '[';
  //get the type of the enumeration
  //the set is based onto
  BaseType := GetTypeData(pti).CompType^;
  //for each possible value
  for I := GetTypeData(BaseType).MinValue
    to GetTypeData(BaseType).MaxValue do
    //if the bit I (computed as 1 shl I) is set,
    //then the corresponding element is in the set
    //(the and is a bitwise and, not a boolean operation)
    if IsBitOn(Value, I) then
    begin
      //add the name of the element
      Res := Res + GetEnumName(BaseType, I) + ', ';
      Found := True;
    end;
  if Found then
    //remove the final comma and space (2 chars)
    Res := Copy(Res, 1, Length(Res) - 2);
  //close the expression
  Result := Res + ']';
end;

//return the property value as a string
function GetPropValAsString(Obj: TObject; PropInfo: PPropInfo): string;
var
  pt: Pointer;
  Word: Cardinal;
begin
  case PropInfo.PropType^.Kind of

    tkUnknown:
      Result := 'Unknown type';

    tkChar:
      begin
        Word := GetOrdProp(Obj, PropInfo);
        if Word > 32 then
          Result := Char(Word)
        else
          Result := '#' + IntToStr(Word);
      end;

    tkWChar:
      begin
        Word := GetOrdProp(Obj, PropInfo);
        if Word > 32 then
          Result := WideChar(Word)
        else
          Result := '#' + IntToStr(Word);
      end;

    tkInteger:
      if GetTypeName(PropInfo.PropType^) = 'TColor' then
        Result := MyColorToString(GetOrdProp(Obj, PropInfo))
      else if GetTypeName(PropInfo.PropType^) = 'TCursor' then
        Result := MyCursorToString(GetOrdProp(Obj, PropInfo))
      else
        Result := Format('%d', [GetOrdProp(Obj, PropInfo)]);

    tkEnumeration:
      Result := GetEnumName(PropInfo.PropType^,
        GetOrdProp(Obj, PropInfo));

    tkFloat:
      Result := FloatToStr(GetFloatProp(Obj, PropInfo));

    tkString, tkLString, tkUString, tkWString:
      Result := GetStrProp(Obj, PropInfo);

    tkSet:
      Result := SetToString(GetOrdProp(Obj, PropInfo), PropInfo.PropType^);

    tkClass:
      begin
        pt := Pointer(GetOrdProp(Obj, PropInfo));
        if pt = nil then
          Result := '(None)'
        else
          Result := Format('(Object %p)', [pt]);
      end;

    tkMethod:
      begin
        pt := GetMethodProp(Obj, PropInfo).Code;
        if pt <> nil then
          Result := GetOwnerForm(Obj as TComponent).MethodName(pt)
        else
          Result := '';
      end;

    tkVariant:
      Result := GetVariantProp(Obj, PropInfo);

    tkArray, tkRecord, tkInterface:
      Result := 'Unsupported type';

  else
    Result := 'Undefined type';
  end;
end;

function MyCursorToString(Cursor: TCursor): string;
begin
  //Note that 5 should never occur (no cursor defined with that value).
  //Also, since crSize (22) has the same value as crSizeAll, crSizeAll will be the name returned.

  Result := GetEnumName(TypeInfo(TMyCursor), -Cursor);
end;

//Cribbed from Vcl.Graphics
function MyColorToString(Color: TColor): string;
begin
  Result := System.UIConsts.ColorToString(Color);
end;

procedure SetCursor(crCursor: TCursor);
var
  CS: IFMXCursorService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXCursorService) then
  begin
    CS := TPlatformServices.Current.GetPlatformService(IFMXCursorService) as IFMXCursorService;
  end;
  if Assigned(CS) then
  begin
    CS.SetCursor(crCursor);
  end;
end;

{$IF NOT (defined(IOS) or defined(ANDROID))}


function ShortStringToString(PStr: PShortString): string;
begin
{$WARN IMPLICIT_STRING_CAST OFF}  // [dcc32 Warning] ObjectDebuggerFMXFrame.pas(1402): W1057 Implicit string cast from 'ShortString' to 'string'
  Result := PStr^; // Not much really to do here.
{$WARN IMPLICIT_STRING_CAST ON}
end;
{$ELSE}


type
  ShortString = Byte;
  PShortString = ^ShortString;

  TShortStringBytes = array [0 .. 255] of Byte;
  PShortStringBytes = ^TShortStringBytes;

function ShortStringToString(PStr: Pointer): string;
var
  bytes: PShortStringBytes;
  len: Integer;
  I: Integer;
begin
  bytes := PShortStringBytes(PStr);
  len := bytes[0];
  if 0 = len then
    Exit('');

  //  Log.d('Length: ' + IntToStr(len));

  SetLength(Result, len);
{$IF defined(IOS) or defined(ANDROID)}
  // Crude but seems sufficient.
  for I := 1 to len do
  begin
    //    Log.d(IntToStr(I) + ': [' + IntToStr(Integer(bytes[I])) + ',' + Char(bytes[I]) + ',' + Chr(bytes[I])+ ']');
    // ??? Isn't length supposed to be stored in index 0.
    // So why does this work but using Result[I] instead of Result[I-1] produces string with incorrect first character and missing last character.
    Result[I - 1] := Chr(bytes[I]);
  end;
{$ELSE} // Windows, Mac OS X
  SetString(Result, PAnsiChar(@bytes[1]), len);
{$ENDIF}
end;

{$ENDIF}


//redeclaration of RTTI type
type
  TParamData = record
    Flags: TParamFlags;
    ParamName: ShortString;
    TypeName: ShortString;
    //beware: string length varies!!!
  end;

  PParamData = ^TParamData;

  //show RTTI information for method pointers
procedure ShowMethod(pti: PTypeInfo; sList: TStrings);
var
  ptd: PTypeData;
  pParam: PParamData;
  nParam: Integer;
  Line: string;
  pTypeString, pReturnString: ^ShortString;
  strParamName, strTypeString, strReturnString: string;
begin
  //protect against misuse
  if pti^.Kind <> tkMethod then
    raise Exception.Create('Invalid type information');

  //get a pointer to the TTypeData structure
  ptd := GetTypeData(pti);

  //1: access the TTypeInfo structure
  sList.Add('Type Name: ' + GetTypeName(pti));
  sList.Add('Type Kind: ' + GetEnumName(
    TypeInfo(TTypeKind),
    Integer(pti^.Kind)));

  //2: access the TTypeData structure
  sList.Add('Method Kind: ' + GetEnumName(
    TypeInfo(TMethodKind),
    Integer(ptd^.MethodKind)));
  sList.Add('Number of parameter: ' +
    IntToStr(ptd^.ParamCount));

  //3: access to the ParamList
  //get the initial pointer and
  //reset the parameters counter
  pParam := PParamData(@(ptd^.ParamList));
  nParam := 1;
  //loop until all parameters are done
  while nParam <= ptd^.ParamCount do
  begin
    //read the information
    Line := 'Param ' + IntToStr(nParam) + ' > ';
    //add type of parameter
    if pfVar in pParam^.Flags then
      Line := Line + 'var ';
    if pfConst in pParam^.Flags then
      Line := Line + 'const ';
    if pfOut in pParam^.Flags then
      Line := Line + 'out ';
    //get the parameter name
    strParamName := ShortStringToString(Pointer(@(pParam^.ParamName)));
    Line := Line + strParamName + ': ';
    //one more type of parameter
    if pfArray in pParam^.Flags then
      Line := Line + ' array of ';
    //the type name string must be located...
    //moving a pointer past the params and
    //the string (including its size byte)
    pTypeString := Pointer(Integer(pParam) +
      sizeof(TParamFlags) +
      Length(strParamName) + 1);
    //add the type name
    //    Test(pTypeString^);
    strTypeString := ShortStringToString(Pointer(pTypeString));
    Line := Line + strTypeString;
    //finally, output the string
    sList.Add(Line);
    //move the pointer to the next structure,
    //past the two strings (including size byte)
    pParam := PParamData(Integer(pParam) +
      sizeof(TParamFlags) +
      Length(strParamName) + 1 +
      Length(strTypeString) + 1);
    //increase the parameters counter
    Inc(nParam);
  end;
  //show the return type if a function
  if ptd^.MethodKind = mkFunction then
  begin
    //at the end, instead of a param data,
    //there is the return string
    // TODO Probably need to also use ShortStringToString here as well.
    pReturnString := Pointer(pParam);
    strReturnString := ShortStringToString(Pointer(pReturnString));
    sList.Add('Returns > ' + strReturnString);
  end;
end;

//show RTTI information for class type
procedure ShowClass(pti: PTypeInfo; sList: TStrings);
var
  ptd: PTypeData;
  ppi: PPropInfo;
  pProps: PPropList;
  nProps, I: Integer;
  ParentClass: TClass;
begin
  //protect against misuse
  if pti.Kind <> tkClass then
    raise Exception.Create('Invalid type information');

  //get a pointer to the TTypeData structure
  ptd := GetTypeData(pti);

  //access the TTypeInfo structure
  sList.Add('Type Name: ' + GetTypeName(pti));
  sList.Add('Type Kind: ' + GetEnumName(
    TypeInfo(TTypeKind),
    Integer(pti.Kind)));

  //access the TTypeData structure
  {omitted: the same information of pti^.Name...
    sList.Add ('ClassType: ' + ptd^.ClassType.ClassName);}
  sList.Add('Size: ' + IntToStr(
    ptd.ClassType.InstanceSize) + ' bytes');

  sList.Add('Defined in: ' + ptd.UnitNameFld.ToString + '.pas');

  //add the list of parent classes (if any)
  ParentClass := ptd.ClassType.ClassParent;
  if ParentClass <> nil then
  begin
    sList.Add('');
    sList.Add('=== Parent classes ===');
    while ParentClass <> nil do
    begin
      sList.Add(ParentClass.ClassName);
      ParentClass := ParentClass.ClassParent;
    end;
  end;

  //add the list of properties (if any)
  nProps := ptd.PropCount;
  if nProps > 0 then
  begin
    //format the initial output
    sList.Add('');
    sList.Add('=== Properties (' +
      IntToStr(nProps) + ') ===');
    //allocate the required memory
    GetMem(pProps, sizeof(PPropInfo) * nProps);
    //protect the memory allocation
    try
      //fill the TPropList structure
      //pointed to by pProps
      GetPropInfos(pti, pProps);
      //sort the properties
      SortPropList(pProps, nProps);
      //show name and data type of each property
      for I := 0 to nProps - 1 do
      begin
        ppi := pProps[I];
        sList.Add(GetPropName(ppi) + ': ' +
          GetTypeName(ppi.PropType^));
      end;
    finally
      //free the allocated memmory
      FreeMem(pProps, sizeof(PPropInfo) * nProps);
    end;
  end;
end;

//list enumerated values (used by next routine)
procedure ListEnum(pti: PTypeInfo;
sList: TStrings; ShowIndex: Boolean);
var
  I: Integer;
begin
  with GetTypeData(pti)^ do
    for I := MinValue to MaxValue do
      if ShowIndex then
        sList.Add('  ' + IntToStr(I) + '. ' +
          GetEnumName(pti, I))
      else
        sList.Add(GetEnumName(pti, I));
end;

//Similar to ListEnum, except we need to handle listviewitem's strings here.
procedure ListEnum2(pti: PTypeInfo; sList: TAppearanceListViewItems; ShowIndex: Boolean);
var
  I: Integer;
  ListViewItem: TListViewItem;
begin
  with GetTypeData(pti)^ do
    for I := MinValue to MaxValue do
    begin
      ListViewItem := sList.Add;
      if ShowIndex then
      begin
        ListViewItem.Text := '  ' + IntToStr(I) + '. ' + GetEnumName(pti, I);
      end
      else
        ListViewItem.Text := GetEnumName(pti, I);
    end;
end;

//show RTTI information for ordinal types
procedure ShowOrdinal(pti: PTypeInfo; sList: TStrings);
var
  ptd: PTypeData;
begin
  //protect against misuse
  if not(pti^.Kind in [tkInteger, tkChar,
    tkEnumeration, tkSet, tkWChar]) then
    raise Exception.Create('Invalid type information');

  //get a pointer to the TTypeData structure
  ptd := GetTypeData(pti);

  //access the TTypeInfo structure
  sList.Add('Type Name: ' + GetTypeName(pti));
  sList.Add('Type Kind: ' + GetEnumName(
    TypeInfo(TTypeKind),
    Integer(pti^.Kind)));

  //access the TTypeData structure
  sList.Add('Implement: ' + GetEnumName(
    TypeInfo(TOrdType),
    Integer(ptd^.OrdType)));

  //a set has no min and max
  if pti^.Kind <> tkSet then
  begin
    sList.Add('Min Value: ' + IntToStr(ptd^.MinValue));
    sList.Add('Max Value: ' + IntToStr(ptd^.MaxValue));
  end;

  //add the enumeration base type
  //and the list of the values
  if pti^.Kind = tkEnumeration then
  begin
    sList.Add('Base Type: ' + GetTypeName((ptd^.BaseType)^));
    sList.Add('');
    sList.Add('Values...');
    ListEnum(pti, sList, True);
  end;

  //show RRTI info about set base type
  if pti^.Kind = tkSet then
  begin
    sList.Add('');
    sList.Add('Set base type information...');
    ShowOrdinal(ptd^.CompType^, sList);
  end;
end;

//generic procedure, calling the other ones
procedure ShowRTTI(pti: PTypeInfo; sList: TStrings);
begin
  case pti^.Kind of
    tkInteger, tkChar, tkEnumeration, tkSet, tkWChar:
      ShowOrdinal(pti, sList);
    tkMethod:
      ShowMethod(pti, sList);
    tkClass:
      ShowClass(pti, sList);
    tkString, tkLString:
      begin
        sList.Add('Type Name: ' + GetTypeName(pti));
        sList.Add('Type Kind: ' + GetEnumName(
          TypeInfo(TTypeKind), Integer(pti^.Kind)));
      end
  else
    sList.Add('Undefined type information');
  end;
end;

//show the RTTI information inside a modal dialog box
procedure ShowRttiDetail(pti: PTypeInfo);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  ShowRTTI(pti, Lines);
  // Old note: Don't invoke ShowMessage (from FMX.Dialogs) with OnMouseDown event as it results in multiple selectcell events being sent to the control
  //(basically, select cell event results when moving the mouse over the string grid results).
  // Simple solution is just move code from OnMouseDown event to OnMouseUp.
  //  ShowMessage(Lines.Text);

  // Replacement for ShowMessage below also lets us set the caption.
  MessageForm.ShowMessage(Lines.Text, 'RTTI Details for ' + GetTypeName(pti));

  FreeAndNil(Lines); //change by birbilis to avoid memory leak (untested)
end;

{$IFDEF OLD}  // Code snippets that had something useful or that may need to be revisited.

// Use MouseUp instead of MouseDown event here because ShowMessage call is made from ShowRttiDetail.
// Things do not work correctly if ShowMessage is called from a MouseUp event (just try it if you don't believe me).

// Following code shows how to determine if row 0 of the TStringGrid was clicked.
// (This is obsolete code as we now use the grid's header instead of row 0.)
procedure TCantObjDebFMXFrame.sgMouseUp(Sender: TObject;
Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  sg: TStringGrid;
  sgObjects: TSGObjects;
begin
  sg := Sender as TStringGrid;
  sgObjects := GetStringGridObjects(sg);

  //Log.d('sgMouseDown: Y = ' + FloatToStr(Y) + ', sg.Y : ' + FloatToStr(sg.Position.Y) + ', ViewportPosition.Y: ' + FloatToStr(sg.ViewportPosition.Y));

  //if clicking on very first row and its value isn't empty
  if (Y - sg.ViewportPosition.Y < sg.RowHeight) and (Y - sg.ViewportPosition.Y >= 0) and (sg.Cells[1, 0] <> '') then
    ShowRttiDetail(PTypeInfo(sgObjects[1, 0]));
end;

// In case we want the top row visible in a scrollbox to be completely visible (more accurately, we allow a little (10%) of the row to be scrolled off the top).
// If top row is not aligned with top of scrollbox , then reposition.
// We do this so that positioning controls over stringgrid cells will align correctly.
procedure TCantObjDebFMXForm.sgVScrollChange(Sender: TObject);
const
  delta = 0.1;
var
  sg: TStringGrid;
  diff: Single;
  pt: TPointF;
begin
  sg := Sender as TStringGrid;

  // TODO Simplify this calculation using sq.TopRow?
  // diff := sg.ViewportPosition.Y - sg.RowHeight * trunc(sg.ViewportPosition.Y / sg.RowHeight);
  diff := sg.ViewportPosition.Y - sg.TopRow * sg.RowHeight;
  if (delta < diff) then
  begin
    //Ensure that top item visible and aligned with top of grid.
    pt := sg.ViewportPosition;
    pt.Y := sg.TopRow * sg.RowHeight;
    sg.ViewportPosition := pt;
  end;
end;

procedure TCantObjDebFMXPanel.MenuItemTopMostClick(Sender: TObject);
begin
  MenuItemTopMost.IsChecked := not MenuItemTopMost.IsChecked;
  if MenuItemTopMost.IsChecked then
    (Root as TCommonCustomForm).FormStyle := TFormStyle.StayOnTop
  else
    (Root as TCommonCustomForm).FormStyle := TFormStyle.Normal;
end;

{$ENDIF}

end.
