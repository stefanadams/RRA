<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
sql = "Update items Set Timer = " & timer & " Where id = " & Request.QueryString("id")
objConn.execute sql
objConn.close
set objConn = nothing
Response.Redirect("admin_currently_bidding.asp")
%>