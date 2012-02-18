<html>
<head>
<title>Rotary Radio Auction</title>
<meta http-equiv="refresh" content="20;url=<%=Request.ServerVariables("SCRIPT_NAME")%>">
<link href="style.css" rel="stylesheet">
<!--#include file="showpage.asp" -->
</head>

<!--#include file="connect.asp" -->
<body topmargin="0" leftmargin="0"  bgcolor="#FFFFFF">
<div class="head">636-239-1111 / 800-333-6108<br></div>

<!-- Items Currently Up For Bid -->
<div class="subhead">Item(s) Currently Up For Bid</div>

<%
	SQLStatement = "SELECT id, name, status, sellername, suggestedprice, bid, timer, timeradmin, advertisement, active FROM items WHERE (status = 'Bidding' Or status = 'Halt') Order By id"
	objRS.Open SQLStatement, objConn
%>

<%
	If objRS.EOF Then
%>
		<div class="content_current">No Items Currently Up For Bid</div>
<%
	else
%>
		<TABLE align='center' width='100%' cellpadding='4' cellspacing='0' border='0'>
		<tr>
			<td style='border-bottom: 1 solid #808080'><b>Item Up For Bid</b></td>
			<td align='center' style='border-bottom: 1 solid #808080'><b>Value</b></td>
			<td align='center' style='border-bottom: 1 solid #808080'><b>Current Bid</b></td>
			<td align='center' style='border-bottom: 1 solid #808080'><b>High Bidder</b></td>
			<!-- <td align='center' style='border-bottom: 1 solid #808080'><b>Timer</b></td> -->
			<td align='center' style='border-bottom: 1 solid #808080'><b>Donor</b></td>
			<td align='center' style='border-bottom: 1 solid #808080'><b>Message</b></td>
		</tr>
<%
		while not objRS.eof
			adtext = objRS("advertisement")
			strbid = ""
			trcolor = "#F2F2E0"
			if objRS("timer") <> "" and objRS("timeradmin") = "time" Then
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
			Response.Write "</td>"
			'Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & strTimer & "</td>"
			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("sellername") & "</td>"
			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>"
			if adtext <> "" Then
				Response.Write "<a href=""#"" onClick=""showpage('" & objRS("id") & "');""><font color='#000000'>" & left(adtext,50) & "...</font></a>"
			Else
				Response.Write "&nbsp;"
			End If			
			Response.Write "</td>"   'end of row
			Response.Write "</tr>"
			objRS.MoveNext
		wend
%>
		</TABLE>

<%
	End If
%>

<%
	objRS.Close
%>
	<div class="key">Key: <img src='images/overbid_star.gif' valign='middle' width='14' height='14'>&nbsp;= Bell Ringer | <img valign='middle' src='images/timer.gif'>&nbsp;= Timer</div>

<br>

<!-- Items Next Up For Bid -->
<div class="subhead">Item(s) Next Up For Bid</div>

<%
	SQLStatement = "SELECT id, name, sellername, suggestedprice, priority, status, sequencenumber FROM items WHERE status = 'Ready' ORDER BY SequenceNumber"
	objRS.maxrecords = 10
	objRS.Open SQLStatement, objConn
%>

<%
	If objRS.EOF Then
%>
		<div class="content_next">No New Items Available</div>
<%
	else
%>
		<TABLE align='center' width='100%' cellpadding='0' cellspacing='0' border='0'>"
		<tr>
			<td><b>Next Item Up For Bid</b></td>
			<td><b>Donor Name</b></td>
			<td><b>Value</b></td>
		</tr>
		<tr>
			<td colspan='5'>
				<p>&nbsp;</p>
			</td>
		</tr>
<%
		while not objRS.eof
			Response.Write "<tr>"
			Response.Write "<td valign='top'>" & objRS("id") & ": " & objRS("name") & "</td>"
			Response.Write "<td valign='top'>" & objRS("sellername") & "</td>"
			Response.Write "<td valign='top'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
			Response.Write "</tr>"
			objRS.MoveNext
		wend
%>

<%
	End If
%>

<%
	objRS.close
	Set objRS = Nothing
%>

</body>
</html>

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
