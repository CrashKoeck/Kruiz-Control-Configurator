; Kruiz Control Configurator by CrashKoeck
; Crash@CrashKoeck.com
; Copyright 2020 CrashKoeck
Version := "1.0.1"

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1


;; --------------------------------
;; Load existing settings
;; --------------------------------

FileReadLine, savedChannelPoints, settings\channelpoints\user.txt, 1
FileReadLine, savedChat, settings\chat\user.txt, 1
FileReadLine, savedOAUTH, settings\chat\oauth.txt, 1
FileReadLine, savedOBSAddress, settings\obs\address.txt, 1
FileReadLine, savedOBSPassword, settings\obs\password.txt, 1
FileReadLine, savedSE, settings\streamelements\jwtToken.txt, 1
FileReadLine, savedSL, settings\streamlabs\socketAPIToken.txt, 1


;; --------------------------------
;; Load images for the GUI (adds to compiled exe)
;; --------------------------------

FileInstall, logo.png, %a_temp%/logo.png
FileInstall, icon.ico, %a_temp%/icon.ico


;; --------------------------------
;; Build the GUI
;; --------------------------------

Menu Tray, Icon, %a_temp%/icon.ico

Gui New, -MaximizeBox +OwnDialogs -Caption

Gui Color, 0x404040

Gui Add, Picture, x195 y10 w250 h141, %a_temp%/logo.png

Gui Add, Button, x25 y25 w140 h23 gVisitKCGitHub, Kruiz Control on GitHub
Gui Add, Button, x25 y55 w140 h23 gKCDiscord, Kruiz Control Discord

Gui Add, Button, x475 y25 w140 h23 gAboutBox, About
Gui Add, Button, x475 y55 w140 h23 gVisitCrashGitHub, CrashKoeck on GitHub
Gui Add, Button, x475 y85 w140 h23 gCrashPad, CrashPad Discord

Gui Add, Text, x-10 y155 w660 h2 +0x10

Gui Add, Text, x10 y175 w305 h21 +0x200 +Right cFFFFFF, Channel to read Channel Points from: 
Gui Add, Edit, x320 y175 w305 h21 vFieldChannelPoints gSaveEnable, %savedChannelPoints%

Gui Add, Text, x10 y200 w301 h23 +0x200 +Right cFFFFFF, Channel to connect to for chat:
Gui Add, Edit, x320 y200 w305 h21 vFieldChat gSaveEnable, %savedChat%

Gui Add, Text, x10 y225 w305 h23 +0x200 +Right cFFFFFF, OAUTH Token for account sending messages:
Gui Add, Edit, x320 y225 w305 h21 vFieldOAUTH gSaveEnable, %savedOAUTH%
Gui Add, Button, x320 y250 w150 h21 gGetOAUTH, Get OAUTH Token
Gui Add, Button, x480 y250 w21 h21 gGetOAUTHHelp, ?

Gui Add, Text, x10 y300 w305 h23 +0x200 +Right cFFFFFF, OBS Websocket Address:
Gui Add, Edit, x320 y300 w305 h21 vFieldOBSAddress gSaveEnable, %savedOBSAddress%

Gui Add, Text, x10 y325 w305 h23 +0x200 +Right cFFFFFF, OBS Websocket Password:
Gui Add, Edit, x320 y325 w305 h21 vFieldOBSPassword gSaveEnable, %savedOBSPassword%
Gui Add, Button, x320 y350 w150 h21 gGetOBSwebsocket, Get OBS websocket Plugin
Gui Add, Button, x480 y350 w21 h21 gGetOBSwebsocketHelp, ?

Gui Add, Text, x10 y400 w305 h23 +0x200 +Right cFFFFFF, StreamElements JWT Token:
Gui Add, Edit, x320 y400 w305 h21 vFieldSE gSaveEnable, %savedSE%
Gui Add, Button, x320 y425 w150 h21 gGetjwt, Get JWT Token
Gui Add, Button, x480 y425 w21 h21 gGetjwtHelp, ?

Gui Add, Text, x10 y475 w305 h23 +0x200 +Right cFFFFFF, Streamlabs socketAPI Token:
Gui Add, Edit, x320 y475 w305 h21 vFieldSL gSaveEnable, %savedSL%
Gui Add, Button, x320 y500 w150 h21 gGetsocketAPI, Get socketAPI Token
Gui Add, Button, x480 y500 w21 h21 gGetsocketAPIHelp, ?

Gui Add, Button, x25 y580 w140 h30 gResetDefaults, Reset Defaults
Gui Add, Button, x175 y580 w140 h30 vReloadButton gReloadSettings +Disabled, Reload Previous Settings
Gui Add, Button, x325 y580 w140 h30 vSaveButton gSaveSettings +Disabled, Save Settings
Gui Add, Button, x475 y580 w140 h30 gExitApp, Exit

Gui Show, w640 h625, Kruiz Control Configurator
Return


;; --------------------------------
;; Visit Kruiz Control GitHub Page
;; --------------------------------

VisitKCGitHub:
	Run, https://github.com/Kruiser8/Kruiz-Control/blob/master/settings/Settings.md
return


;; --------------------------------
;; Visit Crash GitHub Page
;; --------------------------------

VisitCrashGitHub:
	Run, https://github.com/CrashKoeck/Kruiz-Control-Configurator
return


;; --------------------------------
;; Enable the Save button on change
;; --------------------------------

SaveEnable:
	GuiControl,Enable, SaveButton
return


;; --------------------------------
;; Action when the About button is pressed
;; --------------------------------

