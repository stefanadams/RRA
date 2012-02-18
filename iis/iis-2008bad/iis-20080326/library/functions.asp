<%
SUB LOGIN(sUserName,sPassword,sKeepmeLogged)
	sSQL = ""
	sSQL = sSQL & " SELECT crotarianid, cfirstname, nuserlevel, userid, cuserpw FROM rotarian WHERE cusername = '" & sUserName & "' AND cuserpw = '" & sPassword & "'"
	'Response.Write sSql
	Set objrs = objConn.Execute(sSQL)

	if not objrs.eof then
		session("rotarianID") = objrs.Fields("userid")
		session("LoggedIn") = "yes"
		session("username") = sUserName
		session("secLevel") = objrs.fields("nuserlevel")
		If sKeepmeLogged = "indeed" Then
			Response.Cookies("login") = "indeed"
			Response.Cookies("login").Expires = DateAdd("m",3,Now()) '3 months to expire
			Response.Cookies("rotarianID") = objrs.Fields("crotarianid").value
			Response.Cookies("rotarianID").Expires = DateAdd("m",3,Now()) '3 months to expire
			Response.Cookies("username") = session("username")
			Response.Cookies("username").Expires = DateAdd("m",3,Now()) '3 months to expire
			Response.Cookies("secLevel") = objrs.Fields("cuserlevel").value
			Response.Cookies("secLevel").Expires = DateAdd("m",3,Now()) '3 months to expire
		End If
	else
		session("Member_Login") = ""
	end if
	objrs.Close
	objconn.Close
	set objrs = nothing
	set objconn = nothing
END SUB



sub DisplaySessionContents()
	Dim sessitem
	For Each sessitem in Session.Contents  
	Response.write(sessitem & " : " & Session.Contents(sessitem) & "<BR>")
	Next 	
end sub

%>
