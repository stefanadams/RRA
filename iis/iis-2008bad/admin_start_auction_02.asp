<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
giveto = request("auctioneer")
'Response.Write giveto
sql = "Update items Set Status = 'OnDeck', Auctioneer = " & giveto & " Where id = " & Request.QueryString("id")
objConn.execute sql
objConn.close
set objConn = nothing
Response.Redirect("admin_start_auction_01.asp")
%>