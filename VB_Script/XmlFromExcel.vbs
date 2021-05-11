option explicit
on error resume next
Dim strCurDir : strCurDir=getCurrentDirectory()
Dim strTargetExcelName : strTargetExcelName = getExcelFileName()
Dim targetFilePathName : targetFilePathName = strCurDir & "\" & strTargetExcelName
Dim i
dim mapItems
dim parentDirectory
Dim targetQueryRange : targetQueryRange=getUsedRange(targetFilePathName)
'msgbox "targetQueryRange: " & targetQueryRange
Dim targetSpreadSheetName : targetSpreadSheetName=getSpreadSheetName(targetFilePathName)
'msgbox "targetSpreadSheetName: " & targetSpreadSheetName

Dim sql_text: sql_text="Select * FROM [" & targetSpreadSheetName & "$]" 



Dim currentConnection : Set currentConnection = getExcelConnection(targetFilePathName,targetSpreadSheetName)

Dim bundleTypes : set bundleTypes = getBundleTypes(currentConnection,targetSpreadSheetName)

Dim testBusinessSource : testBusinessSource = gettestBusinessSource(currentConnection,targetSpreadSheetName)

Dim bundleDetails : set bundleDetails = getBundleDetails(currentConnection,targetSpreadSheetName)

Dim bundlePathNamesMap : set bundlePathNamesMap = CreateObject("Scripting.Dictionary")

Dim bundleType

For Each bundleType In bundleTypes
                select case bundleType
                                case  "it"                                                                                                              
                                                bundlePathNamesMap.add "it",strCurDir & "\IT" & "\" & testBusinessSource
                                case  "business"                                                                                                                
                                                bundlePathNamesMap.add "business",strCurDir & "\Business" & "\" & testBusinessSource
                end select
Next 

                
                
Dim objFSO

mapItems = bundlePathNamesMap.items

if err.number <>0 then 
                msgbox "Error_Number_1: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
                'err.clear
end if 
                
for i=0 to bundlePathNamesMap.count-1
                Set objFSO = CreateObject("Scripting.FileSystemObject")
                
                parentDirectory  =objFSO.getParentFolderName(mapItems(i))    
                if objFSO.FolderExists(parentDirectory) then
                                DoFolder  parentDirectory,objFSO
                end if

                if             objFSO.fileExists("./importer.xml") then                
                                objFSO.deleteFile "./importer.xml"

                end if

                call CreateFolderRecursive( mapItems(i) )             

next


Dim writtenDestinationPathNames : set writtenDestinationPathNames = writeToXml( bundleDetails , bundlePathNamesMap)
'msgbox "Number Of Created Files: " &  writtenDestinationPathNames.Count



'dim success: success = 
generateImporter writtenDestinationPathNames







'msgbox "Bundle Types_Length<" & bundleTypes.count & ">"
'msgbox "Bundle Types 1<" & bundleTypes.item(0) & ">"
'msgbox "Bundle Types 2<" & bundleTypes.item(1) & ">"
'msgbox "Connection Type <" & TypeName(currentConnection) & ">"


currentConnection.close              

set currentConnection=nothing



                if err.number <>0 then 
                                msgbox "Error_Number_5: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
                                err.clear
                end if 
                
  
Function CreateFolderRecursive(FullPath)
  Dim arr, dir, path
  Dim oFs
