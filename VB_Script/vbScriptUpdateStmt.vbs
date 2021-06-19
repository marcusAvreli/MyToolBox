option explicit
on error resume next
'generates xml bundle definitions based on excel file

msgbox "started"

'Get_Excel_Connection: 3706, Source: ADODB.Connection, Description: Provider cannot be found. It may not be properly installed.
'32-bit OS: HKLM\Software\Microsoft\Office\12.0\Access Connectivity Engine\InstallRoot\Path

'64-bit OS: HKLM\Software\Wow6432Node\Microsoft\Office\12.0\Access Connectivity Engine\InstallRoot\Path
'The registry key: HKCR\Microsoft.ACE.OLEDB.12.0 should exist
'C:\Windows\System32\odbcad32.exe ==> drivers
'https://social.msdn.microsoft.com/Forums/sqlserver/en-US/35c080be-7a20-4812-be34-4a8b3844d88d/how-can-i-see-which-microsoftaceoledbxx0-provider-is-registered-on-my-local-machine?forum=csharpgeneralf



Dim strCurDir : strCurDir=getCurrentDirectory()
Dim strTargetExcelName : strTargetExcelName = getExcelFileName()
Dim targetFilePathName : targetFilePathName = strCurDir & "\" & strTargetExcelName
msgbox targetFilePathName
Dim i
dim mapItems
dim parentDirectory
'Dim targetQueryRange : targetQueryRange=getUsedRange(targetFilePathName)
'msgbox "targetQueryRange: " & targetQueryRange
'Dim targetSpreadSheetName : targetSpreadSheetName=getSpreadSheetName(targetFilePathName)
Dim targetSpreadSheetName : targetSpreadSheetName="employee"
msgbox "targetSpreadSheetName: " & targetSpreadSheetName


Dim resultFileName: resultFileName="Export.csv"
Dim targetSchema : targetSchema = "idm"
Dim targetTable : targetTable = "employee"



Dim currentConnection : Set currentConnection = getExcelConnection(targetFilePathName,targetSpreadSheetName)
                

dim rowDetails : set rowDetails= getRowDetails(currentConnection,targetSpreadSheetName)


generateInsertStatements strCurDir,resultFileName,targetFilePathName,targetSchema,targetTable,rowDetails

                


'msgbox "Number Of Created Files: " &  writtenDestinationPathNames.Count


'msgbox "Connection Type <" & TypeName(currentConnection) & ">"


currentConnection.close              

set currentConnection=nothing

  msgbox "Finished"

if err.number <>0 then 
	msgbox "main_function_error: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
	err.clear
end if 
                

