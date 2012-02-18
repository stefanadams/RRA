<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<!--#include file="head.asp"-->
<%
		SQLStatement	= "SELECT id, name, status, sellername, suggestedprice, bid, bidderID, timer, timeradmin, advertisement, active FROM items WHERE (status = 'Bidding' Or status = 'Halt') And Auctioneer = 0 Order By SequenceNumber"
		objRS.Open SQLStatement, objConn
			
		Response.Write "<TABLE bgcolor='#F2F2E0' align='center' width='95%' cellpadding='2' cellspacing='0' border='0'>"
		Response.Write "<TR bgcolor='gray'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'>"
		Response.Write "<B>Auctioneer A - Item(s) Currently Up For Bid</B>"
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
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><font size='1'><b>Advertisement</b></font></td>"
		Response.Write "</tr>"
		
		Response.Write "<tr><td colspan='8' style='border-bottom: 1 solid #808080'><img src='images/spacer.gif' width='1' height='1'></td></tr>"
		
		while not objRS.eof
		adtext = objRS("advertisement")
		strbid = ""
		trcolor = ""
		strTimer = ""
		newbidcolor = ""
		if objRS("timer") <> 0 and objRS("timeradmin") <> "start" Then
			newtime = timer
			elapsed = newtime - objRS("timer")
			strTimer = "<font color='red'><b>" & formatnumber(elapsed/60,1) & "</b></font>"
			trcolor = "#F2F2E0"
		End If
		if objRS("timeradmin") = "start" Then
			strTimer =  "<a href='admin_start_timer_02.asp?id=" & objRS("id") & "&x=a'><font face='arial' size='1' color='green'>Start</font></a>"
			trcolor = "#F2F2E0"
		end if
		if objRS("timer") <> 0 and objRS("timeradmin") = "stop" Then
			strTimer = strTimer & "<br><a href='admin_stop_timer_02.asp?id=" & objRS("id") & "&x=b'><font face='arial' size='1' color='blue'>Stop</font></a>"
			trcolor = "#F2F2E0"
		end if
		if objRS("timeradmin") = "end" Then
			strTimer =  strTimer & "<br><a href='admin_stop_auction_02.asp?id=" & objRS("id") & "&x=a'><font face='arial' size='1' color='blue'><nobr>End Auction</nobr></font></a>"
			trcolor = "#F2F2E0"
		end if
		if objRS("bidderID") = 1 Then
			newbidcolor = "#ffeecc"
		end if
		
		
		if strTimer = "" Then strTimer = "&nbsp;"
		
		if objRS("bid") => objRS("SuggestedPrice") Then
			strbid = "<img src='images/overbid_star.gif' width='14' height='14'>&nbsp;"
			if timeleft = "" or timeleft > 60 Then trcolor = "#ffcc66"
		End If
		if objRS("timeradmin") = "Halt" Then
			strTimer =  "<a href='admin_stop_auction_03.asp?id=" & objRS("id") & "&x=a'><font face='arial' size='1' color='blue'><nobr>Clear</nobr></font></a>"
			trcolor = "#87cefa"
		end if
		
		Response.Write "<tr bgcolor='" & trcolor & "'>"
		Response.Write "<td"
			if newbidcolor <> "" Then Response.Write " bgcolor='red'"
		Response.Write " valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>"
			if newbidcolor <> "" Then Response.Write "<a href='clear_bid_notice.asp?who=a&id=" & objRS("id") & "'>"
		Response.Write objRS("id")
			if newbidcolor <> "" Then Response.Write "</a>" 
		Response.Write "</td>" & vbcrlf
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("name") & "</td>" & vbcrlf
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>" & vbcrlf
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>" & vbcrlf
			if strbid <> "" Then Response.Write strbid
		Response.Write "<b><font color='red'>" & formatcurrency(objRS("bid"),2) & "</font></b></td>" & vbcrlf
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & vbcrlf
			if objRS("active") <> 0 Then
				Response.Write "<a href=""#"" onClick=""showbids('" & objRS("id") & "');"">"
				call biddername(objRS("id"))
				Response.Write "</a>"
			Else
				Response.Write "&nbsp;-&nbsp;"
			End If
		Response.Write "</td>" & vbcrlf
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & strTimer & "</td>" & vbcrlf
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>" & objRS("sellername") & "</td>" & vbcrlf
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'>"
			if adtext <> "" Then
				Response.Write "<a href=""#"" onClick=""showpage('" & objRS("id") & "');""><font color='#000000' size='1'>" & left(adtext,50) & "...</font></a>"
				Else
				Response.Write "&nbsp;"
			End If			
		Response.Write "</td>"
		'end of row
		Response.Write "</tr>" & vbcrlf
		objRS.MoveNext
		wend

		End If
		objRS.Close

		Response.Write "</TABLE></TD></TR></TABLE>"

'-----------------
                a = "SELECT count(auctioneer) AS a FROM items WHERE (status = 'Bidding' Or status = 'Halt') And Auctioneer = 0"
                objRS.open a, objConn
                a = objRS("a")
                objRS.close

		SQLStatement	= "SELECT id, name, status, sellername, advertisement, suggestedprice, auctioneer FROM items WHERE status = 'OnDeck' And Auctioneer = 0 Order By SequenceNumber"
		objRS.Open SQLStatement, objConn
			
		Response.Write "<TABLE align='center' width='95%' cellpadding='5' cellspacing='0' border='0'>"
		
		while not objRS.eof
		
		Response.Write "<tr bgcolor='#69B559'><td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080'><font size='1'>" & objRS("name") & "</font></td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'><font size='1'>" & formatcurrency(objRS("suggestedprice"),2) & "</font></td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'><font size='1'>" & objRS("sellername") & "</font></td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080'><font size='1'>"
			if objRS("advertisement") <> "" Then
				Response.Write objRS("advertisement")
				Else
				Response.Write "&nbsp;"
			End If			
		Response.Write "</font></td>"
		'end of row
                Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080; border-right; 1 solid #808080'>"
                if CInt(a) < 8 then
                       Response.Write "<font size='1'><a href='admin_start_auction_03.asp?id=" & objRS("id") & "&auctioneer=a'>Start Now</a></font>"
                else
                       Response.Write "&nbsp;"
                end if
                Response.Write "</td>"
                Response.Write "</tr>"
		objRS.MoveNext
		wend

		objRS.Close

		Response.Write "</TABLE><br>"
%>
<!--#include file="foot.asp"-->
