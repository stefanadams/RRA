<%	'Ensure that all variables are declared
	Option Explicit
%>
<!--#include file="head.asp"-->

<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
	'Declare SQL Statement Variable
		Dim SQLStatement

	'Declare Item Variables
		Dim name, description, priority, status, suggestedprice

	'Declare Seller Variables
		Dim sellername, sellerphone, selleremail

	
	'Set item variables equal to appropriate values

		name 		= Replace(Request.Form("name"), "'", "''")
		description	= Replace(Request.Form("description"), "'", "''")
		priority	= Request.Form("priority")
		status		= "Ready"
		suggestedprice	= Replace(Request.Form("suggestedprice"), "'", "''")


	'Set seller variables equal to appropriate values

		sellername	= Replace(Request.Form("sellername"), "'", "''")
		sellerphone	= Replace(Request.Form("sellerphone"), "'", "''")
		selleremail	= Replace(Request.Form("selleremail"), "'", "''")



	'Replace all instances of description carriage-return with <BR /> tag in database.
	'This ensures that carriage-returns will be duplicated when site displays
	'item description.

		description	= Replace(description , vbCrLf , " <BR /> " )


	

	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to INSERT statement, open recordset and execute INSERT.
	'INSERT will insert item and seller values into the AUCTION database.

		SQLStatement 	= "INSERT INTO items (name, description, priority, status, suggestedprice, sellername, sellerphone, selleremail, sequencenumber) VALUES ('" & name & "', '" & description & "', '" & priority & "', '" & status & "', '" & suggestedprice & "', '" & sellername & "', '" & sellerphone & "', '" & selleremail & "', 'N/A')"
		objRS.Open SQLStatement, objConn



	'Set recordset equal to nothing.

		Set objRS = Nothing




	'Redirect user to appropriate page
	
		Response.Redirect("welcome.asp")
		
%>
	
		
<!--#include virtual="/library/foot.asp"-->
