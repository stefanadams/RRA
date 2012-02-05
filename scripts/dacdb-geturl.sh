#!/bin/sh

url=${1:-http://www.directory-online.com/Rotary/Report2/MExtract/RunReport.cfm}

echo -n "Username: "; read user
echo -n "Password: "; stty -echo ; read pass ; stty echo ; echo
echo "LoginName=$user&Password=$pass&ClubNumber=2353&LoginReq=Yes&Submit=Login" > dacdb-credentials.txt

drequest="Format=Excel&Type=Club&ClubID=2353&MemberTypeIDs=0&MemberTypeIDs=5&MemberTypeIDs=2&MemberTypeIDs=1&FromDate=&ToDate=&XSLTemplate=Report%2FReport.cfm&XSLPath=Club"
echo "Request: [$drequest] "; read request
echo ${request:-$drequest} > dacdb-request.txt

echo Get Login Form and Cookies ; curl -c /tmp/cookie -s -o /dev/null http://www.directory-online.com/Rotary/Login.cfm
echo Validate Login ; curl -b /tmp/cookie -d @dacdb-credentials.txt -s -o /dev/null 'http://www.directory-online.com/Rotary/Main.cfm?FuseAction=Validate&'
echo Get Page ; curl -b /tmp/cookie -d @dacdb-request.txt -s -o dacdb-results.html "$url"
echo 'echo Import Results: ; ./dacdb-parse.pl dacdb-results.html | mysql -u washingtonrotary -pharris rra_master && echo /bin/rm -f -v /tmp/cookie dacdb-credentials.txt dacdb-request.txt dacdb-results.html'
