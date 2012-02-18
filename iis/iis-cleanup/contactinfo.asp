<%
Dim DBHOST, DBPORT, DBUSER, DBPASS, DBROOTUSER, DBROOTPASS, DBYEAR, DBNIGHT
DBHOST="mysql.washingtonrotary.com"
DBPORT="3306"
DBUSER="washingtonrotary"
DBPASS="harris"
DBROOTUSER="root"
DBROOTPASS="secret"
DBYEAR="2011"
DBNIGHT="1"

Dim radiotitle, phone, radio, title
radiotitle = "KSLQ FM 104.5 / KLPW AM 1220"
radio = "KSLQ FM 104.5 / <a href='http://lightningstream.surfernetwork.com/Media/player/view/klpw4.asp?call=klpw&skin=KLPW'>KLPW AM 1220</a>"
phone = "877-707-2345"
title = "Radio Auction - " & radio & " || " & phone & ""
%>