''msgbox FullPath
  Set oFs = WScript.CreateObject("Scripting.FileSystemObject")
  arr = split(FullPath, "\")
  path = ""
  For Each dir In arr
    If path <> "" Then path = path & "\"
    path = path & dir
    If oFs.FolderExists(path) = False Then oFs.CreateFolder(path)
  Next
End Function




' Recursive function
Sub DoFolder(strFolder,objFSO)
                on error resume next
                Dim objFile,objFolder
                
    With objFSO.GetFolder(strFolder)

        For Each objFile In .Files
            'If objFile.DateCreated < Date - 180 Then objFile.Delete
                                                objFile.Delete
        Next

        For Each objFolder In .SubFolders
            DoFolder objFolder.Path,objFSO
        Next

        ' Checked every file and subfolder. If this folder is empty, remove it...
        If .Files.Count = 0 Then If .SubFolders.Count = 0 Then .Delete

    End With
                if err.number <>0 then 
                                msgbox "Do_Folder_Error_1: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
                                err.clear
                end if 
End Sub

sub  generateImporter(ByRef writtenDestinationPathNames)
                on error resume next
                Const fsoForWriting = 2
                
                Dim xmlDoc : Set xmlDoc = CreateObject("Msxml2.DOMDocument.6.0") 
                xmlDoc.async = false
                xmlDoc.validateOnParse = TRUE
                xmlDoc.resolveExternals = TRUE
                xmlDoc.preserveWhiteSpace = TRUE
                Dim stylesheet:  Set stylesheet =CreateObject("MSXML2.DOMDocument.6.0")
                Dim xslTemplate : Set xslTemplate = CreateObject("Msxml2.XSLTemplate.6.0")
                set xmlDoc  = createImporterRootElement(xmlDoc)
                
                stylesheet.async = False
                stylesheet.Load "stylesheet1.xsl"                 
                xslTemplate.stylesheet = stylesheet

                Dim processor : Set processor = xslTemplate.createProcessor
                processor.input = xmlDoc
                processor.transform()
                
                Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
                Dim destinationRelativePathName : destinationRelativePathName ="./importer.xml"
                Dim objTextStream : Set objTextStream = objFSO.OpenTextFile(destinationRelativePathName, fsoForWriting, True)

                'Display the contents of the text file
                objTextStream.WriteLine processor.output

                'Close the file and clean up
                objTextStream.Close
                Set objTextStream = Nothing
                set xmlDoc=nothing
                
                Dim xmlDoc2 : Set xmlDoc2 = CreateObject("Msxml2.DOMDocument.6.0")
                xmlDoc2.setProperty "ProhibitDTD",false
                xmlDoc2.setProperty "ResolveExternals",false
                xmlDoc2.setProperty "ValidateOnParse",false
                xmlDoc2.async = false
                
                xmlDoc2.load destinationRelativePathName
                If 0 = xmlDoc2.ParseError Then   
                                'msgbox "importer is ok"
                Else
                   WScript.Echo xmlDoc2.ParseError.Reason
                End If

                
                
                
                
                Dim absoluteFilePathNameToImport : absoluteFilePathNameToImport = writtenDestinationPathNames.item(0)
                
                
                dim xmlToImport : Set xmlToImport = CreateObject("Msxml2.DOMDocument.6.0")          
                xmlToImport.setProperty "ProhibitDTD",false
                xmlToImport.setProperty "ResolveExternals",false
                xmlToImport.setProperty "ValidateOnParse",false
                xmlToImport.async = false
                
                xmlToImport.load absoluteFilePathNameToImport
                
                if 0 = xmlToImport.ParseError Then  
                                'msgbox "OK"
                Else
                   WScript.Echo xmlToImport.ParseError.Reason
                End If

                
                

                dim importedRoot : set importedRoot = xmlToImport.documentElement
                
                dim myNode2 : set myNode2 =importedRoot.cloneNode(true)
                xmlDoc2.documentElement.appendChild myNode2
                
                
                
                
                xmlDoc2.save destinationRelativePathName
                set xmlDoc2=nothing
                                if err.number <>0 then 
                                msgbox "Generate_Importer: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
                                'err.clear
                end if 
                
                msgbox "Generate_Importer_Finish"
'set generateImporter=TRUE
end sub


function writeToXml(ByRef bundleDetails,ByRef bundlePathNamesMap)
                on error resume next
                Dim destinationPathNames : set destinationPathNames = CreateObject("System.Collections.ArrayList")
                Dim bundleRow
                Dim xmlDoc,stylesheet,xslTemplate,processor,objFSO
                Dim destinationAbsolutePath
                Dim rolename
                Dim objTextStream
                Const fsoForWriting = 2

                                
                                                                  
                '   xmlDoc.setProperty("SelectionLanguge", "XPath")
                  ' xmlDoc.setProperty "doctype-system", "test"

                dim index

                for each  bundleRow in bundleDetails
                                Set xmlDoc = CreateObject("Msxml2.DOMDocument.6.0")           
                                xmlDoc.async = false
                                xmlDoc.validateOnParse = TRUE
                                xmlDoc.resolveExternals = TRUE
                                xmlDoc.preserveWhiteSpace = TRUE
                                Set stylesheet =CreateObject("MSXML2.FreeThreadedDOMDocument.6.0")
                                Set xslTemplate = CreateObject("Msxml2.XSLTemplate.6.0")
                                set xmlDoc  = createRootElement(xmlDoc,bundleRow)
                                set xmlDoc  = createOwnerElement(xmlDoc,bundleRow)
                                set xmlDoc  = createAttributesElement(xmlDoc,bundleRow)
                                rolename = bundleRow.item("Role_Name")
                                'msgbox "Before:" & rolename
                                rolename = camelCase(rolename)
                                'rolename = CamelCase(rolename)
                                stylesheet.async = False
                                stylesheet.Load "stylesheet1.xsl"                 
                                xslTemplate.stylesheet = stylesheet

                                Set processor = xslTemplate.createProcessor
                                processor.input = xmlDoc
                                
                                Set objFSO = CreateObject("Scripting.FileSystemObject")

                                'Open the text file
                                destinationAbsolutePath = bundlePathNamesMap.item(bundleRow.item("Role_Type")) & "\"& rolename & ".xml"
                                destinationPathNames.add destinationAbsolutePath
                                'Set objTextStream = objFSO.OpenTextFile(destinationAbsolutePath, fsoForWriting, True)

                                Dim oStream : Set oStream = CreateObject("ADODB.Stream")
                                oStream.Open
                                'oStream.Type=1                             
                                oStream.Charset = "UTF-8"
                                processor.output=oStream
                                processor.transform
                                
                
                                'Display the contents of the text file
                                oStream.SaveToFile destinationAbsolutePath,2
                                oStream.close
                                
                                Set oStream = Nothing
                                Set objTextStream = Nothing
                                Set objFSO = Nothing
                                '               msgbox "After " & rolename
                                
                                
                next
                if err.number <>0 then 
                                msgbox "Write_To_Xml: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
                                err.clear
                end if 
                set writeToXml  = destinationPathNames
end function
