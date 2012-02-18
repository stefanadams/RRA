<!--#INCLUDE FILE='connect.asp' -->
<!--#INCLUDE FILE='contactinfo.asp' -->

<html>
<head>
<title>O: <% Response.Write title %></title>
<style type="text/css">
<!--
	A.mainlinks:link	{color:#000000; text-decoration:none}
	A.mainlinks:visited	{color:#000000; text-decoration:none}
	A.mainlinks:hover	{color:#800000; text-decoration:none}
-->
</style>
<META HTTP-EQUIV="refresh" content="20;URL=/operators"> 
<link href="/operators.css" rel="STYLESHEET">
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

<%
	SQLStatement = "SELECT id, name, status, sellername, suggestedprice, bid, timer, timeradmin, advertisement, active FROM items WHERE (status = 'Bidding' Or status = 'Halt') Order By id"
	objRS.Open SQLStatement, objConn
'	Response.Write "<TABLE bgcolor='#FFD685' align='center' width='100%' cellpadding='10' cellspacing='0' border='0'>"
'	Response.Write "<TR bgcolor='#414794'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'>"
'	Response.Write "<B>Washington Rotary Radio Auction: "&FormatDateTime(Date(),2)&" "&FormatDateTime(Time(),3)&"<BR>Listen: "&radio&"<BR>Bid: "&phone&"</B>"
'	Response.Write "</TD></TABLE>"
	Response.Write "<TABLE bgcolor='#FFD685' align='center' width='100%' cellpadding='10' cellspacing='0' border='0'>"
	Response.Write "<TR><TD>"

	Response.Write "<TABLE align='center' width='100%' cellpadding='4' cellspacing='0' border='0'>"

	If objRS.EOF Then
		Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>No Items Currently Up For Bid</B></TD></TR>"
	else
		Response.Write "<tr><td style='border-bottom: 1 solid #808080'><b>Item Up For Bid</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Value</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Current Bid</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>High Bidder</b></td>"
'		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Timer</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Donor</b></td>"
'		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Message</b></td>"
		Response.Write "</tr>"
		while not objRS.eof
			adtext = objRS("advertisement")
			strbid = ""
			trcolor = "#F2F2E0"
			if objRS("timer") <> "" and (objRS("timeradmin") = "time" or objRS("timeradmin") = "end") Then
				newtime = timer
				elapsed = newtime - objRS("timer")
				strTimer = "<img align='left' src='images/timer.gif'>&nbsp;"
				trcolor = "#FFD685"
			Else
				strTimer =  "&nbsp;"
				'trcolor = "#F2F2E0"
			end if
			if objRS("bid") => objRS("SuggestedPrice") Then
				strbid = "<img src='images/overbid_star.gif' width='14' height='14'>&nbsp;"
				if timeleft = "" or timeleft > 60 Then trcolor = "#FFD685"
			End If
			if objRS("timeradmin") = "Halt" Then
				strTimer =  "<nobr>Auction Closed</nobr><br>"
				trcolor = "#87cefa"
			end if
			Response.Write "<tr bgcolor='" & trcolor & "'><td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("id") & ": " & objRS("name") & "</td>"
			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>"
			if strTimer <> "" then Response.Write strTimer
			if strbid <> "" Then Response.Write strbid
			Response.Write "<b><font color='red'>" & formatcurrency(objRS("bid"),2) & "</font></b></td>"
			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>"
			if objRS("bid") > 0 Then
				call biddername(objRS("id"))
			Else
				Response.Write "&nbsp;-&nbsp;"
			End If
			Response.Write "</td></font>"
'			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & strTimer & "</td>"
			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("sellername") & "</td>"
'			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>"
'			if adtext <> "" Then
'				Response.Write "<a href=""#"" onClick=""showpage('" & objRS("id") & "');""><font color='#000000'>" & left(adtext,50) & "...</font></a>"
'			Else
'				Response.Write "&nbsp;"
'			End If			
'			Response.Write "</td>"   'end of row
			Response.Write "</tr>"
			objRS.MoveNext
		wend
	End If
	objRS.Close
	Response.Write "<tr><td colspan='6'>"
	Response.Write "Key: <img src='images/overbid_star.gif' valign='middle' width='14' height='14'>&nbsp;= Bell Ringer | <img valign='middle' src='images/timer.gif'>&nbsp;= Timer"
	Response.Write "</td></tr>"
	Response.Write "</TABLE></TD></TR></TABLE>"
%>

</BODY>
</HTML>

<%
On Error Resume Next
if isObject(objRS) Then
	objRS.close
	set objRS = nothing
End If

if isObject(objConn) Then
	ojbConn.close
	set objConn = nothing
End If
%>
