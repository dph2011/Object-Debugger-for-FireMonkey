# Object-Debugger-for-FireMonkey
A run-time object inspector for Delphi FireMonkey applications

README

The FMX ObjectDebugger is a run-time Object Inspector for Delphi FireMonkey applications (Windows 32 bit, Windows 64 bit, Mac OS X, iOS, Android).

Licensed under MPL 2.0, https://www.mozilla.org/en-US/MPL/2.0/ .

Copyright (c) 2016 Daniel Horn


Developed with Delphi/RAD Studio 10 Seattle.
Based on version 5.0 of the (VCL) Object Debugger for Delphi by Marco Cantù:
        http://blog.marcocantu.com/blog/2016-february-objectdebugger-delphi10seattle.html


WHAT'S HERE

The projects included in this project group are:


DemoMobile - A simple demo program that uses the component.  This shows how you might use the component in an Android or iOS app though it will also run on Windows and Mac OS X.
(Run this first on Win32 to make sure there are no problems.)

DemoDesktop - Similar to DemoMobile but intended for Windows and Mac because the Object Inspector runs in its own form.

ObjectDebuggerFMXTest - If you intend to modify the component, this project is a simple way of building and running the ObjectDebuggerFMXFrame class directly
in an app (this is a way of avoiding any install/uninstall issues that may come up while changing the code).


INSTRUCTIONS

1) To build open the project group in Delphi.

2) Open ObjectDebuggerFMXFrame in Design Mode.  In the Structure pane, right-click on FMXObjectDebuggerFrame and select Add to Palette.
The Component Template Information dialog appears.
Accept the defaults (TFMXObjectDebuggerFrameTemplate for Component Name and Templates for Palette Page.

3) Select the Demo project and Target Platform on which you intend to run (e.g., Win32 or OX X).

4) Some simple examples of what you can do when running the Demo application:
        choose the edit field and change its Text property using the inspector;
        change the cursor;
        choose the listbox or combobox and add modify its content (the Items property) or change its selected item (ItemIndex).
        
5) When adding it to your own project, remember to also add the FormMessage.pas file to the project.


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
(For example, the default component size is too big for an iPhone).


4) Evidently, the FireMonkey TStringGrid component does not generate OnVScrollChange and OnHScrollChange events on the Mac.
The simple solution to this is just use the OnViewportPositionChange event handler instead in FireMonkey apps.


5) Since the FMX ShowMessage messagebox does not let you assign a caption, we provide a simple replacement, FormMessage;
in addition to acting like ShowMessage replacement, it can also be used to display a TPanel.


See the comments in the ObjectDebuggerFMXFrame.pas source file for more information.
