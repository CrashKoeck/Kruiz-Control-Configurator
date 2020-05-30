; Kruiz Control Configurator by CrashKoeck
; Crash@CrashKoeck.com
; Copyright 2020 CrashKoeck
Version := "1.1.2"

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1


;; --------------------------------
;; Get latest version of KCC on GitHub
;; --------------------------------

vCheck := ComObjCreate("WinHttp.WinHttpRequest.5.1")
vCheck.Open("GET","https://raw.githubusercontent.com/CrashKoeck/Kruiz-Control-Configurator/master/Kruiz-Control%20Configurator.ahkp")
vCheck.Send()
vCheckResponse := vCheck.ResponseText
vCheckArray := StrSplit(vCheckResponse, """")
latestKCCVersion := vCheckArray[2]


;; --------------------------------
;; Check for KCC update and prompt if update is available
;; --------------------------------

if (FileExist("Kruiz-Control-Configurator-OLD.exe")){ ;Clean up old installation files
	FileDelete, Kruiz-Control-Configurator-OLD.exe
}

if (Version < latestKCCVersion and A_Args[1] != "noupdate"){
	URL := "https://github.com/CrashKoeck/Kruiz-Control-Configurator/releases/download/v" . latestKCCVersion . "/Kruiz-Control-Configurator.exe"
	Gui New, -MaximizeBox +OwnDialogs -SysMenu
	Gui Add, Text, x0 y25 w350 h50 +0x200 +Center vUpdateInfo, Downloading and installing Kruiz Control Configurator v%latestKCCVersion%
	Gui Add, Progress, x50 y75 w250 h25 -Smooth vProgress, 0
	Gui Show, w350 h150, Kruiz Control Configurator Updating...
	Sleep, 2000
	if (FileExist("Kruiz-Control-Configurator.exe")){
		FileMove, Kruiz-Control-Configurator.exe, Kruiz-Control-Configurator-OLD.exe
	}
	GuiControl,, Progress, 33
	GuiControl,, UpdateInfo, % "Local version backed up. Downloading new version..."
	Sleep, 2000
	UrlDownloadToFile, %URL%, Kruiz-Control-Configurator.exe
	GuiControl,, Progress, 66
	GuiControl,, UpdateInfo, % "New version downloaded. Installing..."
	Sleep, 2000
	if (!FileExist("Kruiz-Control-Configurator.exe")){
		MsgBox,48, Update Error, Kruiz Control Configurator could not be updated - new file missing. Please restart Kruiz Control Configurator to attempt the update again. If the error persists, please contact CrashKoeck
		FileMove, Kruiz-Control-Configurator-OLD.exe, Kruiz-Control-Configurator.exe
		ExitApp
	}
	GuiControl,, Progress, 100
	GuiControl,, UpdateInfo, % "Update Complete! Restarting in 3"
	Sleep, 1000
	GuiControl,, UpdateInfo, % "Update Complete! Restarting in 2"
	Sleep, 1000
	GuiControl,, UpdateInfo, % "Update Complete! Restarting in 1"
	Sleep, 1000
	Run, Kruiz-Control-Configurator.exe
	ExitApp
}


;; --------------------------------
;; Get latest version of KC on GitHub
;; --------------------------------

vCheck := ComObjCreate("WinHttp.WinHttpRequest.5.1")
vCheck.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/version.txt")
vCheck.Send()
if (vCheck.ResponseText = "404: Not Found"){
	latestKCVersion := "Could not retrieve latest version data (Version data coming soon to Kruiz Control)"
} else {
	latestKCVersion := vCheck.ResponseText
}


;; --------------------------------
;; Get version of local KC
;; --------------------------------

currentLocalKCVersion := "Could not determine local version"
KUpdateAvailable := ""
if (FileExist("version.txt")){
	FileReadLine, readLocalVersion, version.txt, 1
	if(readLocalVersion != ""){
		currentLocalKCVersion := readLocalVersion
		if(readLocalVersion < latestKCVersion){
			KCUpdateAvailable := "Kruiz Control Update Available`nCheck the About Tab"
		}
	}
}


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

Gui New, -MaximizeBox +OwnDialogs -SysMenu

;Gui Color, 0x121212

Gui Add, Picture, x231 y10 w178 h100, %a_temp%/logo.png
Gui, Font, s15
Gui Add, Text, x170 y110 w300 h25 +0x200 +Center, Configurator by CrashKoeck
Gui, Font

Gui Add, Text, x10 y10 w200 h30 cFF0000, %KCUpdateAvailable%

Gui Add, Button, x600 y10 w30 h30 gExitApp, X


;; --------------------------------
;; TABS - Inner Dimensions = x6 y166 w628 h428
;; --------------------------------

Gui Add, Tab3, x5 y145 w632 h451, Configuration|Trigger Creator|About
	
	Gui Add, Text, x16 y176 w299 h21 +0x200 +Right, Channel to read Channel Points from: 
	Gui Add, Edit, x320 y176 w304 h21 vFieldChannelPoints gSaveEnable, %savedChannelPoints%

	Gui Add, Text, x16 y201 w299 h23 +0x200 +Right, Channel to connect to for chat:
	Gui Add, Edit, x320 y201 w304 h21 vFieldChat gSaveEnable, %savedChat%

	Gui Add, Text, x16 y226 w299 h23 +0x200 +Right, OAUTH Token for account sending messages:
	Gui Add, Edit, x320 y226 w304 h21 vFieldOAUTH gSaveEnable +Password, %savedOAUTH%
	Gui Add, Button, x319 y251 w150 h21 gGetOAUTH, Get OAUTH Token
	Gui Add, Button, x474 y251 w21 h21 gGetOAUTHHelp, ?
	Gui Add, Button, x500 y251 w125 h21 gShowOAUTH, Show Token

	Gui Add, Text, x16 y301 w299 h23 +0x200 +Right, OBS Websocket Address:
	Gui Add, Edit, x320 y301 w304 h21 vFieldOBSAddress gSaveEnable, %savedOBSAddress%

	Gui Add, Text, x16 y326 w299 h23 +0x200 +Right, OBS Websocket Password:
	Gui Add, Edit, x320 y326 w304 h21 vFieldOBSPassword gSaveEnable +Password, %savedOBSPassword%
	Gui Add, Button, x319 y351 w150 h21 gGetOBSwebsocket, Get OBS websocket Plugin
	Gui Add, Button, x474 y351 w21 h21 gGetOBSwebsocketHelp, ?
	Gui Add, Button, x500 y351 w125 h21 gShowOBSwebsocket, Show Password

	Gui Add, Text, x16 y401 w299 h23 +0x200 +Right, StreamElements JWT Token:
	Gui Add, Edit, x320 y401 w304 h21 vFieldSE gSaveEnable +Password, %savedSE%
	Gui Add, Button, x319 y426 w150 h21 gGetjwt, Get JWT Token
	Gui Add, Button, x474 y426 w21 h21 gGetjwtHelp, ?
	Gui Add, Button, x500 y426 w125 h21 gShowjwt, Show JWT Token

	Gui Add, Text, x16 y476 w299 h23 +0x200 +Right, Streamlabs socketAPI Token:
	Gui Add, Edit, x320 y476 w304 h21 vFieldSL gSaveEnable +Password, %savedSL%
	Gui Add, Button, x319 y501 w150 h21 gGetsocketAPI, Get socketAPI Token
	Gui Add, Button, x474 y501 w21 h21 gGetsocketAPIHelp, ?
	Gui Add, Button, x500 y501 w125 h21 gShowsocketAPI, Show socketAPI Token

	Gui Add, Button, x100 y554 w140 h30 gResetDefaults, Reset Defaults
	Gui Add, Button, x250 y554 w140 h30 vReloadButton gReloadSettings +Disabled, Reload Previous Settings
	Gui Add, Button, x400 y554 w140 h30 vSaveButton gSaveSettings +Disabled, Save Settings

Gui Tab, 2

	Gui Add, Text, x10 y356 w620 h23 +0x200 +Center, Coming Soon

Gui Tab, 3

	Gui Add, Link, x16 y176 w608 h418, Kruiz Control Configurator Version: %Version%`nCreated by CrashKoeck`n<a href="https://crashkoeck.com">CrashKoeck.com</a>`n<a href="https://raw.githubusercontent.com/CrashKoeck/Kruiz-Control-Configurator/master/LICENSE">License</a>`n`nCurrent Local Version of Kruiz Control: %currentLocalKCVersion%`nLatest Version of Kruiz Control on <A href="https://github.com/Kruiser8/Kruiz-Control/releases">GitHub</a>: %latestKCVersion%`n`nKruiz Control created by Kruiser8`n`nIf you are having issues with this app, please join the <a href="https://discord.gg/zyS2jbJ">CrashPad Discord</a> for support`n`n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -`n`n<a href="https://github.com/Kruiser8/Kruiz-Control/blob/master/js/Documentation.md#kruiz-control-documentation">Kruiz Control Documentation</a>`n`n<a href="https://discord.gg/wU3ZK3Q">Kruiz Control Support Discord</a>`n`n<a href="https://twitter.com/kruiser8">Kruiser8 on Twitter</a>`n`n<a href="https://twitch.tv/kruiser8">Kruiser8 on Twitch</a>`n`n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -`n`n<a href="https://github.com/crashkoeck">CrashKoeck on GitHub</a>`n`n<a href="https://twitter.com/CrashKoeck">CrashKoeck on Twitter</a>`n`n<a href="https://twitch.tv/CrashKoeck">CrashKoeck on Twitch</a>
	

Gui Tab

Gui Show, w640 h600, Kruiz Control Configurator
Return


;; --------------------------------
;; Enable the Save button on change
;; --------------------------------

SaveEnable:
	GuiControl,Enable, SaveButton
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
;; Action when the Show OAUTH button is pressed
;; --------------------------------

ShowOAUTH:
	Gui, Submit, NoHide
	GuiControlGet, FieldOAUTH
	MsgBox,32,Twitch OAUTH Token, %FieldOAUTH%
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
;; Action when the Show Password button is pressed
;; --------------------------------

ShowOBSwebsocket:
	Gui, Submit, NoHide
	GuiControlGet, FieldOBSPassword
	MsgBox,32,OBS websocket Password, %FieldOBSPassword%
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
;; Action when the Show JWT button is pressed
;; --------------------------------

Showjwt:
	Gui, Submit, NoHide
	GuiControlGet, FieldSE
	MsgBox,32,StreamElements JWT Token, %FieldSE%
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
;; Action when the Show socketAPI button is pressed
;; --------------------------------

ShowsocketAPI:
	Gui, Submit, NoHide
	GuiControlGet, FieldSL
	MsgBox,32,Streamlabs socketAPI Token, %FieldSL%
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

MsgBox,,Save Settings, New settings saved
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