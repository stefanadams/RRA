<% If Session.Contents("status") = "Administrator" or Session.Contents("status") = "Operator" Then %>
<br><br>
<TABLE width='500' align='center' cellpadding='5' cellspacing='0' bgcolor='#F2F2E0'>

	<% If Session.Contents("status") = "Administrator" Then %>

<%
        a = "SELECT count(auctioneer) AS a FROM items WHERE (status = 'Bidding' Or status = 'Halt') And Auctioneer = 0"
        objRS.open a, objConn
        a = objRS("a")
        objRS.close
        b = "SELECT count(auctioneer) AS b FROM items WHERE (status = 'Bidding' Or status = 'Halt') And Auctioneer = 1"
        objRS.open b, objConn
        b = objRS("b")
        objRS.close
%>

	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='admin_auctioneer_a.asp'>Broadcaster A: <% Response.Write(a) %> items</A></FONT></TD>
	</TR>
	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='admin_auctioneer_b.asp'>Broadcaster B: <% Response.Write(b) %> items</A></FONT></TD>
	</TR>
	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='admin_items_view.asp'>View/Edit Current Items</A></FONT></TD>
	</TR>
	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='admin_start_auction_01.asp'>Admin - Start Auctions</A></FONT></TD>
	</TR>
	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='admin_main.asp'>Admin - Timer Functions</A></FONT></TD>
	</TR>
	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='admin_place_bid_01.asp'>Place Bids From Callers</A></FONT></TD>
	</TR>

	<% end If
	   If Session.Contents("status") = "Operator" Then %>
	   
	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='admin_place_bid_01.asp'>Place Bids From Callers</A></FONT></TD>
	</TR>
	
	<% end If %>

	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='main_current_bidding.asp'>View Auction in Progress</A></FONT></TD>
	</TR>
	<TR valign='top'>
		<TD align='center'><FONT face='verdana' color='#000000' size='2'><A class='mainlinks' href='welcome.asp'>Welcome</A></FONT></TD>
	</TR>
</TABLE>
<br>
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