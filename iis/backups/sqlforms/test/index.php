<?php

	include(dirname(__FILE__)."/defaultLang.php");
	include(dirname(__FILE__)."/language.php");
	include(dirname(__FILE__)."/incCommon.php");
	include(dirname(__FILE__)."/header.php");

	?><link rel="stylesheet" type="text/css" href="style.css"><?php

	if($_GET['signOut']==1){
		logOutMember();
	}

	$arrTables=getTableList();

	?>
	<div align="center"><table>
		<?php if($_GET['loginFailed']==1 || $_GET['signIn']==1){ ?>
		<tr><td colspan="2" align="center">
			<?php if($_GET['loginFailed']){ ?>
			<div class="Error"><?php echo $Translation['login failed']; ?></div>
			<?php } ?>
			<form method="post" action="index.php">
				<table border="0" cellspacing="1" cellpadding="4" align="center">
					<tr>
						<td colspan="2" class="TableHeader">
							<div class="TableTitle"><?php echo $Translation['sign in here']; ?></div>
							</td>
					<tr>
						<td align="right" class="TableHeader">
							<?php echo $Translation['username']; ?>
							</td>
						<td align="left" class="TableBody">
							<input type="text" name="username" value="" size="20" class="TextBox">
							</td>
						</tr>
					<tr>
						<td align="right" class="TableHeader">
							<?php echo $Translation['password']; ?>
							</td>
						<td align="left" class="TableBody">
							<input type="password" name="password" value="" size="20"class="TextBox">
							</td>
						</tr>
					<tr>
						<td colspan="2" align="right" class="TableHeader">
							<input type="submit" name="signIn" value="<?php echo $Translation['sign in']; ?>">
							</td>
					<tr>
						<td colspan="2" align="left" class="TableHeader">
							<?php echo $Translation['go to signup']; ?>
							<br><br>
							</td>
						</tr>
					<tr>
						<td colspan="2" align="left" class="TableHeader">
							<?php echo $Translation['forgot password']; ?>
							<br><br>
							</td>
						</tr>
					<tr>
						<td colspan="2" align="left" class="TableHeader">
							<?php echo $Translation['browse as guest']; ?>
							<br><br>
							</td>
						</tr>
					</table>
				</form>
			</td></tr>
		<?php } ?>
	<?php
		if(!$_GET['signIn'] && !$_GET['loginFailed']){
			if(is_array($arrTables)){
				if(getLoggedAdmin()){
					?><tr><td><a href="admin/"><img src=table.gif border=0></a></td><td class="TableTitle"><a href="admin/" class="TableTitle" style="color: red;"><?php echo $Translation['admin area']; ?></a></td></tr><?php
				}
				foreach($arrTables as $tn=>$tc){
					?><tr><td><a href=<?php echo $tn; ?>_view.php><img src=table.gif border=0></a></td><td class="TableTitle"><a href=<?php echo $tn; ?>_view.php class="TableTitle"><?php echo $tc; ?></a></td></tr><?php
				}
			}else{
				?><tr><td><div class="Error"><?php echo $Translation['no table access']; ?></div></td></tr><?php
			}
		}
?>

</table><br><br><div class="TableFooter"><b><a href=http://www.bigprof.com/appgini/>BigProf Software</a> - <?php echo $Translation['powered by']; ?> AppGini 4.2</b></div>

</div>
</html>
