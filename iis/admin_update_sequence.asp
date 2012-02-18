<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
Response.Buffer = true
id = request("id")
oldsort = cint(request("old"))
newsort = cint(request("new"))
maxsort = cint(request("max"))
'Response.Write "oldsort = " & oldsort & "<br>"
'Response.Write "newsort = " & newsort & "<br>"
'Response.Write "maxsort = " & maxsort & "<br>"


if newsort = oldsort Then
	Response.Redirect("admin_items_view.asp?error=same_number")
Else
	if oldsort > newsort Then
		x = newsort + 1
		'renumber everything from the new number up
'		sql = "Select id From items Where status <> 'Sold' And status <> 'Bidding' And sequencenumber >= " & newsort & " Order By sequencenumber"
		sql = "Select id From items Where status = 'Ready' And sequencenumber >= " & newsort & " Order By sequencenumber"
		objRS.open sql, objConn, 3, 3
		while not objRS.eof
			sqlx = "Update items Set sequencenumber = " & x & " Where id = " & objRS("id")
'			Response.Write "Item #" & objRS("id") & " Set to " & x & ".<br>"
			objConn.execute sqlx
			x = x + 1
			objRS.movenext
		wend
		objRS.Close
		set objRS = nothing
		
		'now update the item
		sqln = "Update items Set sequencenumber = " & newsort & " Where id = " & id
		objConn.execute sqln
'		Response.Write sqln
'		Response.end		

	Else
		if newsort > maxsort then newsort = maxsort
		'change the items inbetween
		x = oldsort
		'renumber everything from the new number up
		sql = "Select id From items Where status = 'Ready' And sequencenumber > " & oldsort & " And sequencenumber <= " & newsort & " Order By sequencenumber"
		objRS.open sql, objConn, 3, 3
		while not objRS.eof
			sqlx = "Update items Set sequencenumber = " & x & " Where id = " & objRS("id")
			'Response.Write "Item #" & objRS("id") & " Set to " & x & ".<br>"
			objConn.execute sqlx
			x = x + 1
			objRS.movenext
		wend
		objRS.Close
		
		'now update the item
		sqln = "Update items Set sequencenumber = " & newsort & " Where id = " & id
		objConn.execute sqln
		

	End If
End If
objConn.close
set objConn = nothing

Response.Redirect("admin_items_view.asp?sort=s")
'<a href='admin_viewitems.asp?sort=s'>back</a>
%>
