<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
		Response.Write("<TABLE><TR><TD height='40'> &nbsp; </TD></TR></TABLE>")

		SQLStatement	= "SELECT id, name, status, sellername, suggestedprice, bid, timer, advertisement, active FROM items WHERE status = 'Bidding' Order By SequenceNumber"
		objRS.Open SQLStatement, objConn
%>
<!--#include file="head.asp"-->
<%
		

		Response.Write "<BODY>"
			
		Response.Write "<TABLE bgcolor='#F2F2E0' align='center' width='95%' cellpadding='10' cellspacing='0' border='0'>"
		Response.Write "<TR bgcolor='gray'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'>"
		Response.Write "<B>Item(s) Currently Up For Bid</B>"
		Response.Write "</TD></TR><TR><TD>"

		Response.Write "<TABLE align='center' width='100%' cellpadding='5' cellspacing='0' border='0'>"
		
		If objRS.EOF Then

		Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>No Items Currently Up For Bid</B></TD></TR>"
		
		else

		Response.Write "<tr><td style='border-bottom: 1 solid #808080'><b>Item Up For Bid</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Value</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Current Bid</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>High Bidder</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Timer</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Donor Name</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Advertisement</b></td>"
		Response.Write "</tr>"
		
		Response.Write "<tr><td colspan='7' style='border-bottom: 1 solid #808080'><p>&nbsp;</p></td></tr>"
		
		while not objRS.eof
		strbid = ""
		timeleft = 180
		
		if objRS("timer") <> "" Then
			newtime = timer
			elapsed = newtime - objRS("timer")
			timeleft = 180 - elapsed
			If timeleft > 60 Then
				strTimer = "<font color='red'><b>" & formatnumber(timeleft/60,1) & "</b></font>"
				trcolor = "#F2F2E0"
			End If
			If timeleft > 0 And timeleft <= 60 Then
				strTimer = "<font color='red'><b>" & formatnumber(timeleft/60,1) & "</b></font>"
				trcolor = "#ff99cc"
			End If
			if timeleft <= 0 And timeleft > -60 Then
				strTimer = "<font color='red'><b>End Of Auction</b></font>"
				trcolor = "#c0c0c0"
			End if
			if timeleft < -30 Then 'remove from recordset
				strTimer = "<font color='red'><b>End Of Auction</b></font>"
				trcolor = "#c0c0c0"
				endsql = "Update items Set status = 'Sold' Where id = " & objRS("id")
				objConn.execute endsql
			End If
		Else
			strTimer =  "<a href='admin_start_timer.asp?id=" & objRS("id") & "'><font face='arial' size='1' color='#000000'>Start Timer</font></a>"
			trcolor = "#F2F2E0"
		end if
		
		if objRS("bid") > objRS("SuggestedPrice") Then
			strbid = "<img src='overbid_star.gif' width='14' height='14'>&nbsp;"
			if timeleft = "" or timeleft > 60 Then trcolor = "#ffcc66"
		End If
		
		Response.Write "<tr bgcolor='" & trcolor & "'><td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("name") & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>"
			if strbid <> "" Then Response.Write strbid
		Response.Write "<b><font color='red'>" & formatcurrency(objRS("bid"),2) & "</font></b></td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>"
			if objRS("active") <> 0 Then
				call biddername(objRS("id"))
			Else
				Response.Write "No Bids"
			End If
		Response.Write "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & strTimer & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("sellername") & "</td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>"
			if objRS("advertisement") <> "" Then
				Response.Write objRS("advertisement")
				Else
				Response.Write "&nbsp;"
			End If			
		Response.Write "</td>"
		'end of row
		Response.Write "</tr>"
		objRS.MoveNext
		wend

		End If
		objRS.Close

		Response.Write "</TABLE></TD></TR></TABLE><br>"


		










'----------------
		SQLStatement	= "SELECT id, name, sellername, suggestedprice, priority, status, sequencenumber FROM items WHERE status = 'Ready' ORDER BY priority, sequencenumber"
		objRS.maxrecords = 10
		objRS.Open SQLStatement, objConn
		
		Response.Write "<TABLE bgcolor='#F2F2E0' align='center' width='95%' cellpadding='10' cellspacing='0' border='0'>"
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
		Response.Write "<td><b>Value</b></td>"
		Response.Write "<td align='center'><b>Starting Bid</b></td>"
		Response.Write "<td><b>Start</b></td>"
		Response.Write "</tr>"
		Response.Write "<tr><td colspan='5'><p>&nbsp;</p></td></tr>"
		
		while not objRS.eof
		Response.Write "<tr>"
		Response.Write "<td valign='top'>" & objRS("name") & "</td>"
		Response.Write "<td valign='top'>" & objRS("sellername") & "</td>"
		Response.Write "<td valign='top'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
		Response.Write "<td valign='top' align='center'>"
			Response.Write "<form method='post' action='admin_start_auction.asp?id=" & objRS("id") & "'>"
			Response.Write "<input type='text' name='startbid' size='5'>"
		Response.Write "</td>"
		Response.Write "<td valign='top'>"
			Response.Write "<input type='submit' value='Start'>"
			Response.Write "</form>"
		Response.Write "</td>"
		Response.Write "</tr>"
		objRS.MoveNext
		wend

		End If
		Response.Write "</table>"
		Response.Write "</td></tr></table>"

                objRS.close
%>
<!--#include file="foot.asp"-->
