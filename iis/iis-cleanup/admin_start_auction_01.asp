<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<!--#include file="head.asp"-->
<%

                a = "SELECT count(auctioneer) AS a FROM items WHERE (status = 'Bidding' Or status = 'Halt') And Auctioneer = 0"
                objRS.open a, objConn
                a = objRS("a")
                objRS.close
                b = "SELECT count(auctioneer) AS b FROM items WHERE (status = 'Bidding' Or status = 'Halt') And Auctioneer = 1"
                objRS.open b, objConn
                b = objRS("b")
                objRS.close

		SQLStatement	= "SELECT id, name, sellername, suggestedprice, priority, status, sequencenumber FROM items WHERE status = 'Ready' ORDER BY sequencenumber"
		objRS.maxrecords = 10
		objRS.Open SQLStatement, objConn
		
		Response.Write "<br><TABLE bgcolor='#F2F2E0' align='center' width='95%' cellpadding='2' cellspacing='0' border='0'>"
		Response.Write "<TR bgcolor='gray'><TD align='center' valign='middle'><FONT face='verdana' color='#FFFFFF' size='2'>"
		Response.Write "<B>Item(s) Next Up For Bid</B>"
		Response.Write "</TD></TR><TR><TD>"

		Response.Write "<TABLE align='center' width='100%' cellpadding='3' cellspacing='0' border='0'>"
		
		If objRS.EOF Then

		Response.Write "<TR><TD align='center'><FONT face='verdana' color='#000000' size='2'><B>No New Items Available</B></TD></TR>"
		
		else

		Response.Write "<tr>"
                Response.Write "<td style='border-bottom: 1 solid #c0c0c0'><b>ID</b></td>"
                Response.Write "<td style='border-bottom: 1 solid #c0c0c0'><b>Next Item Up For Bid</b></td>"
                Response.Write "<td style='border-bottom: 1 solid #c0c0c0'><b>Donor Name</b></td>"
                Response.Write "<td style='border-bottom: 1 solid #c0c0c0' align='right'><b>Value</b></td>"
'               Response.Write "<td style='border-bottom: 1 solid #c0c0c0' align='center'><b>Starting Bid</b></td>"
                Response.Write "<td style='border-bottom: 1 solid #c0c0c0' align='center' colspan='2'><b>Start</b></td>"
		Response.Write "</tr>"
'		Response.Write "<tr><td style='border-bottom: 1 solid #c0c0c0' colspan='7'><p>&nbsp;</p></td></tr>"
		
                while not objRS.eof
                Response.Write "<tr>"
                Response.Write "<td valign='top' style='border-left: 1 solid #c0c0c0; border-bottom: 1 solid #c0c0c0' align='center'>" & objRS("id") & "</td>"
                Response.Write "<td valign='middle' style='border-left: 1 solid #c0c0c0; border-bottom: 1 solid #c0c0c0'>" & objRS("name") & "</td>"
                Response.Write "<td valign='middle' style='border-left: 1 solid #c0c0c0; border-bottom: 1 solid #c0c0c0'>" & objRS("sellername") & "</td>"
                Response.Write "<td align='right' valign='middle' style='border-left: 1 solid #c0c0c0; border-bottom: 1 solid #c0c0c0'>" & formatcurrency(objRS("suggestedprice"),2) & "</td>"
'               Response.Write "<td align='center' valign='middle' style='border-left: 1 solid #c0c0c0; border-bottom: 1 solid #c0c0c0; border-right: 1 solid #c0c0c0'>"
                Response.Write "<td align='center' valign='middle' style='border-left: 1 solid #c0c0c0; border-bottom: 1 solid #c0c0c0;'>"
                Response.Write "<a href='admin_start_auction_02.asp?id=" & objRS("id") & "&auctioneer=0'><img src='images/notify_a.gif' border='0'></a>"
                Response.Write "</td>"
                Response.Write "<td align='center' valign='middle' style='border-bottom: 1 solid #c0c0c0; border-right: 1 solid #c0c0c0'>"
                Response.Write "<a href='admin_start_auction_02.asp?id=" & objRS("id") & "&auctioneer=1'><img src='images/notify_b.gif' border='0'></a>"
                Response.Write "</td>"
                Response.Write "</tr>"
                objRS.MoveNext
                wend

                End If
                Response.Write "</table>"
                Response.Write "</td></tr></table>"

                objRS.close
%>
<!--#include file="foot.asp"-->
