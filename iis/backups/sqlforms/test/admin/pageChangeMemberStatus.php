<?php
	require("./incCommon.php");

	// validate input
	$memberID=makeSafe($_GET['memberID']);
	$unban=($_GET['unban']==1 ? 1 : 0);
	$approve=($_GET['approve']==1 ? 1 : 0);
	$ban=($_GET['ban']==1 ? 1 : 0);

	if($unban){
		sql("update membership_users set isBanned=0 where memberID='$memberID'");
	}

	if($approve){
		sql("update membership_users set isBanned=0, isApproved=1 where memberID='$memberID'");
		notifyMemberApproval($memberID);
	}

	if($ban){
		sql("update membership_users set isBanned=1, isApproved=1 where memberID='$memberID'");
	}

	if($_SERVER['HTTP_REFERER']){
		redirect($_SERVER['HTTP_REFERER'], TRUE);
	}else{
		redirect("pageViewMembers.php");
	}

?>