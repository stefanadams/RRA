<%	'Ensure that all variables are declared
	'Option Explicit
	Response.Buffer = true
%>
<!--#include file="head.asp"-->

<!-- #INCLUDE FILE='connect.asp' -->

<%
	'Declare SQL Statement
		Dim SQLStatement
	
	'Declare all other variables
		Dim usernameEntered, passwordEntered
		Dim username, password, status

	'Initialize appropriate variabes
		usernameEntered		= Request.Form("username")
		passwordEntered		= Request.Form("password")



	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to SELECT statement, open recordset and execute SELECT.
	'SELECT will pull item that is currently up for bid.

		set objRS = server.CreateObject("adodb.recordset")
		SQLStatement	= "SELECT username, password, status " & _
				  "FROM memberslogin WHERE username = '" & usernameEntered & "' " & _
				  "AND password = '" & passwordEntered & "'"
		objRS.Open SQLStatement, objConn


	If objRS.EOF <> True Then

		'Set variables equal to appropriate values
		
		username	= objRS(0)
		password	= objRS(1)
		status		= objRS(2)

		Session("username") = username
		Session("status")	= status

		Response.Redirect("welcome.asp")

	else
		Response.Redirect("main_current_bidding.asp")
	End If




	'Close recordset and set recordset equal to nothing
		
		objRS.Close
		Set objRS	= Nothing
%>
<!--#include virtual="/library/foot.asp"-->