AboutBox:
	MsgBox,32, Kruiz Control Configurator by CrashKoeck, % "Kruiz Control Configurator for Kruiz Control 1.2.0`n`nVersion: " . Version . "`nCreated by CrashKoeck`nCrashKoeck.com`n`nKruiz Control created by Kruiser8`n`nIf you are having issues with this app, please join the CrashPad Discord"
return


;; --------------------------------
;; Action when the CrashPad Discord button is pressed
;; --------------------------------

CrashPad:
	Run, https://discord.gg/zyS2jbJ
return


;; --------------------------------
;; Action when the Kruiz Control Discord button is pressed
;; --------------------------------

KCDiscord:
	Run, https://discord.gg/wU3ZK3Q
return


;; --------------------------------
;; Action when the OAUTH button is pressed
;; --------------------------------

GetOAUTH:
	Run, http://twitchapps.com/tmi/
return


;; --------------------------------
;; Action when the OAUTH ? button is pressed
;; --------------------------------

GetOAUTHHelp:
	MsgBox,32,OAUTH Help, The OAUTH token allows Kruiz Control to send mesages to chat. Make sure you are logged into Twitch with the account that you want to send the messages with before grabbing the OAUTH token.
return


;; --------------------------------
;; Action when the OBS websocket button is pressed
;; --------------------------------

GetOBSwebsocket:
	Run, https://github.com/Palakis/obs-websocket/releases
return


;; --------------------------------
;; Action when the OBS websocket ? button is pressed
;; --------------------------------

GetOBSwebsocketHelp:
	MsgBox,64,OBS websocket Info, OBS websocket plugin allows different services to connect to and communicate with OBS. Follow the instructions on the OBS websocket page to install and use
return


;; --------------------------------
;; Action when the jwt button is pressed
;; --------------------------------

Getjwt:
	Run, https://streamelements.com/dashboard/account/channels
return


;; --------------------------------
;; Action when the jwt ? button is pressed
;; --------------------------------

GetjwtHelp:
	MsgBox,32,StreamElements Connection Help, - Go to your StreamElements account settings`n- Click the Show secrets toggle on the right`n- Copy the JWT Token value that appears`n- Paste the JWT token in the box
return


;; --------------------------------
;; Action when the socketAPI button is pressed
;; --------------------------------

GetsocketAPI:
	Run, https://streamlabs.com/dashboard#/settings/api-settings
return


;; --------------------------------
;; Action when the socketAPI ? button is pressed
;; --------------------------------

GetsocketAPIHelp:
	MsgBox,32,Streamlabs Connection Help, - Log in to your Streamlabs Dashboard`n- Click Settings from the left menu`n- Click the API Tokens tab`n- Copy the Your Socket API Token value`n- Paste the Socket API token in the box
return


;; --------------------------------
;; Action then the Reset button is pressed
;; --------------------------------

ResetDefaults:
	GuiControl,, FieldChannelPoints, username
	GuiControl,, FieldChat, username
	GuiControl,, FieldOAUTH, oauth:token
	GuiControl,, FieldOBSAddress, localhost:4444
	GuiControl,, FieldOBSPassword, password
	GuiControl,, FieldSE, jwtToken
	GuiControl,, FieldSL, socketAPIToken
	GuiControl,Enable, ReloadButton
	GuiControl,Enable, SaveButton
return


;; --------------------------------
;; Action then the Reload button is pressed
;; --------------------------------

ReloadSettings:
	GuiControl,, FieldChannelPoints, %savedChannelPoints%
	GuiControl,, FieldChat, %savedChat%
	GuiControl,, FieldOAUTH, %savedOAUTH%
	GuiControl,, FieldOBSAddress, %savedOBSAddress%
	GuiControl,, FieldOBSPassword, %savedOBSPassword%
	GuiControl,, FieldSE, %savedSE%
	GuiControl,, FieldSL, %savedSL%
	GuiControl,Disabled, ReloadButton
	GuiControl,Enable, SaveButton
return


;; --------------------------------
;; Action when saving
;; --------------------------------

SaveSettings:
Msgbox 68, Save Settings, Are you sure you want to save the new settings?
IfMsgBox No
	Return
Gui, Submit, NoHide
GuiControlGet, FieldChannelPoints
GuiControlGet, FieldChat
GuiControlGet, FieldOAUTH
GuiControlGet, FieldOBSAddress
GuiControlGet, FieldOBSPassword
GuiControlGet, FieldSE
GuiControlGet, FieldSL

file := FileOpen("settings\channelpoints\user.txt", "w")
file.write(FieldChannelPoints)
file.close()
file := FileOpen("settings\chat\user.txt", "w")
file.write(FieldChat)
file.close()
file := FileOpen("settings\chat\oauth.txt", "w")
file.write(FieldOAUTH)
file.close()
file := FileOpen("settings\obs\address.txt", "w")
file.write(FieldOBSAddress)
file.close()
file := FileOpen("settings\obs\password.txt", "w")
file.write(FieldOBSPassword)
file.close()
file := FileOpen("settings\streamelements\jwtToken.txt", "w")
file.write(FieldSE)
file.close()
file := FileOpen("settings\streamlabs\socketAPIToken.txt", "w")
file.write(FieldSL)
file.close()

MsgBox,,Save Settings, New settings saved!.
GuiControl,Enable, ReloadButton
GuiControl,Disable, SaveButton
return


;; --------------------------------
;; Action when Exit button pressed
;; --------------------------------

ExitApp:
Msgbox 52, Exit application,Are you sure you want to exit?`nUnsaved changes will be lost
IfMsgBox No
	Return
ExitApp
return


GuiClose:
    ExitApp
