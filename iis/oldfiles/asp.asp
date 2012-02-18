<% 
Response.write "Hello!" & "<br />"
Dim objConn, objRS, strConn, dbpath
strConn = "Provider=SQLNCLI;Server=Symantec\sqlexpress;Network Library=DBMSSOCN;Initial Schema=washrotary;Initial Catalog=washrot;Database=washrot;UID=paul;PWD=harris;"
'strConn = "DRIVER={MySQL ODBC 3.51 Driver};SERVER=mysql.washingtonrotary.com;PORT=3306;DATABASE=washingtonrotary_auction;USER=washingtonrotary;PASSWORD=harris;OPTION=3;"
Set objConn = Server.CreateObject("ADODB.Connection")
Set objRS = Server.CreateObject("ADODB.Recordset") 
objConn.Open strConn
SQLStatement = "SELECT * FROM items"
objRS.Open SQLStatement, objConn
while not objRS.eof
Response.Write objRS("name") & "<br>"
objRS.MoveNext
wend
objRS.Close
%>