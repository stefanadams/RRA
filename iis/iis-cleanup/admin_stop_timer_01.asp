<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
x = request("x")
sql = "Update items Set TimerAdmin = 'stop' Where id = " & Request.QueryString("id")
objConn.execute sql
objConn.close
set objConn = nothing
Response.Redirect("admin_main.asp")
%>