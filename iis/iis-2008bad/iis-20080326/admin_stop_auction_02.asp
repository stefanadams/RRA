<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
x = request("x")
sql = "Update items Set Status = 'Halt', timeradmin = 'Halt' Where id = " & Request.QueryString("id")
objConn.execute sql
objConn.close
set objConn = nothing
if x = "a" Then
	Response.Redirect("admin_auctioneer_a.asp")
	else
	Response.Redirect("admin_auctioneer_b.asp")
end if
%>