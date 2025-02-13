option explicit
on error resume next
''The registry key: HKEY_CLASSES_ROOT\Microsoft.ACE.OLEDB.12.0 should exist
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''run in cmd
''C:\Windows\System32\odbcad32.exe
''go to drivers tab 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''run this script that will check whether Microsoft.ACE.OLEDB is installed 
''if Microsoft Access Database Engine 2016 Redistributable is not installed, so install it
Const HKCR=&H80000000 'HKEY_CLASSES_ROOT
Const HKCU=&H80000001 'HKEY_CURRENT_USER
Const HKLM=&H80000002 'HKEY_LOCAL_MACHINE
Const HKUS=&H80000003 'HKEY_USERS
Const HKCC=&H80000005 'HKEY_CURRENT_CONFIG
Const force = true

dim subkey
dim arrSubKeys
Dim oReg: Set oReg=GetObject("winmgmts:!root/default:StdRegProv")
Dim strResultReportName :  strResultReportName = "ResultReport.csv"
Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
Dim strCurDir : strCurDir=getCurrentDirectory()

Dim strKeyPath :  strKeyPath = "SOFTWARE\Classes"
Dim stringToFind :  stringToFind = "Microsoft.ACE.OLEDB"

Dim csvFilePathName : csvFilePathName =strCurDir & "\" & strResultReportName
if objFSO.FileExists( csvFilePathName ) then
	objFSO.deleteFile csvFilePathName,force
	'msgbox "file: " & csvFilePathName & " was deleted"
end if
set objFSO = nothing

oReg.EnumKey HKLM, strKeyPath, arrSubKeys
For Each subkey In arrSubKeys
	
	If InStr(1, subkey, stringToFind) = 1 Then
		writeToFile strCurDir,strResultReportName,subkey
	End If
    
Next
if err.number <>0 then 
	msgbox "main_function_error: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
	err.clear
end if 



sub writeToFile(ByVal strCurDir,ByVal resultFileName,ByVal contents)
	on error resume next
	Const ForWriting = 2
	Const ForReading = 1
	Const ForAppending = 8
	'Opens the file by using the system default
	'TristateUseDefault =-2
	
	'Opens the file as ASCII
	'TristateFalse =0
	
	'Opens the file as Unicode
	Const TristateTrue =-1
    dim  objCSVFile

	Dim csvFilePathName : csvFilePathName =strCurDir & "\" & resultFileName
	
	Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
	Dim newFile:newFile = Not objFSO.FileExists( csvFilePathName )
	
	if newFile Then
		Set objCSVFile = objFSO.CreateTextFile(csvFilePathName,ForWriting, True)
	else
		Set objCSVFile = objFSO.OpenTextFile(csvFilePathName,ForAppending, True,TristateTrue)
	end if
	objCSVFile.Write contents
	objCSVFile.Write vbCrLf
	''objCSVFile.Writeline	
	objCSVFile.close
	set objCSVFile=nothing
	if err.number <>0 then 
		msgbox "write_to_file: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
end sub 

function getCurrentDirectory()
on error resume next
	Dim WshShell, strCurDir
	Set WshShell = CreateObject("WScript.Shell")     
	getCurrentDirectory    = WshShell.CurrentDirectory         
end function