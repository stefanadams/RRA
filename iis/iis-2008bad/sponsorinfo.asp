<%@ Language=VBScript %>
<!--#INCLUDE FILE='connect.asp' -->
<%
'##############################################################################################
'Washington Rotary Membership and Auction Application
'©2003 ITL Enterprises, Inc.
'http://www.itlent.com
'All Rights Reserved
'##############################################################################################
%>
<!--
Washington Rotary Membership and Auction Application
©2003 ITL Enterprises, Inc.
http://www.itlent.com
All Rights Reserved
-->
<html>

<head>
<title>Rotary Club Of Washington, Missouri</title>
</head>
<body onload="window.focus();">
<%
		SQLStatement	= "SELECT id, sellername, advertisement FROM items WHERE id = " & request("id")
		objRS.Open SQLStatement, objConn
		Response.write "<font face='verdana'><b>" & objRS("sellername") & "</b></font><br>"
		Response.Write "<p><font face='verdana' size='2'>" & objRS("advertisement") & "</font></p>"
		objRS.close
		set objRS = nothing
		objConn.close
		set objConn = nothing
%>
</body>
</html>