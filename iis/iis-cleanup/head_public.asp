<html>
<head>
<title>Rotary Club Of Washington, Missouri</title>
<style type="text/css">
<!--
	A.mainlinks:link	{color:#000000; text-decoration:none}
	A.mainlinks:visited	{color:#000000; text-decoration:none}
	A.mainlinks:hover	{color:#800000; text-decoration:none}
-->
</style>
<META HTTP-EQUIV="refresh" content="20;URL=<%=Request.ServerVariables("SCRIPT_NAME")%>"> 
<link href="style.css" rel="STYLESHEET">
<script language=javascript>
<!--
function showpage(id) {
	var options;
	var leftpos;
	var toppos;
	var page;
	page = "/sponsorinfo.asp?id="+id;
	leftpos = (screen.width-400)/2;
	toppos = (screen.height-400)/2;
	options = "'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,copyhistory=no,width=400,height=400 left=" + leftpos + " top=" + toppos + "')"
	var spw = window.open(page, "sponsorinfo", options);
}
-->
</script>
</head>

<body topmargin="0" leftmargin="0"  bgcolor="#FFFFFF">
<% if Session.Contents("status") = "Administrator" or Session.Contents("status") = "Operator" then Response.Write Session("status") & "<br />" end if %>
<table border="0" width="100%" cellspacing="0" cellpadding="5">
  <tr>
    <td valign='top'>