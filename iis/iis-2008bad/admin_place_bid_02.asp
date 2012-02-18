<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<STYLE>
.bigButton {
	width: 35px; height: 35px;
}
</STYLE>
<%
metafresh = 999
onload = "OnLoad=""document.bidform.phone.focus();"""

		Response.Write("<TABLE><TR><TD height='40'> &nbsp; </TD></TR></TABLE>")

		SQLStatement	= "SELECT id, name, status, sellername, suggestedprice, bid FROM items WHERE id = " & request("id") & " And status = 'Bidding'"
		objRS.Open SQLStatement, objConn
		id = objRS("id")
		item = objRS("name")
		value = objRS("suggestedprice")
%>
<!--#include file="head.asp"-->
<%
		

		
		Response.Write "<TABLE bgcolor='#F2F2E0' align='center' width='95%' cellpadding='10' cellspacing='0' border='0'>"
		Response.Write "<TR bgcolor='gray'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='3'>"
		Response.Write "<B>Add Caller's Bid</B>"
		Response.Write "</TD></TR><TR><TD>"

		Response.Write "<TABLE align='center' width='100%' cellpadding='5' cellspacing='0' border='0'>"
		
		If objRS.EOF Then

		Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>Item No Longer Available</B></TD></TR>"
		
		else

		bid = objRS("bid")
		Response.Write "<tr bgcolor='#F2F2E0'>"
		Response.Write "<td valign='top' style='border-top: 1 solid #808080; border-left: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='center'>" & objRS("id") & "</td>"
		Response.Write "<td valign='top' style='border-top: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='left'>" & objRS("name") & "</td>"
		Response.Write "<td valign='top' style='border-top: 1 solid #808080; border-right: 1 solid #808080; border-bottom: 1 solid #808080' align='right'>"
		Response.Write "<b>Current Bid: <font color='red'>" & formatcurrency(objRS("bid"),2) & "</font></b></td>"
		'end of row
		Response.Write "</tr>"

		End If
		objRS.Close

		Response.Write "</TABLE></TD></TR></TABLE><br>"

		Set objRS	= Nothing
		
		Response.Write "<center>" & vbcrlf
		Response.Write "<form action='admin_place_bid_03.asp' method='post' name='bidform'>" & vbcrlf
		Response.Write "<b>Caller's Phone Number</b><br>"
		Response.Write "<font size='2'><b>(numbers only, #######):</b></font><br>"
		Response.Write "<input class='bigButton' type='radio' name='ac' value='636' checked onClick=""document.bidform.phone.focus()""> 636 <input class='bigButton'  type='radio' name='ac' value='314' onClick=""document.bidform.phone.focus()""> 314 <input class='bigButton' type='radio' name='ac' value='573' onClick=""document.bidform.phone.focus()""> 573<br>" & vbcrlf 
		Response.Write "<input type='text' name='phone' size='10'><br>" & vbcrlf
		Response.Write "<input type='hidden' name='item' value='" & item & "'>" & vbcrlf
		Response.Write "<input type='hidden' name='bid' value='" & bid & "'>" & vbcrlf
		Response.Write "<input type='hidden' name='id' value='" & id & "'>" & vbcrlf
		Response.Write "<input type='hidden' name='value' value='" & value & "'>" & vbcrlf
		Response.Write "<input type='submit' value='Go'>"
		Response.Write "</form>" & vbcrlf
		Response.Write "</center>" & vbcrlf
		
	Response.Write("</BODY></HTML>")
%>
<!--include virtual="/library/foot.asp"-->
