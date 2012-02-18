<?php
	require("./incCommon.php");

	// get groupID of anonymous group
	$anonGroupID=sqlValue("select groupID from membership_groups where name='".$adminConfig['anonymousGroup']."'");

	// request to save changes?
	if($_POST['saveChanges']!=''){
		// validate data
		$name=makeSafe($_POST['name']);
		$description=makeSafe($_POST['description']);
		switch($_POST['visitorSignup']){
			case 0:
				$allowSignup=0;
				$needsApproval=1;
				break;
			case 2:
				$allowSignup=1;
				$needsApproval=0;
				break;
			default:
				$allowSignup=1;
				$needsApproval=1;
		}
		###############################
		$contacts_insert=checkPermissionVal('contacts_insert');
		$contacts_view=checkPermissionVal('contacts_view');
		$contacts_edit=checkPermissionVal('contacts_edit');
		$contacts_delete=checkPermissionVal('contacts_delete');
		###############################
		$rotarians_insert=checkPermissionVal('rotarians_insert');
		$rotarians_view=checkPermissionVal('rotarians_view');
		$rotarians_edit=checkPermissionVal('rotarians_edit');
		$rotarians_delete=checkPermissionVal('rotarians_delete');
		###############################
		$donations_insert=checkPermissionVal('donations_insert');
		$donations_view=checkPermissionVal('donations_view');
		$donations_edit=checkPermissionVal('donations_edit');
		$donations_delete=checkPermissionVal('donations_delete');
		###############################
		$stockitems_insert=checkPermissionVal('stockitems_insert');
		$stockitems_view=checkPermissionVal('stockitems_view');
		$stockitems_edit=checkPermissionVal('stockitems_edit');
		$stockitems_delete=checkPermissionVal('stockitems_delete');
		###############################

		// new group or old?
		if($_POST['groupID']==''){ // new group
			// make sure group name is unique
			if(sqlValue("select count(1) from membership_groups where name='$name'")){
				echo "<div class=\"error\">Error: Group name already exists. You must choose a unique group name.</div>";
				include("./incFooter.php");
			}

			// add group
			sql("insert into membership_groups set name='$name', description='$description', allowSignup='$allowSignup', needsApproval='$needsApproval'");

			// get new groupID
			$groupID=mysql_insert_id();

		}else{ // old group
			// validate groupID
			$groupID=intval($_POST['groupID']);

			if($groupID==$anonGroupID){
				$name=$adminConfig['anonymousGroup'];
				$allowSignup=0;
				$needsApproval=0;
			}

			// make sure group name is unique
			if(sqlValue("select count(1) from membership_groups where name='$name' and groupID!='$groupID'")){
				echo "<div class=\"error\">Error: Group name already exists. You must choose a unique group name.</div>";
				include("./incFooter.php");
			}

			// update group
			sql("update membership_groups set name='$name', description='$description', allowSignup='$allowSignup', needsApproval='$needsApproval' where groupID='$groupID'");

			// reset then add group permissions
			sql("delete from membership_grouppermissions where groupID='$groupID' and tableName='contacts'");
			sql("delete from membership_grouppermissions where groupID='$groupID' and tableName='rotarians'");
			sql("delete from membership_grouppermissions where groupID='$groupID' and tableName='donations'");
			sql("delete from membership_grouppermissions where groupID='$groupID' and tableName='stockitems'");
		}

		// add group permissions
		if($groupID){
			// table 'contacts'
			sql("insert into membership_grouppermissions set groupID='$groupID', tableName='contacts', allowInsert='$contacts_insert', allowView='$contacts_view', allowEdit='$contacts_edit', allowDelete='$contacts_delete'");
			// table 'rotarians'
			sql("insert into membership_grouppermissions set groupID='$groupID', tableName='rotarians', allowInsert='$rotarians_insert', allowView='$rotarians_view', allowEdit='$rotarians_edit', allowDelete='$rotarians_delete'");
			// table 'donations'
			sql("insert into membership_grouppermissions set groupID='$groupID', tableName='donations', allowInsert='$donations_insert', allowView='$donations_view', allowEdit='$donations_edit', allowDelete='$donations_delete'");
			// table 'stockitems'
			sql("insert into membership_grouppermissions set groupID='$groupID', tableName='stockitems', allowInsert='$stockitems_insert', allowView='$stockitems_view', allowEdit='$stockitems_edit', allowDelete='$stockitems_delete'");
		}

		// redirect to group editing page
		redirect("pageEditGroup.php?groupID=$groupID");

	}elseif($_GET['groupID']!=''){
		// we have an edit request for a group
		$groupID=intval($_GET['groupID']);
	}

	include("./incHeader.php");

	if($groupID!=''){
		// fetch group data to fill in the form below
		$res=sql("select * from membership_groups where groupID='$groupID'");
		if($row=mysql_fetch_assoc($res)){
			// get group data
			$name=$row['name'];
			$description=$row['description'];
			$visitorSignup=($row['allowSignup']==1 && $row['needsApproval']==1 ? 1 : ($row['allowSignup']==1 ? 2 : 0));

			// get group permissions for each table
			$res=sql("select * from membership_grouppermissions where groupID='$groupID'");
			while($row=mysql_fetch_assoc($res)){
				$tableName=$row['tableName'];
				$vIns=$tableName."_insert";
				$vUpd=$tableName."_edit";
				$vDel=$tableName."_delete";
				$vVue=$tableName."_view";
				$$vIns=$row['allowInsert'];
				$$vUpd=$row['allowEdit'];
				$$vDel=$row['allowDelete'];
				$$vVue=$row['allowView'];
			}
		}else{
			// no such group exists
			echo "<div class=\"error\">Error: Group not found!</div>";
			$groupID=0;
		}
	}
