<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<!--#include file="head.asp"-->
<%
		SQLStatement	= "SELECT id, name, status, sellername, suggestedprice, bid, timer, timeradmin, auctioneer, active FROM items WHERE status = 'Bidding' Order By Auctioneer, SequenceNumber"
		objRS.Open SQLStatement, objConn
			
		Response.Write "<TABLE bgcolor='#F2F2E0' align='center' width='95%' cellpadding='2' cellspacing='0' border='0'>"
		Response.Write "<TR bgcolor='gray'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'>"
		Response.Write "<B>Admin - Item(s) Currently Up For Bid</B>"
		Response.Write "</TD></TR><TR><TD>"

		Response.Write "<TABLE align='center' width='100%' cellpadding='5' cellspacing='0' border='0'>"
		
		If objRS.EOF Then

		Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>No Items Currently Up For Bid</B></TD></TR>"
		
		else

		Response.Write "<tr><td style='border-bottom: 1 solid #808080'><font size='1'><b>ID</b></font></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>Item Up For Bid</b></font></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>Value</b></font></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>Current Bid</b></font></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>High Bidder</b></font></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>Timer</b></font></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>Donor Name</b></font></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>Auctioneer</b></font></td>"
		Response.Write "</tr>"
		
		Response.Write "<tr><td colspan='8' style='border-bottom: 1 solid #808080'><img src='images/spacer.gif' width='1' height='1'></td></tr>"
		
		while not objRS.eof
		strbid = ""
		trcolor = ""
		strTimer = ""
		if objRS("timer") <> 0 and objRS("timeradmin") <> "start" Then
			newtime = timer
			elapsed = newtime - objRS("timer")
			strTimer = "<font color='red'><b>" & formatnumber(elapsed/60,1) & "</b></font>"
			trcolor = "#F2F2E0"
		End if
		if objRS("timer") <> 0 and objRS("timeradmin") = "time" Then
'			strTimer = strTimer & "<br><a href='admin_stop_timer_01.asp?id=" & objRS("id") & "'><font face='arial' size='1' color='blue'>Stop Timer</font></a>"
			strTimer = strTimer & "<br><a href='admin_stop_auction_01.asp?id=" & objRS("id") & "'><font face='arial' size='1' color='red'><nobr>End Auction</nobr></font></a>"
		End If
		if objRS("timeradmin") = "start" Then
			strTimer =  "<font face='arial' size='1' color='green'>Waiting</font>"
			trcolor = "#F2F2E0"
		end if
		if objRS("timeradmin") = "stop" Then
			strTimer = strTimer & "<br><font face='arial' size='1' color='blue'>Stand By</font>"
			trcolor = "#F2F2E0"
		end if
		if objRS("timeradmin") = "end" Then
			strTimer = strTimer & "<br><font face='arial' size='1' color='red'>Ending</font>"
			trcolor = "#F2F2E0"
		end if
		
		if strTimer = "" Then strTimer = "<a href='admin_start_timer_01.asp?id=" & objRS("id") & "'><font face='arial' size='1' color='#000000'>Start</font></a>"
		
		if objRS("bid") => objRS("SuggestedPrice") Then
			strbid = "<img src='images/overbid_star.gif' width='14' height='14'>&nbsp;"
			if timeleft = "" or timeleft > 60 Then trcolor = "#ffcc66"
		End If
		
		Response.Write "<tr bgcolor='" & trcolor & "'>"
		Response.Write "<td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & objRS("id") & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("name") & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>"
			if strbid <> "" Then Response.Write strbid
		Response.Write "<b><font color='red'>" & formatcurrency(objRS("bid"),2) & "</font></b></td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>"
			if objRS("active") <> 0 Then
				call biddername(objRS("id"))
			Else
				Response.Write "&nbsp;-&nbsp;"
			End If
		Response.Write "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & strTimer & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("sellername") & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>"
			Select Case objRS("auctioneer")
			case 0 Response.Write "<img src='images/notify_a.gif' border='0'>"
			case -1 Response.Write "<img src='images/notify_b.gif' border='0'>"
			end select
		Response.Write "</td>"
		'end of row
		Response.Write "</tr>"
		objRS.MoveNext
		wend

		End If
		objRS.Close

		Response.Write "</TABLE></TD></TR></TABLE>"
%>
<!--#include file="foot.asp"-->
