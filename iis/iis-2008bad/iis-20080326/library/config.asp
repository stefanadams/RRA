<%
'##############################################################################################
'Washington Rotary Membership and Auction Application
'©2002 ITL Enterprises, Inc.
'http://www.itlent.com
'All Rights Reserved
'##############################################################################################
'for compusystems
dbpath = server.MapPath("\foxdata")
strConn = "Driver={Microsoft Visual FoxPro Driver};SourceType=DBC;SourceDb=" & dbpath & "\washrotary.dbc"


'for home
'strConn = "Driver={Microsoft Visual FoxPro Driver};SourceType=DBC;SourceDb=c:\inetpub\washingtonrotary\foxdata\washrotary.dbc"



ConnString = strConn
%>