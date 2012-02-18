<!--include file="config.asp"-->
<!--#include file="head.asp"-->

<FONT face='verdana' color='#000000' size='2'>
<CENTER><H3>Auction Login</H3></CENTER>

<TABLE bgcolor='#F2F2E0' width='500' align='center' cellpadding='10' cellspacing='0'>
	<TR valign='top'>
		<TD>
			<FORM method='post' action='login.asp'>

			<BR>
			
			<TABLE align='center' width='450' bgcolor='#F2F2E0' cellpadding='0' cellspacing='0' border='0'>
			<TR valign='top'>
				<TD valign='middle' align='right'>
					<FONT face='verdana' color='#000000' size='2'>
					<B>Username: &nbsp; </B>
				</TD>
				<TD>
					<INPUT type='text' name='username' size='20' maxlength='20'>
				</TD>
			</TR>
			<TR valign='top'>
				<TD valign='middle' align='right'>
					<FONT face='verdana' color='#000000' size='2'>
					<B>Password: &nbsp; </B>
				</TD>
				<TD>
					<INPUT type='password' name='password' size='20' maxlength='20'>
				</TD>
			</TR>
			<TR valign='top'>
				<TD height='30'>
					&nbsp;
				</TD>
			</TR>
			<TR valign='top'>
				<TD colspan='2' align='center'>
					<INPUT type='submit' value='Login Now'>
				</TD>
			</TR>
			</TABLE>

			</FORM>
					
		</TD>
	</TR>
</TABLE>

</FONT>

<!--#include virtual="/library/foot.asp"-->
