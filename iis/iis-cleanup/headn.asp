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
	<style type="text/css">
	<!--
		A.mainlinks:link	{color:#000000;
					 text-decoration:none}
		A.mainlinks:visited	{color:#000000;
					 text-decoration:none}
		A.mainlinks:hover	{color:#800000;
					 text-decoration:none}
	-->
	</style>
<link href="/library/style.css" rel="STYLESHEET">
</head>

<body topmargin="0" leftmargin="0"  bgcolor="#FFFFFF">
<% if Session.Contents("status") = "Administrator" or Session.Contents("status") = "Operator" then Response.Write Session("status") & "<br />" end if %>
