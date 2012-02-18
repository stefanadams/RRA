<!--#include file="head.asp"-->

<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
	'Set item variables equal to appropriate values

		id		= Request.Form("id")
		name 		= Replace(Request.Form("name"), "'", "''")
		description	= Replace(Request.Form("description"), "'", "''")
		status		= "Ready"
		suggestedprice	= Replace(Request.Form("suggestedprice"), "'", "''")


	'Set seller variables equal to appropriate values

		sellername	= Replace(Request.Form("sellername"), "'", "''")
		sellerphone	= Replace(Request.Form("sellerphone"), "'", "''")
		selleremail	= Replace(Request.Form("selleremail"), "'", "''")
		advertisement	= Replace(Request.Form("advertisement"), "'", "''")



	'Replace all instances of description carriage-return with <BR /> tag in database.
	'This ensures that carriage-returns will be duplicated when site displays
	'item description.

		description	= Replace(description , vbCrLf , " <BR /> " )


	

	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to UPDATE statement, open recordset and execute UPDATE.
	'UPDATE will update item and seller values of selected item in the database.

		SQLStatement 	= "UPDATE items SET name='" & name & _
				  "', description = '" & description & _
				  "', status = '" & status & _
				  "', suggestedprice = '" & suggestedprice & _
				  "', sellername = '" & sellername & _
				  "', sellerphone = '" & sellerphone & _
				  "', selleremail = '" & selleremail & _
				  "', advertisement = '" & advertisement & _
				  "' WHERE id = '" & id & "'"
		objRS.Open SQLStatement, objConn



	
	'Set recordset equal to nothing.
		
		Set objRS 	= Nothing


	'Redirect user to appropriate page.

		Response.Redirect("admin_items_view.asp")
%>
<!--#include virtual="/library/foot.asp"-->