sub generateInsertStatements (ByVal strCurDir,ByVal resultFileName,ByVal targetFilePathName,ByRef targetSchema,ByREf targetTable,ByVal rowDetails)
	on error resume next
	Const ForWriting = 2
	Dim csvFilePath : csvFilePath =strCurDir & "\" & resultFileName
	Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
	dim  objCSVFile : Set objCSVFile = objFSO.CreateTextFile(csvFilePath,ForWriting, True)
	if err.number <>0 then 	
		msgbox "generateSqlCommands1: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
		end if
		dim selectQuery: selectQuery ="select test1,tewst from table where id_number in ("
		
		dim rowDetailsMap,csvColumns
		dim sqlString
		Dim notNullFields 
		Dim notNullFieldNames 
		dim idNumbers : set idNumbers=CreateObject("System.Collections.ArrayList")
		dim result_idNumbers
		ReDim csvValues((6))
		for each  rowDetailsMap in rowDetails
			set notNullFields = CreateObject("System.Collections.ArrayList")
			set notNullFieldNames = CreateObject("System.Collections.ArrayList")
			dim idNumber : idNumber  = rowDetailsMap.item("ID")
			dim firstName : firstname = rowDetailsMap.item("firstname")
			dim lastname : lastname = rowDetailsMap.item("lastname")
			dim birthday : birthday = rowDetailsMap.item("birthday")
			dim email : email = rowDetailsMap.item("email")
			dim phone : phone = rowDetailsMap.item("phone")
			dim website : website = rowDetailsMap.item("website")
			dim image : image = rowDetailsMap.item("image")
			
			if len(idNumber)<>0 then 
				idNumbers.add "'" & idNumber & "'"
				
				notNullFields.add "" & idNumber & "" 
				notNullFieldNames.add "ID"				
									
			end if
			if len(firstName)<>0 then 
				if not isNumeric(firstName) then
					notNullFields.add "'" & firstName & "'" 
					notNullFieldNames.add "firstName"
				end if
			end if
			if len(lastname)<>0 then 
				if not isNumeric(lastname) then
					notNullFields.add "'" & lastname & "'" 
					notNullFieldNames.add "lastname"
				end if
			end if
			if len(birthday)<>0 then 
				if  isNumeric(birthday) then
					msgbox "birthday: " & birthday
					
					Dim sCurrentDate
					sCurrentDate = FormatDateTime(birthday, 1)
					msgbox "formatted_birthday:" & sCurrentDate
					''dim TimeInMS : set TimeInMS = Strings.Format(Now(), "dd-MMM-yyyy HH:mm:ss")
					'dim restString : restString= formatdatetime birthday,vbGeneralDate
					formatdatetime birthday, vbGeneralDate
					msgbox "" & birthday
					notNullFields.add "'" & birthday & "'" 
					notNullFieldNames.add "birthday"
				end if
			end if
			if len(email)<>0 then 
				if not isNumeric(email) then
					notNullFields.add "'" & email & "'" 
					notNullFieldNames.add "email"
				end if
			end if
			if len(phone)<>0 then 
				if not isNumeric(phone) then
					notNullFields.add "'" & phone & "'" 
					notNullFieldNames.add "phone"
				end if
			end if
			if len(website)<>0 then 
				if not isNumeric(website) then
					notNullFields.add "'" & website & "'" 
					notNullFieldNames.add "website"
				end if
			end if
			if len(image)<>0 then 
				if not isNumeric(image) then
					notNullFields.add "'" & image & "'" 
					notNullFieldNames.add "image"
				end if
			end if
			
			csvColumns = "insert into "&  targetTable & " ("& Join(notNullFieldNames.ToArray(),",") & ") values (" & Join(notNullFields.ToArray(),",") &")"
			sqlString = csvColumns & ";"' & " where id_number='" & idNumber & "';"
			objCSVFile.Write sqlString
			objCSVFile.Writeline

		next
                
	dim oracleComments
	
	oracleComments="--following statement selects mispar_oved and id_number"
	objCSVFile.Writeline oracleComments
	
	result_idNumbers  = Join(idNumbers.ToArray(),",")
	selectQuery = selectQuery & result_idNumbers & ");"
	objCSVFile.Writeline selectQuery
	
	oracleComments="--following statement shows id_number that DOES NOT EXIST!!!! in test"
	objCSVFile.Writeline oracleComments
	
	selectQuery="drop type string_tab force;"           
	objCSVFile.Writeline selectQuery
	
	selectQuery="create type string_tab is table of varchar(9);"          
	objCSVFile.Writeline selectQuery
	
	selectQuery="SELECT *   FROM TABLE(string_tab(" & result_idNumbers & "))"
	objCSVFile.Writeline selectQuery
	
	selectQuery="WHERE COLUMN_VALUE NOT IN (SELECT id_number FROM table);"
	objCSVFile.Writeline selectQuery
	
	objCSVFile.close
	set objCSVFile=nothing
if err.number <>0 then 
	msgbox "generate_insert_commands: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
	err.clear
end if 
end sub





sub generateSqlCommands (ByVal strCurDir,ByVal resultFileName,ByVal targetFilePathName,ByRef targetSchema,ByREf targetTable,ByRef rowDetails)
	on error resume next
	Const ForWriting = 2
	Dim csvFilePath : csvFilePath =strCurDir & "\" & resultFileName
	Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
	dim  objCSVFile : Set objCSVFile = objFSO.CreateTextFile(csvFilePath,ForWriting, True)
	if err.number <>0 then 	
		msgbox "generateSqlCommands1: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
		end if
		dim selectQuery: selectQuery ="select test1,tewst from table where id_number in ("
		
		dim rowDetailsMap,csvColumns
		dim sqlString
		Dim notNullFields 
		dim idNumbers : set idNumbers=CreateObject("System.Collections.ArrayList")
		dim result_idNumbers
		ReDim csvValues((6))
		for each  rowDetailsMap in rowDetails
			set notNullFields = CreateObject("System.Collections.ArrayList")
			dim idNumber : idNumber  = rowDetailsMap.item("ID")
			
			
			if len(idNumber)<>0 then 
				idNumbers.add "'" & idNumber & "'"
				''if len(werks)<>0 then 
					''			notNullFields.add "ssd='" & werks & "'"                  
									
			end if
			csvColumns = "update "&  targetTable & " set " & Join(notNullFields.ToArray(),",")
			sqlString = csvColumns & " where id_number='" & idNumber & "';"
			objCSVFile.Write sqlString
			objCSVFile.Writeline

		next
                
	dim oracleComments
	
	oracleComments="--following statement selects mispar_oved and id_number"
	objCSVFile.Writeline oracleComments
	
	result_idNumbers  = Join(idNumbers.ToArray(),",")
	selectQuery = selectQuery & result_idNumbers & ");"
	objCSVFile.Writeline selectQuery
	
	oracleComments="--following statement shows id_number that DOES NOT EXIST!!!! in test"
	objCSVFile.Writeline oracleComments
	
	selectQuery="drop type string_tab force;"           
	objCSVFile.Writeline selectQuery
	
	selectQuery="create type string_tab is table of varchar(9);"          
	objCSVFile.Writeline selectQuery
	
	selectQuery="SELECT *   FROM TABLE(string_tab(" & result_idNumbers & "))"
	objCSVFile.Writeline selectQuery
	
	selectQuery="WHERE COLUMN_VALUE NOT IN (SELECT id_number FROM table);"
	objCSVFile.Writeline selectQuery
	
	objCSVFile.close
	set objCSVFile=nothing
