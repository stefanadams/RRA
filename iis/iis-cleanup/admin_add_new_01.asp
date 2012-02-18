<!-- #INCLUDE FILE='secure2.asp' -->

<!--#include file="head.asp"-->

<FONT face='verdana' color='#000000' size='2'>
<CENTER><H3>Add an Item to Auction</H3></CENTER>
<CENTER><FONT size='1'>Complete and submit this form to add a new item to auction.</FONT></CENTER>

<BR><BR>

<TABLE width='500' align='center' cellpadding='3' cellspacing='0'>
	<TR valign='top'>
		<TD align='center'>
			<FORM method='post' action='submitnewitem.asp' name='submitnewitemform'>
			<TABLE cellpadding='0' cellspacing='0' border='0'>
				<TR>
					<TD colspan='2' align='center'><FONT face='verdana' color='#800000' size='2'><B><U>SELLER INFORMATION</U></B></FONT><BR><BR></TD>
				</TR>
				<TR>
					<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Seller Name:</B> &nbsp;</FONT></TD>
					<TD align='left'><INPUT type='text' size='30' maxlength='30' name='sellername'></TD>
				</TR>
				<TR>
					<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Seller Phone:</B> &nbsp;</FONT></TD>
					<TD align='left'><INPUT type='text' size='30' maxlength='30' name='sellerphone'></TD>
				</TR>
				<TR>
					<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Seller E-Mail:</B> &nbsp;</FONT></TD>
					<TD align='left'><INPUT type='text' size='30' maxlength='30' name='selleremail'></TD>
				</TR>
			</TABLE>
	
			<BR>

			<TABLE cellpadding='0' cellspacing='0' border='0'>
				<TR>
					<TD colspan='2' align='center'><FONT face='verdana' color='#800000' size='2'><B><U>ITEM INFORMATION</U></B></FONT><BR><BR></TD>
				</TR>
				<TR>
					<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Item Name:</B> &nbsp;</FONT></TD>
					<TD align='left'><INPUT type='text' size='30' maxlength='30' name='name'></TD>
				</TR>
				<TR>
					<TD align='right'><FONT face='verdana' color='#000000' size='2'><B>Suggested Price:</B> &nbsp;</FONT></TD>
					<TD align='left'><INPUT type='text' size='15' maxlength='15' name='suggestedprice' value='$'></TD>
				</TR>
				<TR>
					<TD align='left' colspan='2'><INPUT type='hidden' name='priority' value='2'></TD>
				</TR>
			</TABLE>

			<BR><BR>

			<TABLE>
				<TR>
					<TD colspan='2' align='left'><FONT face='verdana' color='#000000' size='2'><B>Description of Item</B></FONT></TD>
				</TR>
				<TR>
					<TD colspan='2' align='left'><TEXTAREA name='description' cols='40' rows='6' wrap='soft'></TEXTAREA></TD>
				</TR>
			</TABLE>

			<BR>
	
			<TABLE>
				<TR>
					<TD align='middle'><INPUT type='submit' value='Add Item to Auction'></TD>
				</TR>
			</TABLE>
			</FORM>
		</TD>
	</TR>
</TABLE>
					

<!--#include virtual="/library/foot.asp"-->
