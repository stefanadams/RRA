<%	'Ensure that all variables are declared
	Option Explicit
%>

<!-- #INCLUDE FILE='connect.asp' -->
<!-- INCLUDE FILE='secure.asp' -->
<!--#include virtual="/library/head.asp"-->

<%
	'Declare SQL Statement variable
		Dim SQLStatement

	'Declare all currently-up-for-bid variables
		Dim id, name, description, priority, status
		Dim suggestedprice, startingprice, currentbid
		Dim sellername, sequencenumber, StrOrder

	'Declare all other variables
		Dim soldprice, iterator, purchasername

	'Initialize appropriate variables
		iterator 	= 0

		Const adOpenKeyset = 1
		Const adLockReadOnly = 1


		SQLStatement	= "SELECT id, name, priority, " & _
				  "status, sellername, sequencenumber, suggestedprice " & _
				  "FROM items WHERE status = 'Ready'"
				  
if Request.QueryString("order") = "" then
		StrOrder = "name"
	Else
		StrOrder = Request.QueryString("order")
End if
		SQLStatement = SQLStatement & " ORDER BY " & StrOrder		  

		objRS.Open SQLStatement, objConn, adOpenKeyset, adLockReadOnly

	Dim TotalRows, PageSize, TotalPages, pageNo, PageNumber, ColorChange, HowMany, rowcolor, value


	TotalRows = objRS.RecordCount 
	objRS.PageSize = 30
	PageSize = objRS.PageSize 
	TotalPages=objRS.PageCount
	
	select case Request("move")
		case "first" pageNo = 1  '  First
		case "prev" pageNo = cint(Session("page_num")) - 1  '  Next
		case "next" pageNo = cint(Session("page_num")) + 1  '  Previous
		case "last" pageNo = TotalPages  '  Last
		case Else PageNo = 1
	End Select
	
	if cint(PageNo) < 1 then PageNo = 1
	if cint(PageNo) > TotalPages then pageNo = TotalPages
	
	objRS.AbsolutePage = PageNo
	PageNumber=PageNo
	Session("page_num") = PageNo
	
		Response.Write("<TABLE width='600' align='center' cellpadding='5' cellspacing='0' border='0'><TR><TD height='25' width='250'> &nbsp; </TD>")
		Response.Write("<TD height='25' width='100' bgcolor='#9AB1CA'> &nbsp; </TD>")
		Response.Write("<TD height='25' width='250'> &nbsp; </TD>")
		Response.Write("</TR></TABLE>")
		Response.Write("<TABLE width='600' align='center' cellpadding='2' cellspacing='0' border='0'>")
		Response.Write("<TR valign='top'><TD> &nbsp; </TD>")
		Response.Write("<TD align='center' width='200' bgcolor='#3D5353'><FONT face='verdana' color='#FFFFFF' size='2'>")
		Response.Write("<B>Radio Auction List</B></TD>")
		Response.Write("<TD> &nbsp; </TD></TR>")
		Response.Write("</TABLE>")

		Response.Write("<TABLE width='98%' align='center' bgcolor='#000000' cellpadding='1' cellspacing='0' border='0'>")
		Response.Write("<TR><TD>")

		Response.Write("<TABLE align='center' width='100%' cellpadding='7' cellspacing='0' border='0' bgcolor='#CDDBDB'>")
		Response.Write("<TR><TD>")

		Response.Write("<TABLE bgcolor='#CDDBDB' width='100%' align='center' cellpadding='4' cellspacing='0' border='0'>")
		Response.Write("<TR><TD width='60%'><a href='main_itemlist.asp?order=name'><FONT face='verdana' color='#134373' size='2'><B><U>Item</U></B></FONT></a></TD>")
		Response.Write("<TD width='30%'><a href='main_itemlist.asp?order=sellername'><FONT face='verdana' color='#134373' size='2'><B><U>Provided By</U></B></FONT></a></TD>")
		Response.Write("<TD width='10%'><a href='main_itemlist.asp?order=suggestedprice'><FONT face='verdana' color='#134373' size='2'><B><U>Value</U></B></FONT></a></TD>")
		Response.Write("</TR>")

	

	colorchange = TRUE
	HowMany = 0
	Do until objRS.EOF or HowMany => PageSize 
	 
	If colorchange = TRUE then
		rowcolor = "#C4D1D1"
		colorchange = False
	Else rowcolor = "#CDDBDB"
		colorchange = TRUE
	End If 
		value = cint(objRS("suggestedprice"))
		
		Response.Write "<tr bgcolor =" & chr(34) & rowcolor & chr(34) & ">"	
		Response.Write "<td><font face=""verdana"" size=""2"">" & objRS("name")  & "</font></td>"
		Response.Write "<td><font face=""verdana"" size=""2"">" & objRS("sellername") & "</font></a></td>"
		Response.Write "<td><font face=""verdana"" size=""2"">" & formatcurrency(value,2) & "</font></a></td>"
		Response.Write "</tr>"
		objRS.MoveNext
		howmany = howmany + 1
	loop
	Response.Write "</table>"


	Response.Write "<p align=center><a href='main_itemlist.asp?move=first&order="& StrOrder &"'><FONT face='verdana' color='#134373' size='2'><B>First</b></font></a>&nbsp;&nbsp;"
	Response.Write "<a href='main_itemlist.asp?move=prev&order="& StrOrder &"'><FONT face='verdana' color='#134373' size='2'><B>Previous</b></font></a>&nbsp;&nbsp;"
	Response.Write "<a href='main_itemlist.asp?move=next&order="& StrOrder &"'><FONT face='verdana' color='#134373' size='2'><B>Next</b></font></a>&nbsp;&nbsp;"
	Response.Write "<a href='main_itemlist.asp?move=last&order="& StrOrder &"'><FONT face='verdana' color='#134373' size='2'><B>Last</b></font></a><br><br>"

	objRS.close
	set objRS = nothing

	If PageNumber < 1 Then
	Response.Write "<p align='center'><font face='verdana' size='1'>Page 1</font></p>"
	TotalPages = 1
	Else
	Response.Write "<p align='center'><font face='verdana' size='1'>Page " & PageNumber & " of " &  TotalPages & "</FONT></p>"
	End If



%>
<!--#include virtual="/library/foot.asp"-->
