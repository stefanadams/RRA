<%
Dim objConn, objRS, strConn, dbpath
strConn = "DRIVER={MySQL ODBC 3.51 Driver};SERVER=mysql.washingtonrotary.com;PORT=3306;DATABASE=washrotary_" + DB_YEAR + ";USER=washingtonrotary;PASSWORD=harris;"

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRS = Server.CreateObject("ADODB.Recordset") 
objConn.Open strConn

Sub Connect
	strConn = "DRIVER={MySQL ODBC 3.51 Driver};SERVER=mysql.washingtonrotary.com;PORT=3306;DATABASE=washrotary_" + DB_YEAR + ";USER=washingtonrotary;PASSWORD=harris;"
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRS = Server.CreateObject("ADODB.Recordset") 
	objConn.Open strConn
end Sub
sub biddername(id)
	bsql = "SELECT bidders.Name FROM bidders INNER JOIN bidhistory ON bidders.BidderID = bidhistory.BidderID INNER JOIN items ON bidhistory.ItemID = items.id WHERE items.id = " & id & " Order By bidhistory.Amount Desc"
	set rs = objConn.execute(bsql)
	Response.Write rs("Name")
	rs.close
	set rs = nothing
end sub
dim metafresh
metafresh = 10
%>
