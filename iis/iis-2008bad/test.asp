<!--#INCLUDE FILE='connect.asp' -->
<%
        SQLStatement = "SELECT * FROM items ORDER BY id"
        objRS.Open SQLStatement, objConn
        If objRS.EOF Then
                Response.Write "No Items!<br />"
        else
                while not objRS.eof
			Response.Write objRS("name") & " / " & objRS("description") & " / " & objRS("suggestedprice") & "<br />"
'			Response.Write "-> " & objRS("iD") & "<br />"
                        objRS.MoveNext
                wend
        End If
        objRS.Close
        Response.Write "That's all!<br />"
%>