if err.number <>0 then 
	msgbox "generateSqlCommands: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
	err.clear
end if 
end sub

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

function getUsedRange(ByVal originFileName)
	Dim originSheetName
	Dim objExcel1,originObjSpread,objWorksheet1
	Set objExcel1 = CreateObject("Excel.Application")
	Const xlExclusive = 3
	Const xlLocalSessionChanges = 2   
	objExcel1.displayalerts = false
	Set originObjSpread = objExcel1.Workbooks.Open(originFileName)
	originObjSpread.sheets(1).activate
	Set objWorksheet1 = originObjSpread.Worksheets(1)
	Dim iCell
	Dim cellValue
	dim clearenceCounter:clearenceCounter=0        
                
	objWorksheet1.usedrange.value=objExcel1.trim(objWorksheet1.usedrange)
   
	originSheetName=objWorksheet1.name
	''set general format
	objWorksheet1.usedrange.NumberFormat="@"
	
	
	Dim startingColumn : startingColumn = objWorksheet1.usedrange.column
	Dim numberOfColumns : numberOfColumns = objWorksheet1.usedrange.columns.count
	Dim startingRow : startingRow = objWorksheet1.usedRange.row
	Dim numberOfRows: numberOfRows = objWorksheet1.usedRange.rows.count
	'msgbox "number of used rows: " & numberOfRows
	Dim rangeName : rangeName = ExcelColHead(numberOfColumns)
	
	
	Dim queryRange : queryRange = "A1:" & rangeName & cstr(numberOfRows)

	originObjSpread.Save
	originObjSpread.Close false
	objExcel1.displayalerts = True
	objExcel1.quit
	Set originObjSpread = Nothing
	Set objExcel1 = Nothing
	if err.number <>0 then 
		msgbox "Get_Spread_Sheet_Name: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if
	getUsedRange = queryRange
end function

function RemoveWhiteSpace(ByRef valueToProcess)

Dim regExp :set regExp = createobject("VBScript.REgEXp")
with regExp
	.pattern ="\s"
	.Multiline=true
	.global=true
	RemoveWhiteSpace=.Replace(valueToProcess,vbNullString)
end with                              
end function



function getSpreadSheetName(ByVal originFileName)    
	on error resume next
	Dim objExcel1 : Set objExcel1 = CreateObject("Excel.Application")             
	objExcel1.displayalerts = false    
	Dim objSpread :  Set objSpread = objExcel1.Workbooks.Open(originFileName)    
	if err.number <>0 then 
					msgbox "Get_Spread_Sheet_Name2: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
					err.clear
	end if
	Dim objWorksheet1  : Set objWorksheet1 = objSpread.Worksheets(1)     
	Dim sheetName : sheetName=objWorksheet1.name
	
	
	objSpread.Close               
	objExcel1.displayalerts = True     
	objExcel1.quit   
	Set objSpread = Nothing
	Set objExcel1 = Nothing 
	if err.number <>0 then 
		msgbox "Get_Spread_Sheet_Name: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	getSpreadSheetName = sheetName
end function




function getExcelConnection(ByRef targetFilePathName, byref targetSpreadSheetName)
	on error resume next	
	Const adSchemaColumns=4
	Const adBSTR = 8 
	Const  adInput=1	
	dim VRstatmt,i,j
	dim sql_text : sql_text="Select * FROM [" & targetSpreadSheetName & "$]" & VRstatmt
	
	Dim objConnection: Set objConnection = CreateObject("ADODB.Connection")
	
	with objConnection
		.Provider = "Microsoft.ACE.OLEDB.16.0"                
		.properties("extended properties").value="excel 12.0;HDR=YES"
		.open targetFilePathName                          
	end with
	
	if err.number <>0 then 
		msgbox "Get_Excel_Connection: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		err.clear
	end if 
	
	set getExcelConnection = objConnection               
