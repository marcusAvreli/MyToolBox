@ECHO OFF    
echo Process started, please wait...    
for /f %%C in ('Find /V /C "" ^< "Salary.txt"') do set SalaryCount=%%C    
echo Salary,%SalaryCount%
for /f %%C in ('Find /V /C "" ^< "Taxes.txt"') do set TaxCount=%%C
echo Tax,%TaxCount%
if TaxCount gtr SalaryCount (
	echo taxes file is longer
)