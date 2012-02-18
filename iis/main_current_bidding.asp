<!--#INCLUDE FILE='vars.asp' -->
<!--#INCLUDE FILE='connect.asp' -->
<html>
<head>
<title>M (<% Response.Write DB_YEAR %>): <% Response.Write radiotitle %></title>
<style type="text/css">
<!--
        A:link        {color:red; text-decoration:underline}
        A:visited     {color:red; text-decoration:underline}
        A:hover       {color:red; text-decoration:underline}
        A.mainlinks:link        {color:red; text-decoration:underline}
        A.mainlinks:visited     {color:red; text-decoration:underline}
        A.mainlinks:hover       {color:red; text-decoration:underline}
-->
</style>
<META HTTP-EQUIV="refresh" content="30;URL=<%=Request.ServerVariables("SCRIPT_NAME")%>">
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
<%
	chat = "Web Chat!"
	SQLStatement = "SELECT id, name, status, sellername, suggestedprice, bid, timer, timeradmin, advertisement, active, moreinfo FROM items WHERE (status = 'Bidding' Or status = 'Halt') Order By id"
	objRS.Open SQLStatement, objConn
%>
<!--
<%
	Response.Write "<TABLE bgcolor='#FFD685' align='center' width='100%' cellpadding='10' cellspacing='0' border='0'>"
	Response.Write "<TR bgcolor='#414794'>"
	if chat <> "" then
		Response.Write "<TD><TABLE bgcolor='#FFD685' align='center' width='100%' cellpadding='10' cellspacing='0' border='0'><TR bgcolor='#414794'>"
		Response.Write "<TD width='163' align='left' valign='middle'><a href='http://radioauction.washingtonrotary.com/mibew/client.php?locale=en&style=simplicity' target='_blank' onclick='if(navigator.userAgent.toLowerCase().indexOf('opera') != -1 && window.event.preventDefault) window.event.preventDefault();this.newWindow = window.open('http://radioauction.washingtonrotary.com/mibew/client.php?locale=en&style=simplicity&url='+escape(document.location.href)+'&referrer='+escape(document.referrer), 'webim', 'toolbar=0,scrollbars=0,location=0,status=1,menubar=0,width=640,height=480,resizable=1');this.newWindow.focus();this.newWindow.opener=window;return false;'><img src='http://radioauction.washingtonrotary.com/mibew/button.php?i=webim&lang=en' border='0' width='163' height='61' alt=''/></a></TD>"
		Response.Write "<TD width='163' align='left' valign='middle'><a href='http://lightningstream.surfernetwork.com/Media/player/view/klpw4.asp?call=klpw&skin=KLPW'><img src='http://images.radcity.net/5680/2489224.gif' border='0' width='163' alt=''/></a></TD>"
		Response.Write "<TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'><B>Washington Rotary Radio Auction " & DB_YEAR & "." & night & "<br />Last Refresh: "&FormatDateTime(Date(),2)&" "&FormatDateTime(Time(),3)&"<BR>Listen: "&radio&"<BR>Bid: "&phone&" / <a href='http://radioauction.washingtonrotary.com/mibew/client.php?locale=en&style=simplicity' target='_blank' onclick='if(navigator.userAgent.toLowerCase().indexOf('opera') != -1 && window.event.preventDefault) window.event.preventDefault();this.newWindow = window.open('http://radioauction.washingtonrotary.com/mibew/client.php?locale=en&style=simplicity&url='+escape(document.location.href)+'&referrer='+escape(document.referrer), 'webim', 'toolbar=0,scrollbars=0,location=0,status=1,menubar=0,width=640,height=480,resizable=1');this.newWindow.focus();this.newWindow.opener=window;return false;'>"&chat&"</a></B></TD>"
		Response.Write "<TD width='163' align='left' valign='middle'>"%>
<form action='https://www.paypal.com/cgi-bin/webscr' method='post'> 
<input type='hidden' name='cmd' value='_s-xclick'><input type='hidden' name='hosted_button_id' value='4113257'> 
<table> 
	<tr> 
		<td> 
			<input type='hidden' name='on0' value='Item ID'><input type='text' name='os0' maxlength='60' value='Item ID' onfocus="this.value = ( this.value == this.defaultValue ) ? '' : this.value;return true;"><br /> 
			<input type='hidden' name='item_name' value='Item Description'> <input type='text' name='item_name' maxlength='60' value='Item Description' onfocus="this.value = ( this.value == this.defaultValue ) ? '' : this.value;return true;"><br />
		</td> 
		<td> 
			<input type='hidden' name='on1' value='Street Address'><input type='text' name='os1' maxlength='60' value='Street Address' onfocus="this.value = ( this.value == this.defaultValue ) ? '' : this.value;return true;"><br /> 
			<input type='hidden' name='on2' value='City, State, Zip'><input type='text' name='os2' maxlength='60' value='City, State, Zip' onfocus="this.value = ( this.value == this.defaultValue ) ? '' : this.value;return true;"><br /> 
		</td> 
		<td> 
			<input type='image' src='https://www.paypal.com/en_US/i/btn/btn_paynowCC_LG.gif' border='0' name='submit' alt='PayPal - The safer, easier way to pay online!'><img alt='' border='0' src='https://www.paypal.com/en_US/i/scr/pixel.gif' width='1' height='1'> 
		</td> 
	</tr>
	<tr><td width='960' align='center'><div id="ad"></div></td></tr>
