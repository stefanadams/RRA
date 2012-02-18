<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<!--#include file="headn.asp"-->
<%
	id = Request("id")
	old = request("sq")
	SQLStatement = "SELECT count(id) AS max FROM items"
	objRS.Open SQLStatement, objConn, 3, 1, adcmdtext
	max = objRS("max")
%>
<br>
<center>
<form action='admin_update_sequence.asp' method='post'>
Current Auction Order For This Item: <%=old%>.<br>
Highest Item Number: <%=max%>.<br>
New Auction Order For This Item:<br>
<input type="text" name="new" size="3">
<input type="hidden" name="old" value="<%=old%>">
<input type="hidden" name="id" value="<%=id%>">
<input type="hidden" name="max" value="<%=max%>">
<input type="submit" value="Change Order">
</form>
</center>
</body>
</html>
