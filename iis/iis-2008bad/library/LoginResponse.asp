<%@ Language=VBScript %>
<%
Response.Buffer = true
%>
<!-- #include file="config.asp" -->

<!-- #include file=functions.asp -->

<%
Set objConn = Server.CreateObject("ADODB.Connection")
objConn.Open strConn

	LOGIN Request.form("UserLogin"), Request.form("Password"), Request.Form("keepme")

	if session("LoggedIn") <> "" then
		if session("ReturnURL") <> "" then
			Response.Redirect session("ReturnURL")
		else
			Response.Redirect "/membership/"
		end if
	else
%>
<!-- #include file="head.asp" -->
<br><br>
  <center>
  <table border="0">
    <tr>
      <td width="100%" align="center"><font face="Verdana"><b>We cannot find your account</b></font>
        <p><font face="Verdana">If you have forgotten your ID or<br>
        your Password, please contact the Rotary Club.</font></p>
    </tr>
  </table>
  </center>
<!-- #include file="foot.asp" -->


<%
	end if 
%>	

