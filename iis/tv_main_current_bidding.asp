<!--#INCLUDE FILE='connect.asp' -->
<!--#INCLUDE FILE='contactinfo.asp' -->

<html>
<head>
<title>T: <% Response.Write title %></title>
<style type="text/css">
<!--
	A.mainlinks:link	{ color:#000000; text-decoration:none }
	A.mainlinks:visited	{ color:#000000; text-decoration:none }
	A.mainlinks:hover	{ color:#800000; text-decoration:none }
	BODY 			{ FONT-SIZE: 12pt; FONT-FAMILY: Verdana }
	TABLE 			{ FONT-SIZE: 12pt; FONT-FAMILY: Verdana }
	TR			{ FONT-SIZE: 12pt; FONT-FAMILY: Verdana }
-->
</style>
<META HTTP-EQUIV="refresh" content="20;URL=http://radioauction.washingtonrotary.com/tv"> 
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
<table border="0" width="620" cellspacing="0" cellpadding="5">
  <tr>
    <td valign='top'><%
		SQLStatement = "SELECT id, name, status, sellername, suggestedprice, bid, timer, timeradmin, active FROM items WHERE (status = 'Bidding' Or status = 'Halt') Order By id"
		objRS.Open SQLStatement, objConn

		Response.Write "<TABLE bgcolor='#FFFFFF' align='center' width='100%' cellpadding='0' cellspacing='0' border='0'>"
		Response.Write "<TR bgcolor='#ffffff'><TD align='center' valign='middle'><FONT face='verdana' color='red' size='2'>"
		Response.Write "<B>Washington Rotary Radio Auction: "&FormatDateTime(Date(),2)&" "&FormatDateTime(Time(),3)&"<BR>Listen: "&radio&"<BR>Bid: "&phone&"</B>"
		Response.Write "</TD></TR><TR><TD>"
		Response.Write "<TABLE align='center' width='100%' cellpadding='2' cellspacing='0' border='0'>"

		If objRS.EOF Then
			Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>No Items Currently Up For Bid</B></TD></TR>"
		else
			Response.Write "<tr><td width=10></td><td style='border-bottom: 1 solid #808080'><b>Item#</b></td>"
			Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Description</b></td>"
			Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Value</b></td>"
			Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>High Bid</b></td>"
'			Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Timer</b></td>"
'			Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Donor</b></td>"
'			Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Message</b></td>"
			Response.Write "</tr>"
'			Response.Write "<tr><td colspan='7' style='border-bottom: 1 solid #808080'><p>&nbsp;</p></td></tr>"
			colorchange = TRUE
			while not objRS.eof
			If colorchange = TRUE then
				rowcolor = "#f7f7f7"
				colorchange = False
			Else rowcolor = "#ffffec"
				colorchange = TRUE
			End If 
			strbid = ""
			strTimer = ""
			trcolor = ""
			if objRS("timer") <> "" and objRS("timeradmin") = "time" Then
				newtime = timer
				elapsed = newtime - objRS("timer")
				strTimer = "<img align='left' src='images/timer.gif'>&nbsp;"
'			Else
'				strTimer =  "&nbsp;"
'				trcolor = "#F2F2E0"
			end if
			if objRS("bid") => objRS("SuggestedPrice") Then
				strbid = "<img src='images/overbid_star.gif' width='14' height='14'>&nbsp;"
				'if timeleft = "" or timeleft > 60 Then trcolor = "#ffcc66"
			End If
			if objRS("timeradmin") = "Halt" Then
				strTimer =  "<nobr>Auction Closed</nobr><br>"
				trcolor = "#87cefa"
			end if
			'Response.Write "<tr bgcolor='" & rowcolor & "'><td colspan='5' valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("name") & "</td></tr>"
			Response.Write "<tr bgcolor='" & rowcolor & "'><td width=50>&nbsp;</td>"
			Response.Write "<td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("id") & "</td>"
			Response.Write "<td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & left(objRS("name"),38) & "</td>"
			Response.Write "<td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
			Response.Write "<td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>"
			if strTimer <> "" Then Response.Write strTimer
			if strbid <> "" Then Response.Write strbid
			Response.Write "<b><font color='red'>" & formatcurrency(objRS("bid"),2) & "</font></b></td>"
'			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>"
'			if objRS("active") <> 0 Then
'				call biddername(objRS("id"))
'			Else
'				Response.Write "No Bids"
'			End If
'			Response.Write "</td>"
'			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & strTimer & "</td>"
'			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("sellername") & "</td>"
'			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>"
'			if objRS("advertisement") <> "" Then
'				Response.Write objRS("advertisement")
'			Else
'				Response.Write "&nbsp;"
'			End If			
'			Response.Write "</td>" 'end of row
			Response.Write "</tr>"
			objRS.MoveNext
		wend
	End If
	Response.Write "</TABLE></TD></TR></TABLE><br>"
	objRS.close
	Set objRS = Nothing
	Response.Write("</BODY></HTML>")
%>