?>
<h1><?php echo ($groupID ? "Edit Group '$name'" : "Add New Group"); ?></h1>
<?php if($anonGroupID==$groupID){ ?>
	<div class="status">Attention! This is the anonymous group.</div>
<?php } ?>
<form method="post" action="pageEditGroup.php">
	<input type="hidden" name="groupID" value="<?php echo $groupID; ?>">
	<table border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td align="right" class="tdFormCaption" valign="top">
				<div class="formFieldCaption">Group name</div>
				</td>
			<td align="left" class="tdFormInput">
				<input type="text" name="name" <?php echo ($anonGroupID==$groupID ? "readonly" : ""); ?> value="<?php echo $name; ?>" size="20" class="formTextBox">
				<br>
				<?php if($anonGroupID==$groupID){ ?>
					The name of the anonymous group is read-only here.
				<?php }else{ ?>
					If you name the group '<?php echo $adminConfig['anonymousGroup']; ?>', it will be considered the anonymous group<br>
					that defines the permissions of guest visitors that do not log into the system.
				<?php } ?>
				</td>
			</tr>
		<tr>
			<td align="right" valign="top" class="tdFormCaption">
				<div class="formFieldCaption">Description</div>
				</td>
			<td align="left" class="tdFormInput">
				<textarea name="description" cols="50" rows="5" class="formTextBox"><?php echo $description; ?></textarea>
				</td>
			</tr>
		<?php if($anonGroupID!=$groupID){ ?>
		<tr>
			<td align="right" valign="top" class="tdFormCaption">
				<div class="formFieldCaption">Allow visitors to sign up?</div>
				</td>
			<td align="left" class="tdFormInput">
				<?php
					echo htmlRadioGroup(
						"visitorSignup",
						array(0, 1, 2),
						array(
							"No. Only the admin can add users.",
							"Yes, and the admin must approve them.",
							"Yes, and automatically approve them."
						),
						($groupID ? $visitorSignup : $adminConfig['defaultSignUp'])
					);
				?>
				</td>
			</tr>
		<?php } ?>
		<tr>
			<td colspan="2" align="right" class="tdFormFooter">
				<input type="submit" name="saveChanges" value="Save changes">
				</td>
			</tr>
		<tr>
			<td colspan="2" class="tdFormHeader">
				<table border="0" cellspacing="0" cellpadding="0" width="100%">
					<tr>
						<td class="tdFormHeader" colspan="5"><h2>Table permissions for this group</h2></td>
						</tr>
					<?php
						// permissions arrays common to the radio groups below
						$arrPermVal=array(0, 1, 2, 3);
						$arrPermText=array("No", "Owner", "Group", "All");
					?>
					<tr>
						<td class="tdHeader"><div class="ColCaption">Table</div></td>
						<td class="tdHeader"><div class="ColCaption">Insert</div></td>
						<td class="tdHeader"><div class="ColCaption">View</div></td>
						<td class="tdHeader"><div class="ColCaption">Edit</div></td>
						<td class="tdHeader"><div class="ColCaption">Delete</div></td>
						</tr>
				<!-- Contacts table -->
					<tr>
						<td class="tdCaptionCell" valign="top">Contacts</td>
						<td class="tdCell" valign="top">
							<input onMouseOver="stm(contacts_add, toolTipStyle);" onMouseOut="htm();" type="checkbox" name="contacts_insert" value="1" <?php echo ($contacts_insert ? "checked class=\"highlight\"" : ""); ?>>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("contacts_view", $arrPermVal, $arrPermText, $contacts_view, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("contacts_edit", $arrPermVal, $arrPermText, $contacts_edit, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("contacts_delete", $arrPermVal, $arrPermText, $contacts_delete, "highlight");
							?>
							</td>
						</tr>
				<!-- Rotarians table -->
					<tr>
						<td class="tdCaptionCell" valign="top">Rotarians</td>
						<td class="tdCell" valign="top">
							<input onMouseOver="stm(rotarians_add, toolTipStyle);" onMouseOut="htm();" type="checkbox" name="rotarians_insert" value="1" <?php echo ($rotarians_insert ? "checked class=\"highlight\"" : ""); ?>>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("rotarians_view", $arrPermVal, $arrPermText, $rotarians_view, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("rotarians_edit", $arrPermVal, $arrPermText, $rotarians_edit, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("rotarians_delete", $arrPermVal, $arrPermText, $rotarians_delete, "highlight");
							?>
							</td>
						</tr>
				<!-- Donations table -->
					<tr>
						<td class="tdCaptionCell" valign="top">Donations</td>
						<td class="tdCell" valign="top">
							<input onMouseOver="stm(donations_add, toolTipStyle);" onMouseOut="htm();" type="checkbox" name="donations_insert" value="1" <?php echo ($donations_insert ? "checked class=\"highlight\"" : ""); ?>>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("donations_view", $arrPermVal, $arrPermText, $donations_view, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("donations_edit", $arrPermVal, $arrPermText, $donations_edit, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("donations_delete", $arrPermVal, $arrPermText, $donations_delete, "highlight");
							?>
							</td>
						</tr>
				<!-- Stockitems table -->
					<tr>
						<td class="tdCaptionCell" valign="top">Stockitems</td>
						<td class="tdCell" valign="top">
							<input onMouseOver="stm(stockitems_add, toolTipStyle);" onMouseOut="htm();" type="checkbox" name="stockitems_insert" value="1" <?php echo ($stockitems_insert ? "checked class=\"highlight\"" : ""); ?>>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("stockitems_view", $arrPermVal, $arrPermText, $stockitems_view, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("stockitems_edit", $arrPermVal, $arrPermText, $stockitems_edit, "highlight");
							?>
							</td>
						<td class="tdCell">
							<?php
								echo htmlRadioGroup("stockitems_delete", $arrPermVal, $arrPermText, $stockitems_delete, "highlight");
							?>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		<tr>
			<td colspan="2" align="right" class="tdFormFooter">
				<input type="submit" name="saveChanges" value="Save changes">
				</td>
			</tr>
		</table>
</form>


<?php
	include("./incFooter.php");
?>