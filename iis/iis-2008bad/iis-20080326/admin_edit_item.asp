<%	'Ensure that all variables are declared
	'Option Explicit
%>
<!--#include file="head.asp"-->

<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
	'Declare SQL Statement variable
		Dim SQLStatement

	'Declare item variables
		Dim id, name, description, priority, status, suggestedprice, advertisement

	'Declare seller variables
		Dim sellername, sellerphone, selleremail

	
	'Set id variable equal to value passed by viewitems.asp querystring
		
		id = Request.QueryString("id")


	
	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to SELECT statement, open recordset and execute SELECT.
	'SELECT will pull editable information on the item that was clicked in viewitems.asp.

		SQLStatement	= "SELECT name, description, priority, status, suggestedprice, sellername, sellerphone, selleremail, advertisement FROM items WHERE id = '" & id & "'"
		objRS.Open SQLStatement, objConn




	'Set item variables equal to returned results from database.

		name		= objRS(0)
		description	= objRS(1)
		priority	= objRS(2)
		status		= objRS(3)
		suggestedprice	= objRS(4)



	'Set seller variables equal to returned results from database.

		sellername 	= objRS(5)
		sellerphone	= objRS(6)
		selleremail	= objRS(7)
		advertisement = objRS(8)


	
	'Replace all instances of description <BR /> tags with carriage-returns.
	'This ensures that carriage-returns will be duplicated when site displays
	'item description.

'		description	= Replace(description , " <BR /> ", vbCrLf )



	'Close recordset and set recordset equal to nothing.

		objRS.Close
		Set objRS	= Nothing


	
	'Display values in a nicely-formatted table with editable fields.

		Response.Write("<CENTER><FONT face='verdana' color='#000000' size='2'><H3>Edit Item</H3></FONT></CENTER><BR><BR>")

		Response.Write("<TABLE width='500' align='center' cellpadding='3' cellspacing='0'>")
		Response.Write("<TR valign='top'>")
		Response.Write("<TD align='center'>")
		Response.Write("<FORM method='post' action='admin_updateitem.asp' name='updateitemform'>")
		Response.Write("<INPUT type='hidden' name='id' value='" & id & "'>")
		Response.Write("<TABLE cellpadding='0' cellspacing='0' border='0'>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='center'><FONT face='verdana' color='#800000' size='2'><B><U>DONOR INFORMATION</U></B></FONT><BR><BR></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Donor Name:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='30' name='sellername' value='" & sellername & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Donor Phone:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='30' name='sellerphone' value='" & sellerphone & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Donor E-Mail:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='30' name='selleremail' value='" & selleremail & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Advertisement:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><textarea name='advertisement' cols='30' rows='5'>" & advertisement & "</textarea></TD>")
		Response.Write("</TR>")
		Response.Write("</TABLE>")
	
		Response.Write("<BR>")

		Response.Write("<TABLE cellpadding='0' cellspacing='0' border='0'>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='center'><FONT face='verdana' color='#800000' size='2'><B><U>ITEM INFORMATION</U></B></FONT><BR><BR></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Item Name:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='30' name='name' value='" & name & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Suggested Price:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='15' maxlength='15' name='suggestedprice' value='" & suggestedprice & "'></TD>")
		Response.Write("</TR>")
		Response.Write("</TABLE>")

		Response.Write("<BR><BR>")

		Response.Write("<TABLE>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='left'><FONT face='verdana' color='#000000' size='2'><B>Description of Item</B></FONT></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='left'><TEXTAREA name='description' cols='40' rows='6' wrap='soft'>" & description & "</TEXTAREA></TD>")
		Response.Write("</TR>")
		Response.Write("</TABLE>")

		Response.Write("<BR>")
	
		Response.Write("<TABLE>")
		Response.Write("<TR>")
		Response.Write("<TD align='middle'><INPUT type='submit' value='Update Item'></FORM></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='middle'>")
		Response.Write("<FORM method='post' action='deleteitem.asp'>")
		Response.Write("<INPUT type='hidden' name='id' value='" & id & "'>")
		Response.Write("<INPUT type='submit' value='Delete Item'>")
		Response.Write("</FORM>")
		Response.Write("</TD></TR></TABLE>")
		Response.Write("</TD>")
		Response.Write("</TR>")
		Response.Write("</TABLE>")
%>
<!--#include virtual="/library/foot.asp"-->
