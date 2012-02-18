<%
'   Response.Buffer = True
   If Session("status") <> "Administrator" And Session("status") <> "Operator" Then
      	Response.Redirect "admin.asp"
   End If
%>