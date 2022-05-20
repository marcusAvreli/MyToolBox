Option Explicit

' Initialize global objects and variables.
Dim fso, f, file, folder, filepath, dir, coll
Dim fspec, strFileName, shortName, strResult
Dim LineOfEquals, strFile, strFiles, strFileExt
Dim Files, StartingFolder, WshShell, strDesktop
Dim S, SubFolders, SubFolder, procFilesCount
Dim xmlDoc, state
Dim sLogPath

'Set global constants and variables.
Const OpenFileForAppending = 8 
LineOfEquals = "=============================================" & vbCrLf

set WshShell = WScript.CreateObject("WScript.Shell")
strDesktop = WshShell.SpecialFolders("Desktop")
Set fso = CreateObject("Scripting.FileSystemObject")
sLogPath = strDesktop & "\msval.txt"

Sub ShowHelp
    Wscript.Echo vbCrLf & _
    "About:" & Chr(9) & "Msval.vbs is an XML file validator." & vbCrLf & _
    vbCrLf & _
    "Syntax:" & Chr(9) & "msval [input_file_or_folder]" & vbCrLf & _
    vbCrLf & _
    "Examples:" & vbCrLf & vbCrLf & _
    Chr(9) & "msval my.xml" & vbCrLf & _
    Chr(9) & "msval C:\MyFolderContainingXML" & vbCrLf & _
    Chr(9) & "msval ..\..\MyFolderContainingXML" & vbCrLf & vbCrLf & _
    "Notes:" & Chr(9) & "If XML file is specified, results are " & _
    "returned in a console message." & vbCrLf & vbCrLf & _
    Chr(9) & "If a folder is specified, a report file, Msval.txt," & _
    " is generated" & vbCrLf & _
    Chr(9) & "on your desktop and validation results are recursive" & _
    " for XML" & vbCrLf & _
    Chr(9) & "files found in the specified folder and all of its" & _
    " subfolders." & vbCrLf
    Exit Sub
End Sub

Sub ErrorOut
    Wscript.Echo (vbCrLf & "Status: MSVAL failed." + vbCr)
    Wscript.Quit
End Sub

Sub ValidateAsXmlFile
    Set xmlDoc = CreateObject("Msxml2.DOMDocument.6.0")
    xmlDoc.setProperty "ProhibitDTD", False
    xmlDoc.setProperty "ResolveExternals", True 

    xmlDoc.validateOnParse = True
    xmlDoc.async = False
    xmlDoc.load(strFileName)
    Select Case xmlDoc.parseError.errorCode
       Case 0 
            strResult = "Valid: " & strFileName & vbCr
       Case Else
           strResult = vbCrLf & "ERROR! Failed to validate " & _
           strFileName & vbCrLf & xmlDoc.parseError.reason & vbCr & _
          "Error code: " & xmlDoc.parseError.errorCode & ", Line: " & _
                           xmlDoc.parseError.line & ", Character: " & _
                           xmlDoc.parseError.linepos & ", Source: " & _
                           Chr(34) & xmlDoc.parseError.srcText & _
                           Chr(34) & " - " & Now & vbCrLf 
    End Select

' Create log file for storing results when validatin multiple files.
    Set f = fso.OpenTextFile(sLogPath, OpenFileForAppending)
    f.WriteLine strResult
    f.Close

    ' Increment processed files count.
    procFilesCount = procFilesCount + 1
    'Release DOM document object
    Set xmlDoc = Nothing
End Sub

