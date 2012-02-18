<?php
	require("./incCommon.php");
	include("./incHeader.php");
	$mailsPerBatch=5;

	$queue=makeSafe($_GET['queue']);
	$queueFile=dirname(__FILE__)."/$queue.php";
	if(!is_file($queueFile)){
		echo "<div class=\"status\">Invalid mail queue.</div>";
		include("./incFooter.php");
	}

	include($queueFile);
	$fLog=@fopen(dirname(__FILE__)."/mailLog.log", "a");
	// send a batch of up to $mailsPerBatch messages
	$i=0;
	foreach($to as $email){
		$i++;
		if(!@mail($email, $mailSubject, $mailMessage, "From: ".$adminConfig['senderName']." <".$adminConfig['senderEmail'].">")){
			@fwrite($fLog, date("d.m.Y H:i:s")." -- Sending message to '$email': Failed.\n");
		}else{
			@fwrite($fLog, date("d.m.Y H:i:s")." -- Sending message to '$email': Ok.\n");
		}
		if($i>=$mailsPerBatch){  break; }
	}
	@fclose($fLog);

	if($i<$mailsPerBatch){
		// no more emails in queue
		@unlink($queueFile);
		?>
		<h1>Done!</h1>You may close this page now or browse to some other page.
		<br><br><pre style="text-align: left;"><? echo "Mail log:\n".@implode("", @file(dirname(__FILE__)."/mailLog.log")); ?></pre>
		<?php
		@unlink(dirname(__FILE__)."/mailLog.log");
		include("./incFooter.php");
	}else{
		while($i--){ array_shift($to); }

		if(!$fp=fopen($queueFile, "w")){
			?>
			<div class="status">
				Couldn't save mail queue. Please make sure the directory '<?php echo dirname(__FILE__); ?>' is writeable (chmod 755 or chmod 777).
				</div>
			<?php
			include("./incFooter.php");
		}else{
			fwrite($fp, "<?php\n");
			foreach($to as $recip){
				fwrite($fp, "\t\$to[]='$recip';\n");
			}
			$mailSubject=addslashes(stripslashes($mailSubject));
			$mailMessage=addslashes(stripslashes($mailMessage));
			$mailMessage=str_replace("\n", "\\n", $mailMessage);
			$mailMessage=str_replace("\r", "\\r", $mailMessage);
			fwrite($fp, "\t\$mailSubject=\"$mailSubject\";\n");
			fwrite($fp, "\t\$mailMessage=\"$mailMessage\";\n");
			fwrite($fp, "?>");
			fclose($fp);
		}

		// redirect to mail queue processor
		redirect("pageSender.php?queue=$queue");
	}

	include("./incFooter.php");
?>