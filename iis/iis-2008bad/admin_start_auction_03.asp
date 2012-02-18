<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
var = request("auctioneer")
if var = "a" Then 
	newvar = 0
	else
	newvar = 1
end if


sql = "Select id From items Where Status = 'bidding' And Auctioneer = '" & newvar & "'"
set rs = server.CreateObject("adodb.recordset")
rs.Open sql,objConn,3,2
ct = rs.RecordCount
rs.Close
set rs = nothing

if ct < 8 Then

sql = "Update items Set Status = 'Bidding', bid = 0 Where id = " & Request.QueryString("id")
objConn.execute sql
objConn.close
set objConn = nothing

End If

If var = "a" then
	Response.Redirect("admin_auctioneer_a.asp")
	Else
	Response.Redirect("admin_auctioneer_b.asp")
End if
%>