Function WalkSubfolders(Folder)
    Dim strFolder, currentFolder, strCurPath
    Set currentFolder = fso.GetFolder(Folder)
    strCurPath = currentFolder.Path
    strFolder = vbCrLf & LineOfEquals & _
                "Folder: " & strCurPath & _
                vbCrLf & LineOfEquals & vbCrLf

    ' Open the log file and append current subfolder.
    Set f = fso.OpenTextFile(sLogPath, OpenFileForAppending)
    f.Write strFolder
    f.Close
    strFolder = ""
    Set Files = currentFolder.Files
    If Files.Count <> 0 Then
      ' Walk the collection. If the file is XML, 
      ' load and validate it.
      For Each File In Files
         strFileName = fso.GetAbsolutePathName(File)
         strFileExt = Right(strFileName,4)
         Select Case strFileExt
           ' Process all known XML file types.
           Case ".xml" ValidateAsXmlFile
           Case ".xsl" ValidateAsXmlFile
           Case ".xsd" ValidateAsXmlFile
           Case Else
         End Select
      Next
    End If

    ' Open the log file and append file list from current subfolder.
    Set f = fso.OpenTextFile(sLogPath, OpenFileForAppending)
    f.Write strFiles
    f.Close
    strFiles  = ""

    Set SubFolders = currentFolder.SubFolders

    If SubFolders.Count <> 0 Then
       For Each SubFolder In SubFolders
          strFolder = strFolder & WalkSubfolders(SubFolder)
       Next
       strFolder = strFolder & vbCr
    End If
End Function

Sub WriteEOFSummary
    Set f = fso.OpenTextFile(sLogPath, OpenFileForAppending)
    strResult = vbCrLf & LineofEquals & _
               "Processing completed at " & Now & vbCrLf & _
               procFilesCount & " files processed" & vbCrLf & _
               LineOfEquals
    f.Write strResult
    f.Close
    strResult = "Results written to " & sLogPath & vbCrLf & _
               "Files processed: " & procFilesCount & vbCrLf & _
               vbCrLf & "Do you want to view the results now?"
    MsgBox strResult, vbYesNo, "MSVAL: Processing completed"
    If vbYes Then
       WshShell.Run ("%windir%\notepad " & sLogPath)
    End If
End Sub

Function ProcessStandAloneFile(sFile)
    Dim basename, str, xdoc
    Set f = fso.GetFile(fspec)
    basename = f.Name
    ' Load XML input file & validate it
    Set xdoc = CreateObject("Msxml2.DOMDocument.6.0")
    xdoc.setProperty "ProhibitDTD", False
    xdoc.setProperty "ResolveExternals", True
    xdoc.validateOnParse = True
    xdoc.async = False
    xdoc.load(fspec)
    If xdoc.parseError.errorCode = 0 Then
       str = basename & " is valid"
    ElseIf xdoc.parseError.errorCode <> 0 Then
       str = basename & " is not valid" & vbCrLf & _
       xdoc.parseError.reason & " URL: " & Chr(9) & _
       xdoc.parseError.url & vbCrLf & "Code: " & Chr(9) & _
       xdoc.parseError.errorCode & vbCrLf & "Line: " & _
       Chr(9) & xdoc.parseError.line & vbCrLf & _
       "Char: "  & Chr(9) & xdoc.parseError.linepos & vbCrLf & _
       "Text: "  & Chr(9) & xdoc.parseError.srcText
    End If
    ProcessStandAloneFile = str
End Function

Sub Main
    'Initialize files count
    procFilesCount = 0

    ' Get the folder to scan for files.
    If Wscript.Arguments.Length > 0 Then
       fSpec = Wscript.Arguments.Item(0)
       fSpec = fSpec & "\"
    Else
       ShowHelp
       WScript.Quit
    End If

    fspec = fso.GetAbsolutePathName(fspec)
    If fso.FileExists(fspec) Then
       strResult = ProcessStandAloneFile(fspec)
       Wscript.Echo strResult
       Wscript.Quit
    ElseIf fso.FolderExists(fspec) Then
       ' Executes a 'DIR' command into a collection.
       Set dir = fso.GetFolder(fspec)
       Set coll = dir.Files
       ' Create the log file on the user's desktop.
       Set f = fso.CreateTextFile(sLogPath, 1)
       strResult = vbCrLf & LineofEquals & sLogPath & _
           " at " & Now & vbCrLf & LineOfEquals & vbCrLf
       f.Write strResult
       f.Close
       WalkSubfolders(fSpec)
    Else
       strResult = vbCrLf & "Input file or folder " & _
                   fspec & " does not exist."
       MsgBox strResult, vbOKOnly, _
             "MSVAL: File or folder doesn't exist"
        ErrorOut
    End If

    WriteEOFSummary

    ' Reset object variables.
    Set fso = Nothing
    Set xmlDoc = Nothing

End Sub

Main