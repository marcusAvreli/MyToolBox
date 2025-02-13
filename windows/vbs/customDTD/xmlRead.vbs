Option Explicit
'on error resume next

' Initialize global objects and variables.
Dim fso, f, file, folder, filepath, dir, coll
Dim fspec, strFileName, shortName, strResult
Dim LineOfEquals, strFile, strFiles, strFileExt
Dim Files, StartingFolder, WshShell, strDesktop
Dim S, SubFolders, SubFolder, procFilesCount
Dim xmlDoc, state
Dim sLogPath
dim objRoot

Sub ErrorOut
    Wscript.Echo (vbCrLf & "Status: MSVAL failed." + vbCr)
    Wscript.Quit
End Sub

function customLoadXml(byRef inputFileName)
	Dim resultXmlDoc : Set resultXmlDoc = CreateObject("Msxml2.DOMDocument.6.0")
    resultXmlDoc.setProperty "ProhibitDTD", False
    resultXmlDoc.setProperty "ResolveExternals", True 

    resultXmlDoc.validateOnParse = True
    resultXmlDoc.async = False
    resultXmlDoc.load inputFileName
	set	customLoadXml = resultXmlDoc
end function

function  isXmlInvalid (byRef inputDocument)
	Dim isInvalid 
	Dim str
	If inputDocument.parseError.errorCode = 0 Then
       isInvalid = false
    ElseIf inputDocument.parseError.errorCode <> 0 Then
	isInvalid = true
       str = " is not valid" & vbCrLf & _
       inputDocument.parseError.reason & " URL: " & Chr(9) & _
       inputDocument.parseError.url & vbCrLf & "Code: " & Chr(9) & _
       inputDocument.parseError.errorCode & vbCrLf & "Line: " & _
       Chr(9) & inputDocument.parseError.line & vbCrLf & _
       "Char: "  & Chr(9) & inputDocument.parseError.linepos & vbCrLf & _
       "Text: "  & Chr(9) & inputDocument.parseError.srcText
    End If
	if isInvalid = True Then
		msgbox "Is inValid: " & str
	end if
	
	isXmlInvalid = isInvalid
end function

Sub Main
	msgbox "start"
	strFileName="input.xml"
	Set xmlDoc = customLoadXml(strFileName)
	if isXmlInvalid(xmlDoc) = True Then
		Wscript.Quit
	end if
	Set objRoot = xmlDoc.documentElement
	if IsNull(objRoot) Then
		msgbox "object is null"
	end if
	dim objNode : Set objNode = xmlDoc.selectSingleNode("/databaseQueryTemplate/entityName")
	MsgBox objNode.getAttribute("name")  
	if err.number <>0 then 
		ErrorOut
		msgbox "xmlQuery_1: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	msgbox "finish"
	Wscript.Quit
End Sub

Main