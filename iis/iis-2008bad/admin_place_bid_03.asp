<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<%
metafresh = 999
item = request("item")
value = request("value")
id = request("id")
bid = request("bid")
phone = replace(request("ac") & request("phone"),"-","")

		Response.Write("<TABLE><TR><TD height='40'> &nbsp; </TD></TR></TABLE>")

		SQLStatement	= "SELECT * FROM bidders WHERE Phone = '" & phone & "'"
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
			onload = "OnLoad=""document.bidform.bid.focus();"""
		Else
			found	= 0
			onload = "OnLoad=""document.bidform.name.focus();"""
		End If
		objRS.close
		set objRS = nothing
%>
<!--#include file="head.asp"-->
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
//
function checkform (form, bid, value) {
        if ( form.bid.value == "" || form.bid.value <= bid ) {
                alert("Your bid must be greater than the current bid");
                form.bid.focus();
                return false;
        }
        if ( form.bid.value < value ) {
                if ( form.bid.value % 5 != 0 ) {
                        if ( form.bid.value < value ) {
                                alert("Until the retail value is reached, only $5 increments are accepted.");
                                form.bid.focus();
                                return false;
                        }
                }
        }
        return true;
}
// End -->
</script> 

<body>
<form action='admin_place_bid_04.asp' method='post' name='bidform' onSubmit='return checkform(this, <%=bid%>, <%=value%>);'>
<div align="center">
  <center>
  <table border="0" cellspacing="0" cellpadding="2">
    <tr>
      <td align="right">Item ID:</td>
      <td><b><%=id%></b></td>
    </tr>
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
				Response.Write "<input type='text' size='25' name='name'>"
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
				Response.Write "<input type='text' size='25' name='address'>"
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
				Response.Write "<input type='text' size='25' name='city'>"
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
				Response.Write "<input type='text' size='2' name='state'>"
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
				Response.Write "<input type='text' size='25' name='zip'>"
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
				Response.Write "<input type='text' size='25' name='email'>"
			End If
			%>
      </td>
    </tr>
    <tr>
      <td align="right">Auction Tracking:</td>
      <td>
		<input type="radio" name='tracking' value="R"> Radio &nbsp; 
		<input type="radio" name='tracking' value="C"> Cable &nbsp; 
		<input type="radio" name='tracking' value="I"> Internet &nbsp; 
		<input type="radio" name='tracking' value="O"> Other 
      </td>
    </tr>
    <tr>
      <td align="right">Phone:</td>
      <td><b><%=phone%></b></td>
    </tr>
    <tr>
      <td align="right">Current Bid: </td>
      <td><%=formatcurrency(bid,2)%></td>
    </tr>
    <tr>
      <td align="right">Amount To Bid: $</td>
      <td><input type="text" size="6" name='bid'></td>
    </tr>
    <tr>
      <td align="right"></td>
      <td><input type="hidden" name='phone' value="<%=phone%>">
      <input type="hidden" name='bidderid' value="<%=bidderid%>">
      <input type="hidden" name='id' value="<%=id%>">
      <input type="hidden" name='found' value="<%=found%>">
      <input type="hidden" name='value' value="<%=value%>">
      <input type="hidden" name='item' value="<%=item%>">
      <input type="submit" value="Submit" style="background-color: #993366; color: #FFFFFF" id=submit1 name=submit1></td>
    </tr>
  </table>
  </center>
</div>


</form>
<!--include virtual="/library/foot.asp"-->
