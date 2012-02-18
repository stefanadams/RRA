<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
metafresh = 999
item = request("item")
value = request("value")
id = request("id")
phone = request("phone")

		Response.Write("<TABLE><TR><TD height='40'> &nbsp; </TD></TR></TABLE>")

		SQLStatement	= "SELECT * FROM Bidders WHERE Phone = '" & phone & "'"
		objRS.Open SQLStatement, objConn
		if not objRS.eof Then
			bidderid= objRS("BidderID")
			name	= objRS("Name")
			address	= objRS("Address")
			city	= objRS("City")
			state	= objRS("State")
			zip		= objRS("Zip")
			email	= objRS("email")
			found	= 1
		Else
			found	= 0
		End If
		objRS.close
		set objRS = nothing
%>
<!--#include file="head.asp"-->

<body>
<form action='admin_place_bid_05.asp' method='post' name='bidform'>
<div align="center"><font face='arial' size='6' color='red'>Please Verify This Is Correct</font>
  <center>
  <table border="0" cellspacing="0" cellpadding="2">
    <tr>
      <td align="right">Item To Bid:</td>
      <td><b><%=item%></b></td>
    </tr>
    <tr>
      <td align="right">Item Value:</td>
      <td><b><%=formatcurrency(value,2)%></b></td>
    </tr>
    <tr>
      <td align="right">Bidder's Name:</td>
      <td>
			<%
			if found = 1 Then
				Response.Write name
			Else
				Response.Write request("name")
				Response.Write "<input type='hidden' size='25' name='name' value='" & request("name") & "'>"
			End If
			%>
			</td>
    </tr>
    <tr>
      <td align="right">Address:</td>
      <td>
			<%
			if found = 1 Then
				Response.Write address
			Else
				Response.Write request("address")
				Response.Write "<input type='hidden' size='25' name='address' value='" & request("address") & "'>"
			End If
			%>
      </td>
    </tr>
    <tr>
      <td align="right">City:</td>
      <td>
			<%
			if found = 1 Then
				Response.Write city
			Else
				Response.Write request("city")
				Response.Write "<input type='hidden' size='25' name='city' value='" & request("city") & "'>"
			End If
			%>
      </td>
    </tr>
    <tr>
      <td align="right">State:</td>
      <td>
			<%
			if found = 1 Then
				Response.Write state
			Else
				Response.Write request("state")
				Response.Write "<input type='hidden' size='2' name='state' value='" & request("state") & "'>"
			End If
			%>
      </td>
    </tr>
    <tr>
      <td align="right">Zip:</td>
      <td>
			<%
			if found = 1 Then
				Response.Write zip
			Else
				Response.Write request("zip")
				Response.Write "<input type='hidden' size='25' name='zip' value='" & request("zip") & "'>"
			End If
			%>
      </td>
    </tr>
    <tr>
      <td align="right">Last Name:</td>
      <td>
			<%
			if found = 1 Then
				Response.Write email
			Else
				Response.Write request("email")
				Response.Write "<input type='hidden' size='25' name='email' value='" & request("email") & "'>"
			End If
			%>
      </td>
    </tr>
    <tr>
      <td align="right">Phone:</td>
      <td><b><%=phone%></b></td>
    </tr>
    <tr>
      <td align="right">Amount To Bid: $</td>
      <td><b><font color='red' size='4'><%=formatcurrency(request("bid"),2)%></font></b><input type="hidden" size="6" name='bid' value='<%=request("bid")%>'></td>
    </tr>
    <tr>
      <td align="right"></td>
      <td><input type="hidden" name='phone' value="<%=phone%>">
      <input type="hidden" name='bidderid' value="<%=bidderid%>">
      <input type="hidden" name='id' value="<%=id%>">
      <input type="hidden" name='found' value="<%=found%>">
      <input type="hidden" name='tracking' value="<%=request("tracking")%>">
      <input type="submit" value="Submit" style="background-color: #993366; color: #FFFFFF" id=submit1 name=submit1>
      <br><br><br>
      <input type="button" value="Cancel" style="background-color: #993366; color: #FFFFFF" id=submit1 name=submit1 OnClick="javascript:history.back(-1);">
      </td>
    </tr>
  </table>
  </center>
</div>


</form>
<!--include virtual="/library/foot.asp"-->
