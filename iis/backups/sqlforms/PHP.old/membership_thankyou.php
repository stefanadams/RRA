<?php
	include(dirname(__FILE__)."/defaultLang.php");
	include(dirname(__FILE__)."/language.php");
	include(dirname(__FILE__)."/lib.php");
	include(dirname(__FILE__)."/header.php");
?>
<link rel="stylesheet" type="text/css" href="style.css">

<center>
	<div style="width: 500px; text-align: left;">
		<h1 class="TableTitle"><?php echo $Translation['thanks']; ?></h1>

		<img src="handshake.jpg"><br><br>
		<div class="TableBody">
			<?php echo $Translation['sign in no approval']; ?>
			</div><br>
		<div class="TableBody">
			<?php echo $Translation['sign in wait approval']; ?>
			</div>
		</div>
	</center>
<?php include(dirname(__FILE__)."/footer.php"); ?>
