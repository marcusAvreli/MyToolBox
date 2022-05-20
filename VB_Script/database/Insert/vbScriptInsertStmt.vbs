option explicit
on error resume next
msgbox "START"
Dim VRstatmt
Dim resultFileName: resultFileName="output.csv"
Dim targetSchema : targetSchema = "IDENTITYIQ"
Dim targetTable : targetTable = "tbl_Report_SP_Params"
Dim originalString : originalString = "insert into """ & targetSchema & """."  &"""" & targetTable & """"
Dim sql_text :    sql_text = "Select * FROM [" & targetTable & "$]" & VRstatmt

Dim strCurDir : strCurDir=getCurrentDirectory()
Dim strTargetExcelName : strTargetExcelName = getExcelFileName()
Dim targetFilePathName : targetFilePathName = strCurDir & "\" & strTargetExcelName

Dim objConnection: Set objConnection = excelConnectionOpen(targetFilePathName)
Dim objCommand : Set objCommand = queryCommandBuild(sql_text,objConnection)

'---------------------------------------------------------------------------
'
'execute query
'
'---------------------------------------------------------------------------
Dim objRecordSet : set objRecordSet  = objCommand.Execute
Dim rowDetailsMap : Set rowDetailsMap = generateSqlCommands(targetTable, originalString,objRecordSet)
writeToFile strCurDir,resultFileName,rowDetailsMap
releseResources objRecordset, objCommand, objConnection 
msgbox "FINISH"

function generateSqlCommands (byRef targetTable,ByRef originalString,ByRef objRecordset)
	on error resume next
	Dim csvColumns
	Dim i
	
	Dim objFields : Set objFields = objRecordset.fields	
	Dim rowDetailsMap : set rowDetailsMap = CreateObject("Scripting.Dictionary")
	ReDim csvFields ((objFields.count))	
	


	for i=0 to objFields.count-1                         
	if len(objFields.Item(i).name) > 0 Then
		csvFields(i)=objFields.Item(i).name
	end if
	next
	
	Dim tempCsvFields : tempCsvFields = Join(csvFields,",")	
	if right(tempCsvFields,1)="," then 
		tempCsvFields = cstr(Left(tempCsvFields,Len(tempCsvFields)-1))
	end if
	Dim sqlString : sqlString = originalString & " ("  & tempCsvFields & ") values "
	Dim counter : counter=0
	

	with objRecordset
		if not .bof and not .eof then
			.movefirst
			while( not .eof) 
				Dim csvValues:  csvValues = parseAndFormatValues( targetTable, csvFields, .fields)		
				counter=counter+1
				csvColumns = Join(csvValues,",")

				if right(csvColumns,1)="," then 
					csvColumns = Left(csvColumns,Len(csvColumns)-1)
				end if

				sqlString = sqlString & "(" & csvColumns & ");"
					
				rowDetailsMap.add counter,sqlString
				
				sqlString = originalString & " ("  & tempCsvFields & ") values "
				counter=counter+1
				.movenext
			wend
		end if
	end with
	if err.number <>0 then 
		msgbox "generateSqlCommands: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	set generateSqlCommands = rowDetailsMap	
end function

function parseAndFormatValues(ByRef targetTable,ByRef csvFields,ByRef fields)

	on error resume next	
	
	Dim j
	Dim currentFieldName
	Dim csvValue
	ReDim csvValues((ubound(csvFields)))
	
	
	for j=0 to  ubound(csvFields)	
		currentFieldName = csvFields(j)
		if currentFieldName <> "" Then 
		if targetTable = "tbl_Report_SP_Params" then 
			select case currentFieldName
				case  "NAME"
					csvValue = Cstr(fields.item(currentFieldName))
					csvValue = replace(csvValue,"'","''")
					csvValues(j) = "'" & csvValue & "'"	
				case  "PARAM_ORDERING"
					csvValue = CInt(fields.item(currentFieldName))
					csvValues(j) = csvValue
				case  "SP_ID"
					csvValue = CInt(fields.item(currentFieldName))
					csvValues(j) = csvValue
			end select    
end if			
		end if
	next
	
	if err.number <>0 then 
		msgbox "parseAndFormatValues: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	
	  parseAndFormatValues = csvValues
end function


sub writeToFile (ByVal strCurDir,ByVal resultFileName,ByRef rowDetailsMap)
	'option explicit
	on error resume next	
	Const ForWriting = 2	
	Dim csvFilePath : csvFilePath =strCurDir & "\" & resultFileName
	Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
	dim  objCSVFile : Set objCSVFile = objFSO.CreateTextFile(csvFilePath,ForWriting, True)	
	dim rowKey
	
	For Each rowKey in rowDetailsMap.keys    
		objCSVFile.Write rowDetailsMap(rowKey)
		objCSVFile.Writeline		
	Next
	Set rowDetailsMap = Nothing
	objCSVFile.close
	set objCSVFile=nothing
	
	
	if err.number <>0 then 
		msgbox "writeToFile: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
end sub


sub releseResources(ByRef objRecordset,ByRef objCommand,ByRef objConnection )
	on error resume next
	objRecordset.Close
	Set objCommand = queryCommandRelease(objCommand)
	Set objConnection = excelConnectionClose(objConnection)

	if err.number <>0 then 
		msgbox "releseResources: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
end sub


function queryCommandRelease(ByRef objCommand)
	on error resume next
	set objCommand=nothing
	if err.number <>0 then 
		msgbox "queryCommandRelease: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	set queryCommandRelease=objCommand
end function

function queryCommandBuild(ByRef sql_text, objConnection)
	on error resume next
	Dim objCommand: Set objCommand = CreateObject("ADODB.Command")	
	objCommand.ActiveConnection = objConnection
	objCommand.commandText = sql_text
	objCommand.prepared=true
	
	if err.number <>0 then 
		msgbox "queryCommandBuild: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	set queryCommandBuild=objCommand
	
end function




function excelConnectionOpen(ByRef targetFilePathName)
	on error resume next
	
	Dim objConnection: Set objConnection = CreateObject("ADODB.Connection")
	objConnection.open "Provider=Microsoft.ACE.OLEDB.16.0;data source =" & targetFilePathName &";extended properties=excel 12.0;"
	if err.number <>0 then 
		msgbox "excelConnectionOpen: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	set excelConnectionOpen = objConnection
end function

function excelConnectionClose(ByRef objConnection)
	on error resume next
	objConnection.close
	set objConnection=nothing
	if err.number <>0 then 
		msgbox "excelConnectionClose: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	set excelConnectionClose = objConnection
	
end function
function getCurrentDirectory()
	Dim WshShell, strCurDir
	Set WshShell = CreateObject("WScript.Shell")     
	getCurrentDirectory    = WshShell.CurrentDirectory         
end function

function getExcelFileName()
	Dim strCurDir,WshShell
	Set WshShell = CreateObject("WScript.Shell")
	strCurDir    = WshShell.CurrentDirectory
	
	Set WshShell = Nothing                 
	Dim oFile
	Dim goFS    : Set goFS    = CreateObject("Scripting.FileSystemObject")        
	For Each oFile In goFS.GetFolder(strCurDir).Files
	If "xlsx" = LCase(goFS.GetExtensionName(oFile.Name)) Then                                     
		getExcelFileName = oFile.Name
		exit function
	end if 
	Next

	If oLstPng Is Nothing Then
					WScript.Echo "no excel found"
	End If
   
end function

Public Function ExcelColHead(ByVal ColNum)
  Dim T 
  If ColNum > 26 Then
    T = (ColNum Mod 26)
    ColNum = (ColNum - T) / 26
    ExcelColHead = Chr(64 + ColNum) & Chr(64 + T)
  Else
    ExcelColHead = Chr(64 + ColNum)
  End If
End Function




function LPad(s,l,c)
	Dim n: n =0
	if l>len(s) then n= l-len(s)
	'msgbox "Result:" &  String(n,c) & s
	LPad = String(n,c) & s
end function
