<%	'Ensure that all variables are declared
	Option Explicit
%>

<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
	'Declare SQL Statement variable
		Dim SQLStatement

	'Declare all other variables
		Dim id, priority

	'Initialize appropriate variables
		id		= Request.Form("id")
		priority	= Request.Form("priorityoptions")


	
	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to UPDATE statement, open recordset and execute UPDATE.
	'UPDATE will update administrative item information (i.e. item priority).

		SQLStatement	= "UPDATE items SET priority = '" & priority & "' WHERE id = '" & id & "'"
		objRS.Open SQLStatement, objConn


	'Set recordset equal to Nothing

		Set objRS	= Nothing


	'Redirect user to appropriate page

		Response.Redirect("currentauctionadmin.asp")
%>