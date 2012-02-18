<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<!--#include file="headn.asp"-->
<%
	Dim SQLStatement
	Dim id, name, sellername, n, s

	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to SELECT statement, open recordset and execute SELECT.
	'SELECT will pull all items from the auctions database that have not yet been sold.
	
	set objRS = server.CreateObject("adodb.recordset")
'	SQLStatement = "SELECT id, name, sellername, sequencenumber FROM items WHERE status <> 'Complete' And status <> 'Bidding'"
	SQLStatement = "SELECT id, name, sellername, sequencenumber FROM items WHERE status = 'Ready'"
	Select Case Request("sort")
	case "s" SQLStatement = SQLStatement & " Order By sequencenumber"
	case "n" SQLStatement = SQLStatement & " Order By Name"
	case "d" SQLStatement = SQLStatement & " Order By sellername"
	case else SQLStatement = SQLStatement & " Order By sequencenumber"
	End Select
	objRS.Open SQLStatement, objConn, 3, 1, adcmdtext

	'Display results in a nicely-formatted table.
	Response.Write "<br><center>"
	Response.Write "<a href='admin_item_add.asp'><font face='verdana' size='4' color='#000000'>Add New Item</font></a><br>"
	Response.Write "</center>"

	Response.Write("<CENTER><br><FONT face='verdana' color='#000000' size='2'><H3>View/Edit Items Available For Sale</H3></FONT></CENTER><BR>")

	Response.Write("<TABLE align='center' cellpadding='3' cellspacing='0' border='0'>")
	Response.Write("<TR><TD align='left'><FONT face='verdana' color='#000000' size='2'>")
	Response.Write "<B><U><a href='admin_items_view.asp?sort=n'>Item</a></U></B></TD>"
	Response.Write "<TD align='left'><FONT face='verdana' color='#000000' size='2'>"
	Response.Write "<B><U><a href='admin_items_view.asp?sort=d'>Donor</a></U></B></TD>"
	Response.Write "<TD align='left'><FONT face='verdana' color='#000000' size='2'>"
	Response.Write "<B><U><a href='admin_items_view.asp?sort=s'>Order</a></U></B></TD></TR>"

	Do While objRS.EOF <> True
		id = objRS("id")
		name = objRS("name")
		sellername = objRS("sellername")
		order = objRS("sequencenumber")
		Response.Write "<TR>"
		Response.Write "<TD align='left'><FONT face='verdana' color='#000000' size='2'><a class='item' href='admin_item_edit.asp?id=" & id & "'>" & id & ": " & name & "</A></TD>"
		Response.Write "<TD align='left'><FONT face='verdana' color='#000000' size='2'>" & sellername & "</TD>"
		Response.Write "<TD align='right'><FONT face='verdana' color='#000000' size='2'><a class='item' href='admin_edit_order.asp?id=" & id & "&sq=" & order & "'>" & order & "</A></TD>"
		Response.Write "</TR>"
		objRS.MoveNext
	Loop
	Response.Write("</TABLE>")
	objRS.Close
%>

<!--#include file="foot.asp"-->
