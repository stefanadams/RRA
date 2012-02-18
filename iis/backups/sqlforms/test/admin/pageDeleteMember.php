<?php
	require("./incCommon.php");

	// validate input
	$memberID=makeSafe($_GET['memberID']);

	sql("delete from membership_users where memberID='$memberID'");
	sql("update membership_userrecords set memberID='' where memberID='$memberID'");

	if($_SERVER['HTTP_REFERER']){
		redirect($_SERVER['HTTP_REFERER'], TRUE);
	}else{
		redirect("pageViewMembers.php");
	}

?>