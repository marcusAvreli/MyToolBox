Const fsoForWriting = 2

dim xmlToImport : Set xmlToImport = CreateObject("Msxml2.DOMDocument.6.0")          
Dim stylesheet:  Set stylesheet =CreateObject("MSXML2.DOMDocument.6.0")
Dim xslTemplate : Set xslTemplate = CreateObject("Msxml2.XSLTemplate.6.0")

xmlToImport.setProperty "ProhibitDTD",false
xmlToImport.setProperty "ResolveExternals",false
xmlToImport.setProperty "ValidateOnParse",false
xmlToImport.async = false
xmlToImport.load "input.xml"
xmlToImport.validateOnParse = TRUE
xmlToImport.resolveExternals = TRUE
xmlToImport.preserveWhiteSpace = TRUE



stylesheet.async = False
stylesheet.Load "stylesheet.xsl"    
xslTemplate.stylesheet = stylesheet


Dim processor : Set processor = xslTemplate.createProcessor
processor.input = xmlToImport
processor.transform()

Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
Dim destinationRelativePathName : destinationRelativePathName ="output.xml"
Dim objTextStream : Set objTextStream = objFSO.OpenTextFile(destinationRelativePathName, fsoForWriting, True)

'Display the contents of the text file
objTextStream.WriteLine processor.output

'Close the file and clean up
objTextStream.Close
Set objTextStream = Nothing
