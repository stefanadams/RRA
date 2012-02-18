<%
DIM DBHOST, DBPORT, DBUSER, DBPASS, DBROOTUSER, DBROOTPASS, DBYEAR, DBNIGHT
DBHOST="mysql.washingtonrotary.com"
DBPORT="3306"
DBUSER="washingtonrotary"
DBPASS="harris"
DBROOTUSER="root"
DBROOTPASS="secret"
DBYEAR="2012"
DBNIGHT="1"

DIM radiotitle, phone, radio, title
radiotitle = "KFAV FM 99.9 / KLPW AM 1220"
radio = "KFAV FM 99.9 / <a href='http://lightningstream.surfernetwork.com/Media/player/view/klpw4.asp?call=klpw&skin=KLPW'>KLPW AM 1220</a>"
phone = "877-707-2345"
title = "Radio Auction - " & radio & " || " & phone & ""
%>
