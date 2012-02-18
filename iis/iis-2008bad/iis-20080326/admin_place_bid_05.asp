<%@ Language=VBScript %>
<!-- #INCLUDE FILE='connect.asp' -->
<!-- #INCLUDE FILE='secure2.asp' -->
<%
itemid = request("id")
bidderid = request("bidderid")
found = request("found")
bid = cint(request("bid"))
strerr = ""

strsql = "select status from items where id = " & itemid
set check = server.CreateObject("adodb.recordset")
check.Open strsql,objConn,3,3
checkstatus = check("status")
check.Close

strsql = "SELECT max(bidhistory.Amount) as bidmax FROM bidhistory Where ItemID = " & itemid
check.Open strsql
if check("bidmax") <> "" Then
	maxbid = check("bidmax")
	else
	maxbid = 0
end if
check.Close
set check = nothing


if checkstatus = "Bidding" Then
	If found <> 1 Then

		sql1 = "Insert Into bidders (Name,Phone"
		sql2 = "'" & request("name") & "','" & request("phone") & "'"
		
	'	dim aryList(4)
		aryList = Array("address","city","state","zip","email","tracking")
		for i = 0 to ubound(aryList)
			if request(aryList(i)) <> "" Then
				sql1 = sql1 & "," & aryList(i)
				sql2 = sql2 & ",'" & request(aryList(i)) & "'"
			End If
		Next
		sql = sql1 & ") Values (" & sql2 & ")"
	'	Response.Write sql
	'	Response.end
		objConn.execute sql
		
		rs = "Select BidderID From bidders Where Phone = '" & request("phone") & "'"
		objRS.open rs, objConn
		bidderID = objRS("BidderID")
		objRS.close
		set objRS = nothing
		
		
	End If

	If bid > cint(maxbid) Then

		sql = "Insert Into bidhistory (BidderID,ItemID,Amount,bhTimeStamp) Values (" & bidderid & "," & itemid & "," & bid & ", NULL)"
		objConn.execute sql
		
		sql = "Update items Set Timer = 0, BidderID = 1, Active = 1, bhTimeStamp = NULL, Bid = " & bid & " Where id = " & itemid
		objConn.execute sql


		sql = "Select Active, timer From items Where id = " & itemid
		'lock the set so another person does not step on this transaction
		set rs = server.CreateObject("ADODB.Recordset")
		rs.Open sql,objConn,2,3
				
			if rs("timer") <> "" Then
				rs("timer") = timer
				rs.update
			end if
				
		rs.close
		set rs = nothing
	Else
		strerr = "toolow"

	End If
End If	

	
objConn.close
set objConn = nothing
Response.Redirect("admin_place_bid_01.asp?x=" & strerr)
%>