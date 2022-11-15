; 압살맨 티스토리 apsalman.tistory.com
CoordMode, Mouse, Screen

#NoTrayIcon
Global wh := ComObjCreate("WinHTTP.WinHTTPRequest.5.1") ;WinHTTP 오브젝트 생성
	  ,req := ComObjCreate("MSXML2.XMLHTTP.6.0") ;XMLHTTP 오브젝트 생성
;----------------------------------Gui 영역----------------------------------
Gui, Add, Text, x10 y11 w70 h20, 사이트 주소
Gui, Add, Edit, x80 y8.5 w350 h20 vSiteLink, 
Gui, Add, Button, x435 y7.5 w60 h22 gSearch, 검 색

Gui, Add, Text, x0 y32 w510 0x10,
Gui, Add, GroupBox, x5 y40 w90 h40, 제거 옵션
Gui, Add, CheckBox, x15 y55 w70 h20 vFilterBlank, 공백 제거

Gui, Add, GroupBox, x100 y40 w305 h40, 방식 선택 (미선택은 WinHTTP)
Gui, Add, Radio, x105 y55 w70 h20 gSetEnc vRadio1, ReadURL
Gui, Add, Radio, x180 y55 w70 h20 vRadio2, URLdown
Gui, Add, Radio, x255 y55 w70 h20 vRadio3, WinHTTP
Gui, Add, Radio, x330 y55 w70 h20 vRadio4, xmlHTTP

Gui, Add, GroupBox, x410 y40 w85 h40, 소요시간
GUi, Add, Text, x430 y58 w60 h20 vUseTime, 

Gui, Add, Edit, x5 y85 w490 h200 vResultBox, 

Gui, Add, Button, x5 y290 w100 h22 gCopy, 복사
;~ Gui, Add, Button, x115 y290 w100 h22 gFind, 검색
;~ Gui, Add, Button, x225 y290 w100 h22 gChange, 바꾸기

;~ Gui, Add, Edit, x5 y320 w100 h20 vBStr
;~ Gui, Add, Edit, x115 y320 w100 h20 vAStr
;~ Gui, Add, Button, x225 y319 w60 h22 gChangeStr, 바꾸기

Gui, Show, w500 h317, 웹 통합 크롤링

Gui, 2:Margin, 0, 0
Gui, 2:Add, ComboBox, x0 y0 w80 gEncod vEncoding, UTF-8||UTF-16|cp949
Gui, 2:-ToolWindow -Caption -Border
;----------------------------------Gui 영역----------------------------------
return

Search: ;검색 버튼 클릭 시 작동
StartTime := A_TickCount
Gui, SubMit, NoHide

SearchType := Radio1?1:Radio2?2:Radio3?3:Radio4?4:4

Result := Filterblank?RegExReplace(RegExReplace(RegExReplace(SearchType=1?ReadURL(SiteLink, Encoding):SearchType=2?URLDownloadToFile(SiteLink):SearchType=4?HTTP("req",SiteLink):HTTP("wh",SiteLink), "  "), "	"), "`n`n"):SearchType=1?ReadURL(SiteLink, Encoding):SearchType=2?URLDownloadToFile(SiteLink):SearchType=4?HTTP("req",SiteLink):HTTP("wh",SiteLink)

GuiControl, , ResultBox, % Result
FinishTime := A_TickCount - StartTime
GuiControl, , UseTime, % FinishTime "ms"
return

SetEnc:
MouseGetPos, mx, my
Gui, 2:Show, % "x" mx-60 " y" my+15
return

Encod:
Gui, 2:Submit, NoHide
Enc := Encoding
Gui, 2:Hide
return

Copy: ;크롤링한 내용을 클립보드에 복사
ClipBoard := Result
ToolTip, 복사되었습니다.
Sleep, 1000
ToolTip
return

;----------------------------------미 구현----------------------------------
;~ Find: ;크롤링한 내용 안에서 키워드 검색
;~ return

;~ Change: ;크롤링한 내용 안에서 키워드 변경
;~ if(StatusChange = "")
;~ {
	;~ StatusChange := 1
	;~ Gui, Show, w500 h345, 웹 통합 크롤링
;~ }
;~ else
;~ {
	;~ StatusChange := ""
	;~ Gui, Show, w500 h317, 웹 통합 크롤링
;~ }
;~ return

;~ ChangeStr:
;~ Gui, Submit, NoHide
;~ StringReplace, ResultChange, Result, BStr, AStr
;~ GuiControl, , ResultBox, %ResultChange%
;~ return
;----------------------------------미 구현----------------------------------

GuiClose:
ExitApp

URLDownloadToFile(URL) {
	URLDownloadToFile, % URL, Error.txt
	FileRead, Result, Error.txt
	FileDelete, Error.txt
	return Result
}

HTTP(HttpType, URL) {
	%HttpType%.Open("Get", URL)
	%HttpType%.Send()
	return %HttpType%.responseText
}

ReadURL(URL, encoding = "UTF-8") {
	static a := "AutoHotkey/" A_AhkVersion
	if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
		return 0
	c := s := 0, o := ""
	if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
	{
		while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
		{
			VarSetCapacity(b, s, 0)
			DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
			o .= StrGet(&b, r >> (encoding = "utf-16" || encoding = "cp1200"), encoding)
		}
		DllCall("wininet\InternetCloseHandle", "ptr", f)
	}
	DllCall("wininet\InternetCloseHandle", "ptr", h)
	return o
}