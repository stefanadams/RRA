<%
varOnLoad = onload
if metafresh = "" Then metafresh = 999
%>
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
<META HTTP-EQUIV="refresh" content="<%=metafresh%>;URL=<%=Request.ServerVariables("SCRIPT_NAME")%>"> 
<link href="/library/style.css" rel="STYLESHEET">
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
function showbids(id) {
	var options;
	var leftpos;
	var toppos;
	var page;
	//alert(id)
	page = "/admin_bid_history.asp?id="+id;
	leftpos = (screen.width-400)/2;
	toppos = (screen.height-400)/2;
	options = "'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,copyhistory=no,width=400,height=400 left=" + leftpos + " top=" + toppos + "')"
	var spw = window.open(page, "sponsorinfo", options);
}
-->
</script>
</head>

<body topmargin="0" leftmargin="0"  bgcolor="#FFFFFF" <%=varOnLoad%>>
<% if Session.Contents("status") = "Administrator" or Session.Contents("status") = "Operator" then Response.Write Session("status") & "<br />" end if %>
