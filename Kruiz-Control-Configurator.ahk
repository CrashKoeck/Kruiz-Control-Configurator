; Kruiz Control Configurator by CrashKoeck
; Crash@CrashKoeck.com
; Copyright 2021 CrashKoeck
Version := "1.5.0"

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
global UnsavedWork := 0

OnExit("ExitFunc")

;; --------------------------------
;; Get latest version of KCC on GitHub
;; --------------------------------

Try {
	vCheck := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	vCheck.Open("GET","https://raw.githubusercontent.com/CrashKoeck/Kruiz-Control-Configurator/master/Kruiz-Control-Configurator.ahk")
	vCheck.Send()
	vCheckResponse := vCheck.ResponseText
	vCheckArray := StrSplit(vCheckResponse, """")
	latestKCCVersion := vCheckArray[2]
}


;; --------------------------------
;; Check for KCC update and prompt if update is available
;; --------------------------------

if (FileExist("Kruiz-Control-Configurator-OLD.exe")){ ;Clean up old installation files
	FileDelete, Kruiz-Control-Configurator-OLD.exe
	Run, https://github.com/CrashKoeck/Kruiz-Control-Configurator/releases
}

Try {
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
} catch {
	MsgBox, 16, ERROR, Could not connect to GitHub to update Kruiz Control Configurator. Please try again later.
}


;; --------------------------------
;; Get latest version of KC on GitHub
;; --------------------------------

Try {
	vCheck := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	vCheck.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/version.txt")
	vCheck.Send()
	if (vCheck.ResponseText = "404: Not Found"){
		latestKCVersion := "Could not retrieve latest version data (Version data coming soon to Kruiz Control)"
	} else {
		latestKCVersion := vCheck.ResponseText
	}
} catch {
	MsgBox, 16, ERROR, Could not connect to GitHub to check Kruiz Control version. Please try again later.
}


;; --------------------------------
;; Get version of local KC
;; --------------------------------

currentLocalKCVersion := "Could not determine local version"
KUpdateAvailable := ""
if (FileExist("version.txt")){
	FileReadLine, readLocalVersion, version.txt, 1
	if(readLocalVersion != ""){
		currentLocalKCVersion := SubStr(readLocalVersion, 2)
		currentRemoteKCVersion := SubStr(latestKCVersion, 2)
		lines := StrSplit(currentRemoteKCVersion, "`n")
		currentRemoteKCVersion := lines[1]
		if(currentLocalKCVersion < currentRemoteKCVersion){
			KCUpdateAvailable := "Kruiz Control Update Available`nCheck the About Tab"
			Msgbox 68, Kruiz Control Update, An update is available for Kruiz Control. Would you like to download it now?`n`nCurrent Version: %currentLocalKCVersion%`nLatest Version: %currentRemoteKCVersion%
				IfMsgBox Yes
					Gosub, UpdateKC
		}
	}
}


;; --------------------------------
;; Load existing settings
;; --------------------------------

FileReadLine, savedChannelPoints, settings\twitch\user.txt, 1
FileReadLine, savedChat, settings\chat\user.txt, 1
FileReadLine, savedOAUTH, settings\chat\oauth.txt, 1
FileReadLine, savedOBSAddress, settings\obs\address.txt, 1
FileReadLine, savedOBSPassword, settings\obs\password.txt, 1
FileReadLine, savedSLOBSAPI, settings\slobs\token.txt, 1
FileReadLine, savedSE, settings\streamelements\jwtToken.txt, 1
FileReadLine, savedSL, settings\streamlabs\socketAPIToken.txt, 1
FileReadLine, savedRV, settings\tts\key.txt, 1


;; --------------------------------
;; Load images for the GUI (adds to compiled exe)
;; --------------------------------

FileInstall, logo.png, %a_temp%/logo.png
FileInstall, icon.ico, %a_temp%/icon.ico


;; --------------------------------
;; Build the GUI
;; --------------------------------

Menu Tray, Icon, %a_temp%/icon.ico

Gui New, -MaximizeBox +OwnDialogs

;Gui Color, 0x121212

Gui Add, Picture, x231 y10 w178 h100, %a_temp%/logo.png
Gui, Font, s15
Gui Add, Text, x170 y110 w300 h25 +0x200 +Center, Configurator by CrashKoeck
Gui, Font

Gui Add, Text, x10 y10 w200 h30 cFF0000, %KCUpdateAvailable%

;Gui Add, Button, x600 y10 w30 h30 gExitApp, X


;; --------------------------------
;; TABS - Inner Dimensions = x6 y166 w628 h428
;; --------------------------------

Gui Add, Tab3, x5 y145 w632 h551 section, Configuration|About
	
	Gui Add, Text, xs+10 y176 w299 h21 +0x200 +Right, Channel to read Channel Points from: 
	Gui Add, Edit, x+5 yp w304 hp vFieldChannelPoints gSaveEnable, %savedChannelPoints%

	Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, Channel to connect to for chat:
	Gui Add, Edit, x+5 yp w304 hp vFieldChat gSaveEnable, %savedChat%

	Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, OAUTH Token for account sending messages:
	Gui Add, Edit, x+5 yp w304 hp vFieldOAUTH gSaveEnable +Password, %savedOAUTH%
	Gui Add, Button, x63 y+5 w250 hp gGetOAUTHLink, Copy OAUTH Page Link to Clipboard
	Gui Add, Button, x+5 yp w150 hp gGetOAUTH, Get OAUTH Token
	Gui Add, Button, x+5 yp w21 hp gGetOAUTHHelp, ?
	Gui Add, Button, x+5 yp w125 hp gShowOAUTH, Show Token

	Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, OBS Websocket Address:
	Gui Add, Edit, x+5 yp w304 hp vFieldOBSAddress gSaveEnable, %savedOBSAddress%

	Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, OBS Websocket Password:
	Gui Add, Edit, x+5 yp w304 hp vFieldOBSPassword gSaveEnable +Password, %savedOBSPassword%
	Gui Add, Button, x318 y+5 w150 hp gGetOBSwebsocket, Get OBS websocket Plugin
	Gui Add, Button, x+5 yp w21 hp gGetOBSwebsocketHelp, ?
	Gui Add, Button, x+5 yp w125 hp gShowOBSwebsocket, Show Password
	
	Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, SLOBS API Key:
	Gui Add, Edit, x+5 yp w304 hp vFieldSLOBSAPI gSaveEnable +Password, %savedSLOBSAPI%
	Gui Add, Button, x318 y+5 w150 hp gGetSLOBSAPI, Get SLOBS API Key
	Gui Add, Button, x+5 yp w21 hp gGetSLOBSAPIHelp, ?
	Gui Add, Button, x+5 yp w125 hp gShowSLOBSAPI, Show API Key

	Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, StreamElements JWT Token:
	Gui Add, Edit, x+5 yp w304 hp vFieldSE gSaveEnable +Password, %savedSE%
	Gui Add, Button, x318 y+5 w150 hp gGetjwt, Get JWT Token
	Gui Add, Button, x+5 yp w21 hp gGetjwtHelp, ?
	Gui Add, Button, x+5 yp w125 hp gShowjwt, Show JWT Token

	Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, Streamlabs socketAPI Token:
	Gui Add, Edit, x+5 yp w304 hp vFieldSL gSaveEnable +Password, %savedSL%
	Gui Add, Button, x318 y+5 w150 hp gGetsocketAPI, Get socketAPI Token
	Gui Add, Button, x+5 yp w21 hp gGetsocketAPIHelp, ?
	Gui Add, Button, x+5 yp w125 hp gShowsocketAPI, Show socketAPI Token
	
	;Gui Add, Text, xs+10 y+15 w299 hp +0x200 +Right, ResponsiveVoice Key:
	;Gui Add, Edit, x+5 yp w304 hp vFieldRV gSaveEnable +Password, %savedRV%
	;Gui Add, Button, x318 y+5 w150 hp gGetResponsiveVoice, Get ResponsiveVoice Key
	;Gui Add, Button, x+5 yp w21 hp gGetResponsiveVoiceHelp, ?
	;Gui Add, Button, x+5 yp w125 hp gShowResponsiveVoice, Show RV Key

	Gui Add, Button, x100 y+15 w140 h30 gResetDefaults, Reset Defaults
	Gui Add, Button, x+10 yp wp hp vReloadButton gReloadSettings +Disabled, Reload Saved Settings
	Gui Add, Button, x+10 yp wp hp vSaveButton gSaveSettings +Disabled, Save Settings

Gui Tab, 2

	Gui Add, Link, xs+10 y176 w450, Kruiz Control Configurator Version: %Version%`nCreated by CrashKoeck`n<a href="https://crashkoeck.com">CrashKoeck.com</a>`n<a href="https://raw.githubusercontent.com/CrashKoeck/Kruiz-Control-Configurator/master/LICENSE">License</a>`n`nCurrent Local Version of Kruiz Control: %currentLocalKCVersion%`nLatest Version of Kruiz Control on <A href="https://github.com/Kruiser8/Kruiz-Control/releases">GitHub</a>: %latestKCVersion%`n`nKruiz Control created by Kruiser8`n`nIf you are having issues with this app, please join the <a href="https://discord.gg/zyS2jbJ">CrashPad Discord</a> for support`n`n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -`n`n<a href="https://github.com/Kruiser8/Kruiz-Control/blob/master/js/Documentation.md#kruiz-control-documentation">Kruiz Control Documentation</a>`n`n<a href="https://discord.gg/wU3ZK3Q">Kruiz Control Support Discord</a>`n`n<a href="https://twitter.com/kruiser8">Kruiser8 on Twitter</a>`n`n<a href="https://twitch.tv/kruiser8">Kruiser8 on Twitch</a>`n`n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -`n`n<a href="https://github.com/crashkoeck">CrashKoeck on GitHub</a>`n`n<a href="https://twitter.com/CrashKoeck">CrashKoeck on Twitter</a>`n`n<a href="https://twitch.tv/CrashKoeck">CrashKoeck on Twitch</a>
	Gui Add, Button, x485 yp w140 h30 vReinstallButton gReinstallKC, Reinstall Kruiz Control

Gui Tab

Gui Show, w640 h700, Kruiz Control Configurator

Return


;; --------------------------------
;; Update Kruiz Control
;; --------------------------------

UpdateKC:
	
	Try {
		if(!FileExist("version.txt") or !FileExist("index.html") or !FileExist("triggers.txt")){
			MsgBox,16,, It appears that you are either not running the Kruiz Control Configurator within the Kruiz Control directory or you are running an old version of Kruiz Control that doesn't work with the auto-updater
		} else {
			Progress, w400, , Downloading data from GitHub, Updating to Kruiz Control %latestKCVersion%
			KCURL = https://github.com/Kruiser8/Kruiz-Control/archive/master.zip
			Progress, 5
			UrlDownloadToFile, %KCURL%, KCUpdate.zip
			Progress, 15, , Backing up user data and deleting old files
			Loop, Files, %A_ScriptDir%\*.*, F
			{
				if(A_LoopFileName != "Kruiz-Control-Configurator.exe" and A_LoopFileName != "KCUpdate.zip"){
					if(A_LoopFileName != "triggers.txt" and A_LoopFileName != "fileTriggers.txt"){
						FileDelete,% A_LoopFileDir . "\" . A_LoopFileName,1
					} else {
						FileMove,% A_LoopFileFullPath, % A_LoopFileDir . "\KCBKP-" . A_LoopFileName,1
					}
				}
			}
			Loop, Files, %A_ScriptDir%\*, D
			{
				if(A_LoopFileName != "Kruiz-Control-Configurator.exe"){
					if(A_LoopFileName != "settings" and A_LoopFileName != "sounds" and A_LoopFileName != "triggers"){
						FileRemoveDir,% A_LoopFileDir . "\" . A_LoopFileName,1
					} else {
						FileMoveDir,% A_LoopFileFullPath, % A_LoopFileDir . "\KCBKP-" . A_LoopFileName
					}
				}
			}
			Progress, 30, , Extracting downloaded files
			RunWait PowerShell.exe -Command "Expand-Archive -LiteralPath '%A_ScriptDir%\KCUpdate.zip' -DestinationPath '%A_ScriptDir%' -Force",, Hide
			Progress, 45, , Moving extracted files
			Loop, Files, %A_ScriptDir%\Kruiz-Control-master\*.*, F
			{
				FileMove,% A_LoopFileFullPath, % A_ScriptDir . "\"  . A_LoopFileName,1
			}
			Loop, Files, %A_ScriptDir%\Kruiz-Control-master\*, D
			{
				FileMoveDir,% A_LoopFileFullPath, % A_ScriptDir . "\"  . A_LoopFileName
			}
			Progress, 60, , Restoring backup files
			Loop, Files, %A_ScriptDir%\*.*, F
			{
				if(A_LoopFileName = "KCBKP-triggers.txt"){
					FileDelete,% A_LoopFileDir . "\triggers.txt",1
					FileMove,% A_LoopFileFullPath, % A_LoopFileDir . "\triggers.txt",1
				} else if(A_LoopFileName = "KCBKP-fileTriggers.txt"){
					FileDelete,% A_LoopFileDir . "\fileTriggers.txt",1
					FileMove,% A_LoopFileFullPath, % A_LoopFileDir . "\fileTriggers.txt",1
				}
			}
			Loop, Files, %A_ScriptDir%\*, D
			{
				if(A_LoopFileName = "KCBKP-settings"){
					FileRemoveDir,% A_LoopFileDir . "\settings",1
					FileMoveDir,% A_LoopFileFullPath, % A_LoopFileDir . "\settings"
				} else if(A_LoopFileName = "KCBKP-sounds"){
					FileRemoveDir,% A_LoopFileDir . "\sounds",1
					FileMoveDir,% A_LoopFileFullPath, % A_LoopFileDir . "\sounds"
				} else if(A_LoopFileName = "KCBKP-triggers"){
					FileRemoveDir,% A_LoopFileDir . "\triggers",1
					FileMoveDir,% A_LoopFileFullPath, % A_LoopFileDir . "\triggers"
				}
			}
			if (FileExist("settings\channelpoints\user.txt")){
				FileCreateDir, settings\twitch
				FileMove, settings\channelpoints\user.txt, settings\twitch\user.txt, 1
				FileRemoveDir, settings\channelpoints, 1
			}
			Progress, 80, , Backups restored`, cleaning up
			if (FileExist("KCUpdate.zip")){
				FileDelete, KCUpdate.zip
			}
			if (InStr(FileExist("Kruiz-Control-master"), "D")){
				FileRemoveDir, Kruiz-Control-master, 1
			}
			Sleep, 1000
			Progress, 100, , Update Complete!
			KCUpdateAvailable := ""
			currentLocalKCVersion := latestKCVersion
			Sleep, 3000
			Progress, Off
		}
	} catch {
		MsgBox, 16, ERROR, Could not perform update. Try again later.
	}
return


;; --------------------------------
;; Reinstall Kruiz Control
;; --------------------------------

ReinstallKC:
	Msgbox 68, Reinstall Kruiz Control, Are you sure you want to reinstall the latest version of Kruiz Control? Your settings and triggers will be preserved
		IfMsgBox Yes
			Gosub, UpdateKC
return


;; --------------------------------
;; Enable the Save button on change
;; --------------------------------

SaveEnable:
	GuiControl,Enable, SaveButton
	UnsavedWork := 1
return


;; --------------------------------
;; Action when the OAUTH Link button is pressed
;; --------------------------------

GetOAUTHLink:
	clipboard := "http://twitchapps.com/tmi/"
	MsgBox, OAUTH page link copied to Clipboard
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
	MsgBox,32,OAUTH Help, The OAUTH token allows Kruiz Control to send mesages to chat. Make sure you are logged into Twitch with the account that you want to send the messages with before clicking the "Get OAUTH Token" button. `n`nNote: If you want to just copy the link to your clipboard so you can log in with another Twitch account in your browser, click the "Copy OAUTH Page Link to Clipboard" button instead.
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
;; Action when the OBS websocket button is pressed
;; --------------------------------

GetSLOBSAPI:
	Run, https://github.com/Kruiser8/Kruiz-Control/blob/master/settings/Settings.md#slobs
return


;; --------------------------------
;; Action when the SLOBS API ? button is pressed
;; --------------------------------

GetSLOBSAPIHelp:
	MsgBox,64,SLOBS API Key Info, The SLOBS API Key allows you to connect Kruiz Control to and communicate with SLOBS.
return


;; --------------------------------
;; Action when the Show Password button is pressed
;; --------------------------------

ShowSLOBSAPI:
	Gui, Submit, NoHide
	GuiControlGet, FieldSLOBSAPI
	MsgBox,32,SLOBS API Key, %FieldSLOBSAPI%
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
;; Action when the ResponsiveVoice button is pressed
;; --------------------------------

GetResponsiveVoice:
	Run, https://app.responsivevoice.org/
return


;; --------------------------------
;; Action when the ResponsiveVoice ? button is pressed
;; --------------------------------

GetResponsiveVoiceHelp:
	MsgBox,32,ResponsiveVoice Help, Click the "Get ResponsiveVoice Key" button then sign-in or create an account. Copy your key from the bottom of the page and paste into this box.
return


;; --------------------------------
;; Action when the Show ResponsiveVoice button is pressed
;; --------------------------------

ShowResponsiveVoice:
	Gui, Submit, NoHide
	GuiControlGet, FieldRV
	MsgBox,32,ResponsiveVoice Key, %FieldRV%
return


;; --------------------------------
;; Action then the Reset button is pressed
;; --------------------------------

ResetDefaults:
	Progress, w400, Working..., Loading data from GitHub, Resetting Defaults
	Try {
	DefChannelPoints := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefChannelPoints.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/twitch/user.txt")
	DefChannelPoints.Send()
	GuiControl,, FieldChannelPoints, % DefChannelPoints.ResponseText
	}
	Progress, 10
	Try {
	DefChat := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefChat.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/chat/user.txt")
	DefChat.Send()
	GuiControl,, FieldChat, % DefChat.ResponseText
	}
	Progress, 20
	Try {
	DefOAUTH := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefOAUTH.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/chat/oauth.txt")
	DefOAUTH.Send()
	GuiControl,, FieldOAUTH, % DefOAUTH.ResponseText
	}
	Progress, 30
	Try {
	DefOBSAddress := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefOBSAddress.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/obs/address.txt")
	DefOBSAddress.Send()
	GuiControl,, FieldOBSAddress, % DefOBSAddress.ResponseText
	}
	Progress, 40
	Try {
	DefOBSPassword := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefOBSPassword.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/obs/password.txt")
	DefOBSPassword.Send()
	GuiControl,, FieldOBSPassword, % DefOBSPassword.ResponseText
	}
	Progress, 50
	Try {
	DefSLOBSAPI := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefSLOBSAPI.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/slobs/token.txt")
	DefSLOBSAPI.Send()
	GuiControl,, FieldSLOBSAPI, % DefSLOBSAPI.ResponseText
	}
	Progress, 60
	Try {
	DefjwtToken := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefjwtToken.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/streamelements/jwtToken.txt")
	DefjwtToken.Send()
	GuiControl,, FieldSE, % DefjwtToken.ResponseText
	}
	Progress, 70
	Try {
	DefsocketAPIToken := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefsocketAPIToken.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/streamlabs/socketAPIToken.txt")
	DefsocketAPIToken.Send()
	GuiControl,, FieldSL, % DefsocketAPIToken.ResponseText
	}
	Progress, 80
	Try {
	DefResponsiveVoiceKey := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	DefResponsiveVoiceKey.Open("GET","https://raw.githubusercontent.com/Kruiser8/Kruiz-Control/master/settings/tts/key.txt")
	DefResponsiveVoiceKey.Send()
	GuiControl,, FieldRV, % DefResponsiveVoiceKey.ResponseText
	}
	Progress, 100, Complete
	GuiControl,Enable, ReloadButton
	GuiControl,Enable, SaveButton
	UnsavedWork := 1
	Sleep, 2000
	Progress, Off
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
	GuiControl,, FieldSLOBSAPI, %savedSLOBSAPI%
	GuiControl,, FieldSE, %savedSE%
	GuiControl,, FieldSL, %savedSL%
	GuiControl,, FieldRV, %savedRV%
	GuiControl,Disabled, ReloadButton
	GuiControl,Enable, SaveButton
	UnsavedWork := 1
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
GuiControlGet, FieldSLOBSAPI
GuiControlGet, FieldSE
GuiControlGet, FieldSL
GuiControlGet, FieldRV

FileCreateDir, settings\twitch
FileCreateDir, settings\chat
FileCreateDir, settings\obs
FileCreateDir, settings\slobs
FileCreateDir, settings\streamelements
FileCreateDir, settings\streamlabs
FileCreateDir, settings\tts
file := FileOpen("settings\twitch\user.txt", "w")
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
file := FileOpen("settings\slobs\token.txt", "w")
file.write(FieldSLOBSAPI)
file.close()
file := FileOpen("settings\streamelements\jwtToken.txt", "w")
file.write(FieldSE)
file.close()
file := FileOpen("settings\streamlabs\socketAPIToken.txt", "w")
file.write(FieldSL)
file.close()
file := FileOpen("settings\tts\key.txt", "w")
file.write(FieldRV)
file.close()

MsgBox,,Save Settings, New settings saved
GuiControl,Enable, ReloadButton
GuiControl,Disable, SaveButton
UnsavedWork := 0
return


;; --------------------------------
;; Action when Exit button pressed
;; --------------------------------

ExitFunc(ExitReason, ExitCode){
	if(UnsavedWork){
		Msgbox 52, Exit application,Are you sure you want to exit?`nUnsaved changes will be lost
		IfMsgBox No
			Return 1
	}
	ExitApp
}

GuiClose:
    ExitApp
