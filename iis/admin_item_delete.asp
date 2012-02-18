<%	'Ensure that all variables are declared
	Option Explicit
%>

<!-- #INCLUDE FILE='connect.asp' -->

<%
	'Declare SQL Statement Variable
		Dim SQLStatement

	'Declare all other variables
		Dim id

	

	'Set values for variables.
		id = Request.Form("id")




	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to UPDATE statement, open recordset and execute UPDATE.
	'UPDATE will update item and seller values of selected item in the database.

		SQLStatement 	= "DELETE items WHERE id = '" & id & "'"
		objRS.Open SQLStatement, objConn



	
	'Set recordset equal to nothing.
		
		Set objRS 	= Nothing


	'Redirect user to appropriate page.

		Response.Redirect("admin_items_view.asp")
%>