Option Explicit
''to run script just double click or in cmd line type:
'' cscript vbSample.vbs
''expected output is parsing error
Sub ErrorOut
    Wscript.Echo (vbCrLf & "Status: MSVAL failed." + vbCr)
    Wscript.Quit
End Sub

Sub Main


msgbox "hello

if err.number <>0 then 
	ErrorOut
	msgbox "xmlQuery_1: " & Err.Number & ", Source: " & Err.Source & ", Description: " & Err.Description
	err.clear
end if 

End Sub

Main