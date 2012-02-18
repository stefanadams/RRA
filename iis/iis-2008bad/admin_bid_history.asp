<%@ Language=VBScript %>
<!--#INCLUDE FILE='connect.asp' -->
<%
'##############################################################################################
'Washington Rotary Membership and Auction Application
'©2003 ITL Enterprises, Inc.
'http://www.itlent.com
'All Rights Reserved
'##############################################################################################
id = Request.QueryString("id")
%>
<!--
Washington Rotary Membership and Auction Application
©2003 ITL Enterprises, Inc.
http://www.itlent.com
All Rights Reserved
-->
<html>

<head>
<title>Bid History</title>
</head>
<body onload="window.focus();">
<center><font face='verdana' size='2'><b>Bid History For Item <%=id%></b></font><br><br>
<%

sql = "SELECT bidhistory.ItemID, bidhistory.Amount, bidders.Name FROM bidhistory INNER JOIN bidders ON bidhistory.BidderID = bidders.BidderID WHERE bidhistory.ItemID = " & id & " Order By bidhistory.Amount Desc"
'Response.Write sql
objRS.open sql, objConn

While Not objRS.eof
	Response.Write "<font face='verdana' size='2'>" & objRS("name") & " - " & formatcurrency(objRS("Amount")) & "</font><br>"
	objRS.movenext
Wend
objRS.close
set objRS = nothing
%>
</center>
</body>
</html>