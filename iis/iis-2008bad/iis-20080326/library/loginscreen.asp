<%@LANGUAGE=VBScript %>
<!-- #include virtual="/library/config.asp" -->
<!-- #include file="functions.asp" -->
<%
regID = Request.Cookies("regID")
'Response.Write(regID)
If regID <> "" Then
	getuserinfo(regID)
End If
regUserName = session("regUserName")

%>
<!-- #include file="head.asp" -->
<br><br>
<form action="LoginResponse.asp" method="post" name="MyForm">
<div align="center">
  <center>
<blockquote><font face="verdana" size="2"><b>Please enter your user id and password to access the members only features.</b></font></blockquote><br>

<table border="1" cellpadding="0" cellspacing="0" width="75%" bordercolorlight="#000000">
<tr>
<td bgcolor="#F5B428" align="center">
            <p><font face="Verdana" color="#FFFFFF"><b>Rotarian Login</b></font></p>
</td>
</tr>
<tr>
<td>
<table border="0" cellpadding="0" cellspacing="0" width="100%" height="111">
    <tr>
        <td valign="top" align="right" width="45%" bgcolor="#FFF7D2" height="25"> 
            <font face="Verdana" size="2">UserID:</font>
        </td>
        <td valign="top" align="left" width="55%" bgcolor="#FFF7D2" height="25"> 
            <font face="Verdana"><input size="20" name="UserLogin" value="<%= regUserName %>"></font>
        </td>
    </tr>
    <tr>
        <td valign="top" align="right" width="45%" bgcolor="#FFF7D2" height="23"> 
            <font face="Verdana" size="2">Password:</font>
        </td>
        <td valign="top" align="left" width="55%" bgcolor="#FFF7D2" height="23"> 
            <font face="Verdana"><input type="password" size="20" name="Password"></font>
        </td>
    </tr>
    <tr>
        <td valign="top" align="center" colspan="2" bgcolor="#FFF7D2" height="18">
			<input type="checkbox" name="keepme" value="indeed">&nbsp; 
            <font face="Verdana" size="2">Keep me logged in on this computer.</font>
        </td>
    </tr>
    <tr>
        <td valign="top" align="center" colspan="2" bgcolor="#FFF7D2" height="27"> 
            <font face="Verdana"><input type="submit" name="B1" value="Log in"></font>
        </td>
    </tr>
</table>
</td>
</tr>
</table>

  </center>
</div>

</form>
<!-- #include file="foot.asp" -->
