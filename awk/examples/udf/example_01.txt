#!/usr/bin/awk -f
#https://www.sqlpac.com/en/documents/unix-linux-awk-utilities-tutorial.html
function gentag(nom,age) {
        tmp=tolower(substr(nom,1,3))
        return tmp "_" age
}

BEGIN {
        FS=" "
        OFS=";"
}

{
        print $1, $3, gentag($1,$3)
}

END {
	print NR , "lines"
}
