<!--#include file="head.asp"-->

<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->

<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function textCounter(field, countfield, maxlimit) {
if (field.value.length > maxlimit) // if too long...trim it!
field.value = field.value.substring(0, maxlimit);
// otherwise, update 'characters left' counter
else
countfield.value = maxlimit - field.value.length;
}
function checkform (form) {
        if ( form.suggestedprice.value == "" ) {
                alert("Enter a suggested price");
                form.suggestedprice.focus();
                return false;
        }
        return true;
}
// End -->
</script>

<%
        set objRS = server.CreateObject("adodb.recordset")
        SQLStatement    = "SELECT count(id) AS max FROM items"
        objRS.Open SQLStatement, objConn, 3, 1, adcmdtext
	newseqence = cint(objRS("max")) + 1

	'Display values in a nicely-formatted table with editable fields.

		Response.Write("<CENTER><FONT face='verdana' color='#000000' size='2'><H3>Add Item</H3></FONT></CENTER><BR><BR>")

		Response.Write("<TABLE width='500' align='center' cellpadding='3' cellspacing='0'>")
		Response.Write("<TR valign='top'>")
		Response.Write("<TD align='center'>")
		Response.Write("<FORM method='post' action='admin_item_add02.asp?seq=" & newseqence & "' name='additemform' onSubmit='return checkform(this);'>")
		Response.Write("<TABLE cellpadding='0' cellspacing='0' border='0'>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='center'><FONT face='verdana' color='#800000' size='2'><B><U>DONOR INFORMATION</U></B></FONT><BR><BR></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Donor Name:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='60' name='sellername' value='" & sellername & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Donor Phone:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='30' name='sellerphone' value='" & sellerphone & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Donor E-Mail:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='60' name='selleremail' value='" & selleremail & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Advertisement:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><textarea name=advertisement wrap=physical cols=30 rows=5 onKeyDown='textCounter(this.form.advertisement,this.form.advLen,250);' onKeyUp='textCounter(this.form.advertisement,this.form.advLen,250);'>" & advertisement & "</textarea><br><input readonly type=text name=advLen size=3 maxlength=3 value='250'> characters left</td>")
		Response.Write("</TR>")
		Response.Write("</TABLE>")
	
		Response.Write("<BR>")
		'stock item
'		Response.Write("<TABLE cellpadding='0' cellspacing='0' border='0'>")
'		Response.Write("<TR>")
'		Response.Write("<TD colspan='2' align='center'><INPUT TYPE='RADIO' NAME='RADIO' VALUE='STOCK'><FONT face='verdana' color='#800000' size='2'><B><U>STOCK ITEM</U></B></FONT><BR><BR></TD>")
'		Response.Write("</TR>")
'		Response.Write("<TR>")
'		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B><nobr>Item Description:</nobr></B> &nbsp;</FONT></TD>")
'		Response.Write("<TD align='left'><select name='stockID'>" & vbcrlf)
'		
'		sql = "Select * From stockitems"
'		set objRS = server.CreateObject("adodb.recordset")
'		objRS.Open sql,objConn,3,3
'		While Not objRS.EOF
'			Response.Write "<option value=" & objRS("ID") & ">" & objRS("ItemDescription") & "</option>" & vbcrlf
'			objRS.MoveNext
'		Wend
'		objRS.Close
'		Set objRS	= Nothing
'		
'		Response.Write("</select></TD>")
'		Response.Write("</TR>")
'		Response.Write("</TABLE>")
		
		Response.Write("<BR>")
		'custom item
		Response.Write("<TABLE cellpadding='0' cellspacing='0' border='0'>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='center'><INPUT TYPE='RADIO' NAME='RADIO' VALUE='CUSTOM'><FONT face='verdana' color='#800000' size='2'><B><U>ITEM INFORMATION</U></B></FONT><BR><BR></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Item Name:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='30' maxlength='250' name='name' value='" & name & "'></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Suggested Price:</B> &nbsp;</FONT></TD>")
		Response.Write("<TD align='left'><INPUT type='text' size='15' maxlength='15' name='suggestedprice' value='" & suggestedprice & "'></TD>")
		Response.Write("</TR>")
		Response.Write("</TABLE>")

		Response.Write("<BR><BR>")

		Response.Write("<TABLE>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='left'><FONT face='verdana' color='#000000' size='2'><B>Description of Item</B></FONT></TD>")
		Response.Write("</TR>")
		Response.Write("<TR>")
		Response.Write("<TD colspan='2' align='left'><textarea name=description wrap=physical cols=40 rows=6 onKeyDown='textCounter(this.form.description,this.form.descLen,250);' onKeyUp='textCounter(this.form.description,this.form.descLen,250);'>" & description & "</textarea><br><input readonly type=text name=descLen size=3 maxlength=3 value='250'> characters left</td>")
		Response.Write("</TR>")
		Response.Write("</TABLE>")

		Response.Write("<BR>")
	
%>
<TABLE>
<TR>
<TD align='middle'>
        <INPUT type='submit' value='Enter Item'>
</TD>
</TR>
</TABLE>
</FORM>
<!--#include virtual="/library/foot.asp"-->
