<!--#include file="head.asp"-->

<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
newseqence = request("seq")
	
	If request("radio") = "STOCK" Then
		set RS = server.CreateObject("adodb.recordset")
		sql = "Select * From stockitems Where ID = " & request("stockID")
		RS.Open sql,objConn,3,3,adCmdText
		Name = rs("Name")
		Description = rs("itemdescription")
		status = "Ready"
		suggestedprice = rs("suggestedvalue")
		rs.Close
		set rs = nothing
	Else
		name 		= Replace(Request.Form("name"), "'", "''")
		description	= Replace(Request.Form("description"), "'", "''")
		status		= "Ready"
		suggestedprice	= Replace(Request.Form("suggestedprice"), "'", "''")
	End If

	'Set seller variables equal to appropriate values

		sellername	= Replace(Request.Form("sellername"), "'", "''")
		sellerphone	= Replace(Request.Form("sellerphone"), "'", "''")
		selleremail	= Replace(Request.Form("selleremail"), "'", "''")
		advertisement	= Replace(Request.Form("advertisement"), "'", "''")



	'Replace all instances of description carriage-return with <BR /> tag in database.
	'This ensures that carriage-returns will be duplicated when site displays
	'item description.

		description	= Replace(description , vbCrLf , " </BR> " )


	

	'Connection information has been provided by the connect.asp include file.
	'Set SQLStatement equal to UPDATE statement, open recordset and execute UPDATE.
	'UPDATE will update item and seller values of selected item in the database.

		SQLStatement = "Insert Into items (name,description,status,suggestedprice,sellername,sellerphone,sequencenumber"
		if selleremail <> "" Then
			SQLStatement = SQLStatement & ",selleremail"
		end if
		if advertisement <> "" Then
			SQLStatement = SQLStatement & ",advertisement"
		end if
		SQLStatement = SQLStatement & ") values ("
		SQLStatement = SQLStatement & "'" & name & "','" & description & "','Ready'," & suggestedprice & ",'" & sellername & "','" & sellerphone & "'," & newseqence
		if selleremail <> "" Then
			SQLStatement = SQLStatement & ",'" & selleremail & "'"
		end if
		if advertisement <> "" Then
			SQLStatement = SQLStatement & ",'" & advertisement & "'"
		end if
		SQLStatement = SQLStatement & ")"
'		Response.Write SQLStatement
		objConn.execute SQLStatement
		


objConn.close

	

		Response.Redirect("admin_items_view.asp")
%>
<!--#include virtual="/library/foot.asp"-->
