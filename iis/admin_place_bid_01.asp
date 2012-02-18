<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
metafresh = 20
if request("x") = "toolow" Then errmsg = "Bid was not high enough, please bid again."

		Response.Write("<TABLE><TR><TD height='40'> &nbsp; </TD></TR></TABLE>")

		SQLStatement	= "SELECT id, name, status, sellername, suggestedprice, bid, timer, bidderid, advertisement, active FROM items WHERE status = 'Bidding' Order By id"
		objRS.Open SQLStatement, objConn
%>
<!--#include file="head.asp"-->
<%
		

		Response.Write "<BODY>"
			
		Response.Write "<TABLE bgcolor='#F2F2E0' align='center' width='95%' cellpadding='10' cellspacing='0' border='0'>"
		Response.Write "<TR bgcolor='gray'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'>"
		Response.Write "<B>Item(s) Currently Up For Bid</B>"
		Response.Write "</TD></TR>"
		If errmsg <> "" Then
			Response.Write "<tr><td align='center'><font face='arial' size='6' color='red'>" & errmsg & "</font></td></tr>"
		end if
		Response.Write "<TR><TD>"

		Response.Write "<TABLE align='center' width='100%' cellpadding='5' cellspacing='0' border='0'>"
		
		If objRS.EOF Then

		Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>No Items Currently Up For Bid</B></TD></TR>"
		
		else

		Response.Write "<tr><td style='border-bottom: 1 solid #808080' align='center'><b>Number:</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Item Up For Bid</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Value</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Current Bid</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>High Bidder</b></td>"
		Response.Write "<td align='center' style='border-bottom: 1 solid #808080'><b>Timer</b></td>"
		Response.Write "</tr>"
		
		Response.Write "<tr><td colspan='7' style='border-bottom: 1 solid #808080'><p>&nbsp;</p></td></tr>"
		
		while not objRS.eof
		strbid = ""
		timeleft = 180
		trcolor = "#F2F2E0"
		
		if objRS("timer") <> "" Then
			newtime = timer
			elapsed = newtime - objRS("timer")
			strTimer = "<font color='red'><b>" & formatnumber(elapsed/60,1) & "</b></font>"
			trcolor = "#FFD685"
		Else
			strTimer =  "&nbsp;"
			'trcolor = "#F2F2E0"
		end if
		
		if objRS("bid") => objRS("SuggestedPrice") Then
			strbid = "<img src='images/overbid_star.gif' width='14' height='14'>&nbsp;"
			if timeleft = "" or timeleft > 60 Then trcolor = "#FFD685"
		End If
		
		Response.Write "<tr bgcolor='" & trcolor & "'>"
		Response.Write "<td valign='top' style='border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'><a href='admin_place_bid_02.asp?id=" & objRS("id") & "'>" & objRS("id") & "</a></td>"
		Response.Write "<td valign='top' style='border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='left'>" & objRS("name") & "</td>"
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
		'end of row
		Response.Write "</tr>"
		objRS.MoveNext
		wend

		End If
		objRS.Close

		Response.Write "</TABLE></TD></TR></TABLE><br>"
%>
<!--#include file="foot.asp"-->
