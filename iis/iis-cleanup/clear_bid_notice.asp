<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
itemid = request("id")
who = request("who")

sql = "Update items Set BidderID = 0 Where id = " & itemid
objConn.execute sql
	
objConn.close
set objConn = nothing
Response.Redirect("admin_auctioneer_" & who & ".asp")
%>