end function




function getRowDetails(ByRef currentConnection,ByRef targetSpreadSheetName)
	on error resume next
	'msgbox "START_BUNDLE_DETAILS"
	''Role_Name      Display_Name   Role_Type
	'msgbox "Target_SPreadShett_Name: " & targetSpreadSheetName
	Dim i,j,VRstatmt,currentFieldName,csvValue
	Dim emptyString : emptyString=""
	dim sql_text : sql_text="select *   FROM [" & targetSpreadSheetName & "$]"  & VRstatmt
	
	Dim objCommand: Set objCommand = CreateObject("ADODB.Command")

	objCommand.ActiveConnection = currentConnection

	objCommand.commandText = sql_text

	objCommand.prepared=true

	Dim objRecordset : Set objRecordset = objCommand.execute
                
	if err.number <>0 then 
		msgbox "Get_Bundle_Details0: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
		'err.clear
	end if                
                
	Dim objFields : Set objFields = objRecordset.fields
	'msgbox "Header Names: " & objFields(0).Name
	ReDim csvFields ((objFields.count)) 
	Dim rowDetailsMap : set rowDetailsMap = CreateObject("Scripting.Dictionary")
	Dim rowDataList : set rowDataList = CreateObject("System.Collections.ArrayList")
	for i=0 to objFields.count-1                         
					if len(objFields.Item(i).name) > 0 Then
									csvFields(i)=objFields.Item(i).name
					end if
	next
	if err.number <>0 then 
					msgbox "Get_Bundle_Details1: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
					'err.clear
	end if
	Dim counter : counter=0
	with objRecordset
		if not .bof and not .eof then
			'.movelast
			.movefirst                           
			while( not .eof) 
				for j=0 to  objFields.count
		currentFieldName = csvFields(j)                                                                
		if currentFieldName = "" then 
			'msgbox "current field name is null" 
		end if
		
		dim currentValue
		if currentFieldName <> "" Then 
			select case currentFieldName
				case  "ID" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
																																											if isNumeric(csvValue) then
						csvValue=LPad(csvValue,9,"0")
						rowDetailsMap.add currentFieldName,csvValue        
						end if     
					else
						rowDetailsMap.add currentFieldName,""
					end if
				case  "firstname" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
						rowDetailsMap.add currentFieldName,csvValue						
					else
						rowDetailsMap.add currentFieldName,""
					end if
				case  "lastname" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
						rowDetailsMap.add currentFieldName,csvValue						
					else
						rowDetailsMap.add currentFieldName,""
					end if
				case  "email" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
						rowDetailsMap.add currentFieldName,csvValue						
					else
						rowDetailsMap.add currentFieldName,""
					end if
				case  "phone" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
						rowDetailsMap.add currentFieldName,csvValue						
					else
						rowDetailsMap.add currentFieldName,""
					end if
				case  "birthday" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
						rowDetailsMap.add currentFieldName,csvValue						
					else
						rowDetailsMap.add currentFieldName,""
					end if
				case  "website" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
						rowDetailsMap.add currentFieldName,csvValue						
					else
						rowDetailsMap.add currentFieldName,""
					end if
				case  "image" 
					currentValue = objRecordset.fields.item(currentFieldName)
					if not isNull(currentValue) then
						csvValue = Cstr(objRecordset.fields.item(currentFieldName))                                                                
						csvValue = Trim(csvValue)
						rowDetailsMap.add currentFieldName,csvValue						
					else
						rowDetailsMap.add currentFieldName,""
					end if
			end select
		end if                                                                  
		next
		'msgbox "Current Row Number " & counter
		counter=counter+1
		rowDataList.add rowDetailsMap
		set rowDetailsMap = CreateObject("Scripting.Dictionary")
			.movenext
	wend
	end if
end with
	
	if err.number <>0 then 
					msgbox "Get_Bundle_Details9: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
					'err.clear
	end if
	
	objRecordset.Close
	if err.number <>0 then 
					msgbox "Get_Bundle_Details10: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
					'err.clear
	end if
	set getRowDetails=rowDataList

end function

function LPad(s,l,c)
                Dim n: n =0
                if l>len(s) then n= l-len(s)
                LPad = String(n,c) & s
end function