</table> 
</form>
</TD><%
		Response.Write "</TR></TABLE></TD>"
	else
		Response.Write "<TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'><B>Washington Rotary Radio Auction: "&FormatDateTime(Date(),2)&" "&FormatDateTime(Time(),3)&"<BR>Listen: "&radio&"<BR>Bid: "&phone&"</B></TD>"
	end if
	Response.Write "</TR><TR><TD>"
%>
-->
<%
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
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Message</b></td>"
		Response.Write "</tr>"
		while not objRS.eof
			adtext = objRS("advertisement")
			moreinfo = objRS("moreinfo")
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
			Response.Write "<tr bgcolor='" & trcolor & "'><td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080'>"
			if moreinfo <> "" Then
				Response.Write "<a href='" & moreinfo & "' target='_new'><b>More Info</b></a> | "
			End If			
			Response.Write objRS("id") & ": " & objRS("name")
			//fileName = Server.MapPath("/data/vhosts/washingtonrotary.com/radioauction/htdocs/auction/content/pics/2012/"&objRS("id")&".jpg")
			//dim fs
			//set fs=Server.CreateObject("Scripting.FileSystemObject")
			//Response.Write fs.FileExists(fileName)
			//if fs.FileExists(fileName) = true then
			//	Response.Write " - img"
			//else
			//	//Response.Write "'"&fileName&"'"
			//End If
			Response.Write "</td>"
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
'			Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & strTimer & "</td>"
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
                Response.Write "<tr><td colspan='6'>"
                Response.Write "Key: <img src='images/overbid_star.gif' valign='middle' width='14' height='14'>&nbsp;= Bell Ringer | <img valign='middle' src='images/timer.gif'>&nbsp;= Timer"
                Response.Write "</td></tr>"
	End If
	objRS.Close
        Response.Write "</TABLE></TD></TR></TABLE>"
%>

<!-- ---------------- -->
<br>
<!--
<%
	SQLStatement	= "SELECT id, name, sellername, suggestedprice, priority, status, sequencenumber FROM items WHERE status = 'Ready' ORDER BY SequenceNumber"
	objRS.maxrecords = 10
	objRS.Open SQLStatement, objConn

	Response.Write "<TABLE bgcolor='#F2F2E0' align='center' width='600' cellpadding='10' cellspacing='0' border='0'>"
	Response.Write "<TR bgcolor='gray'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'>"
	Response.Write "<B>Item(s) Next Up For Bid</B>"
	Response.Write "</TD></TR><TR><TD>"

	Response.Write "<TABLE align='center' width='100%' cellpadding='0' cellspacing='0' border='0'>"

	If objRS.EOF Then
		Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>No New Items Available</B></TD></TR>"
	else
		Response.Write "<tr>"
		Response.Write "<td><b>Next Item Up For Bid</b></td>"
		Response.Write "<td><b>Donor Name</b></td>"
		Response.Write "<td align='right'><b>Value</b></td>"
		Response.Write "</tr>"
		Response.Write "<tr><td colspan='5'><p>&nbsp;</p></td></tr>"

		while not objRS.eof
			Response.Write "<tr>"
			Response.Write "<td valign='top'>" & objRS("id") & ": " & objRS("name") & "</td>"
			Response.Write "<td valign='top'>" & objRS("sellername") & "</td>"
			Response.Write "<td align='right' valign='top'>&nbsp;&nbsp;" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
			Response.Write "</tr>"
			objRS.MoveNext
		wend
        End If
        objRS.close
        Set objRS = Nothing
%>
-->
<% If Session.Contents("status") = "Administrator" or Session.Contents("status") = "Operator" Then %>
<br><br>
<TABLE width='500' align='center' cellpadding='5' cellspacing='0' bgcolor='#F2F2E0'>
        <TR valign='top'>
                <TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='welcome.asp'>Welcome</A></FONT></TD>
        </TR>
</TABLE>
<br>
<% else %>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<a href="/admin.asp"><img width=8 border=0 src="http://radioauction.washingtonrotary.com/auction/content/icons/arrow-right2.gif"></a>  
<% end If %>

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