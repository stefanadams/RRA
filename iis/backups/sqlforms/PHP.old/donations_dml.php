<?php

// Data functions for table donations

// This script and data application were generated by AppGini 4.2 on 1/15/2009 at 3:25:27 AM
// Download AppGini for free from http://www.bigprof.com/appgini/download/

function insert(){
	global $HTTP_SERVER_VARS, $HTTP_GET_VARS, $HTTP_POST_VARS, $HTTP_POST_FILES, $Translation;

	if($HTTP_GET_VARS['insert_x']){$HTTP_POST_VARS=$HTTP_GET_VARS;}

	// mm: can member insert record?
	$arrPerm=getTablePermissions('donations');
	if(!$arrPerm[1]){
		return 0;
	}

	$donation_year = makeSafe($HTTP_POST_VARS["donation_year"]);
	$donation_item = makeSafe($HTTP_POST_VARS["donation_item"]);
	$donation_description = makeSafe($HTTP_POST_VARS["donation_description"]);
	$donation_msrp = makeSafe($HTTP_POST_VARS["donation_msrp"]);
	$donation_more_url = makeSafe($HTTP_POST_VARS["donation_more_url"]);
	$donation_more_text = makeSafe($HTTP_POST_VARS["donation_more_text"]);
	$contact_id = makeSafe($HTTP_POST_VARS["contact_id"]);
	$stockitem_id = makeSafe($HTTP_POST_VARS["stockitem_id"]);
	if($donation_year== ""){
		echo StyleSheet() . "\n\n<div class=Error>" . $Translation["error:"] . " 'Auction Year': " . $Translation['field not null'] . "</div>";
		exit;
	}

	sql("insert into donations (donation_year, donation_item, donation_description, donation_msrp, donation_more_url, donation_more_text, contact_id, stockitem_id) values (" . (($donation_year != "") ? "'$donation_year'" : "NULL") . ", " . (($donation_item != "") ? "'$donation_item'" : "NULL") . ", " . (($donation_description != "") ? "'$donation_description'" : "NULL") . ", " . (($donation_msrp != "") ? "'$donation_msrp'" : "NULL") . ", " . (($donation_more_url != "") ? "'$donation_more_url'" : "NULL") . ", " . (($donation_more_text != "") ? "'$donation_more_text'" : "NULL") . ", " . (($contact_id != "") ? "'$contact_id'" : "NULL") . ", " . (($stockitem_id != "") ? "'$stockitem_id'" : "NULL") . ")");
	// mm: save ownership data
	$recID=mysql_insert_id();
	sql("insert into membership_userrecords set tableName='donations', pkValue='$recID', memberID='".getLoggedMemberID()."', dateAdded='".time()."', dateUpdated='".time()."', groupID='".getLoggedGroupID()."'");

	return (get_magic_quotes_gpc() ? stripslashes($recID) : $recID);
}

function delete($selected_id, $AllowDeleteOfParents=false, $SkipChecks=false){
	// insure referential integrity ...
	global $Translation;


	// mm: can member delete record?
	$arrPerm=getTablePermissions('donations');
	$ownerGroupID=sqlValue("select groupID from membership_userrecords where tableName='donations' and pkValue='".makeSafe($selected_id)."'");
	$ownerMemberID=sqlValue("select memberID from membership_userrecords where tableName='donations' and pkValue='".makeSafe($selected_id)."'");
	if(($arrPerm[4]==1 && $ownerMemberID==getLoggedMemberID()) || ($arrPerm[4]==2 && $ownerGroupID==getLoggedGroupID()) || $arrPerm[4]==3){ // allow delete?
		// delete allowed, so continue ...
	}else{
		return FALSE;
	}


	sql("delete from donations where id='".makeSafe($selected_id)."'");

	// mm: delete ownership data
	sql("delete from membership_userrecords where tableName='donations' and pkValue='".makeSafe($selected_id)."'");
}

function update($selected_id){
	global $HTTP_SERVER_VARS, $HTTP_GET_VARS, $HTTP_POST_VARS, $Translation;

	if($HTTP_GET_VARS['update_x']){$HTTP_POST_VARS=$HTTP_GET_VARS;}

	// mm: can member edit record?
	$arrPerm=getTablePermissions('donations');
	$ownerGroupID=sqlValue("select groupID from membership_userrecords where tableName='donations' and pkValue='".makeSafe($selected_id)."'");
	$ownerMemberID=sqlValue("select memberID from membership_userrecords where tableName='donations' and pkValue='".makeSafe($selected_id)."'");
	if(($arrPerm[3]==1 && $ownerMemberID==getLoggedMemberID()) || ($arrPerm[3]==2 && $ownerGroupID==getLoggedGroupID()) || $arrPerm[3]==3){ // allow update?
		// update allowed, so continue ...
	}else{
		return;
	}

	if(get_magic_quotes_gpc()){
		$donation_year = $HTTP_POST_VARS["donation_year"];
		$donation_item = $HTTP_POST_VARS["donation_item"];
		$donation_description = $HTTP_POST_VARS["donation_description"];
		$donation_msrp = $HTTP_POST_VARS["donation_msrp"];
		$donation_more_url = $HTTP_POST_VARS["donation_more_url"];
		$donation_more_text = $HTTP_POST_VARS["donation_more_text"];
		$contact_id = $HTTP_POST_VARS["contact_id"];
		$stockitem_id = $HTTP_POST_VARS["stockitem_id"];
	}else{
		$donation_year = addslashes($HTTP_POST_VARS["donation_year"]);
		$donation_item = addslashes($HTTP_POST_VARS["donation_item"]);
		$donation_description = addslashes($HTTP_POST_VARS["donation_description"]);
		$donation_msrp = addslashes($HTTP_POST_VARS["donation_msrp"]);
		$donation_more_url = addslashes($HTTP_POST_VARS["donation_more_url"]);
		$donation_more_text = addslashes($HTTP_POST_VARS["donation_more_text"]);
		$contact_id = addslashes($HTTP_POST_VARS["contact_id"]);
		$stockitem_id = addslashes($HTTP_POST_VARS["stockitem_id"]);
	}

	sql("update donations set " . "donation_year=" . (($donation_year != "") ? "'$donation_year'" : "NULL") . ", " . "donation_item=" . (($donation_item != "") ? "'$donation_item'" : "NULL") . ", " . "donation_description=" . (($donation_description != "") ? "'$donation_description'" : "NULL") . ", " . "donation_msrp=" . (($donation_msrp != "") ? "'$donation_msrp'" : "NULL") . ", " . "donation_more_url=" . (($donation_more_url != "") ? "'$donation_more_url'" : "NULL") . ", " . "donation_more_text=" . (($donation_more_text != "") ? "'$donation_more_text'" : "NULL") . ", " . "contact_id=" . (($contact_id != "") ? "'$contact_id'" : "NULL") . ", " . "stockitem_id=" . (($stockitem_id != "") ? "'$stockitem_id'" : "NULL") . " where id='".makeSafe($selected_id)."'");

	// mm: update ownership data
	sql("update membership_userrecords set dateUpdated='".time()."' where tableName='donations' and pkValue='".makeSafe($selected_id)."'");

}

function form($selected_id = "", $AllowUpdate = 1, $AllowInsert = 1, $AllowDelete = 1, $ShowCancel = 0){
	// function to return an editable form for a table records
	// and fill it with data of record whose ID is $selected_id. If $selected_id
	// is empty, an empty form is shown, with only an 'Add New'
	// button displayed.

	global $Translation;


	// mm: get table permissions
	$arrPerm=getTablePermissions('donations');
	if(!$arrPerm[1] && $selected_id==""){ return ""; }
	// combobox: contact_id
	$combo_contact_id = new DataCombo;
	$combo_contact_id->Query = "select id, concat(contact_name, '::', id) from contacts order by 2";
	$combo_contact_id->SelectName = "contact_id";
	// combobox: stockitem_id
	$combo_stockitem_id = new DataCombo;
	$combo_stockitem_id->Query = "select id, concat(stockitem_name, '::', id) from stockitems order by 2";
	$combo_stockitem_id->SelectName = "stockitem_id";

	if($selected_id){
		// mm: check member permissions
		if(!$arrPerm[2]){
			return "";
		}
		// mm: who is the owner?
		$ownerGroupID=sqlValue("select groupID from membership_userrecords where tableName='donations' and pkValue='".makeSafe($selected_id)."'");
		$ownerMemberID=sqlValue("select memberID from membership_userrecords where tableName='donations' and pkValue='".makeSafe($selected_id)."'");
		if($arrPerm[2]==1 && getLoggedMemberID()!=$ownerMemberID){
			return "";
		}
		if($arrPerm[2]==2 && getLoggedGroupID()!=$ownerGroupID){
			return "";
		}

		$res = sql("select * from donations where id='".makeSafe($selected_id)."'");
		$row = mysql_fetch_array($res);
		$combo_contact_id->SelectedData = $row["contact_id"];
		$combo_stockitem_id->SelectedData = $row["stockitem_id"];
	}else{
		$combo_contact_id->SelectedData = ( $_REQUEST['FilterField'][1]=='donations.contact_id' && $_REQUEST['FilterOperator'][1]=='<=>' ? (get_magic_quotes_gpc() ? stripslashes($_REQUEST['FilterValue'][1]) : $_REQUEST['FilterValue'][1]) : "");
		$combo_stockitem_id->SelectedData = ( $_REQUEST['FilterField'][1]=='donations.stockitem_id' && $_REQUEST['FilterOperator'][1]=='<=>' ? (get_magic_quotes_gpc() ? stripslashes($_REQUEST['FilterValue'][1]) : $_REQUEST['FilterValue'][1]) : "");
	}
	$combo_contact_id->Render();
	$combo_stockitem_id->Render();

	// code for template based detail view forms

	// open the detail view template
	$templateCode=@implode('', @file('./donations_templateDV.html'));

	// process form title
	$templateCode=str_replace('<%%DETAIL_VIEW_TITLE%%>', 'Detail View', $templateCode);
	// process buttons
	if($arrPerm[1]){ // allow insert?
		$templateCode=str_replace('<%%INSERT_BUTTON%%>', "<input type=image src=insert.gif name=insert alt='" . $Translation['add new record'] . "'>", $templateCode);
	}else{
		$templateCode=str_replace('<%%INSERT_BUTTON%%>', '', $templateCode);
	}
	if($selected_id){
		if(($arrPerm[3]==1 && $ownerMemberID==getLoggedMemberID()) || ($arrPerm[3]==2 && $ownerGroupID==getLoggedGroupID()) || $arrPerm[3]==3){ // allow update?
			$templateCode=str_replace('<%%UPDATE_BUTTON%%>', "<input type=image src=update.gif vspace=1 name=update alt='" . $Translation["update record"] . "'>", $templateCode);
		}else{
			$templateCode=str_replace('<%%UPDATE_BUTTON%%>', '', $templateCode);

			// set records to read only if user can't insert new records
			if(!$arrPerm[1]){
				$jsReadOnly.="\n\n\tif(document.getElementsByName('id').length){ document.getElementsByName('id')[0].readOnly=true; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('donation_year').length){ document.getElementsByName('donation_year')[0].readOnly=true; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('donation_item').length){ document.getElementsByName('donation_item')[0].readOnly=true; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('donation_description').length){ document.getElementsByName('donation_description')[0].readOnly=true; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('donation_msrp').length){ document.getElementsByName('donation_msrp')[0].readOnly=true; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('donation_more_url').length){ document.getElementsByName('donation_more_url')[0].readOnly=true; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('donation_more_text').length){ document.getElementsByName('donation_more_text')[0].readOnly=true; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('contact_id').length){ var contact_id=document.getElementsByName('contact_id')[0]; contact_id.disabled=true; contact_id.style.backgroundColor='white'; contact_id.style.color='black'; }\n";
				$jsReadOnly.="\n\n\tif(document.getElementsByName('stockitem_id').length){ var stockitem_id=document.getElementsByName('stockitem_id')[0]; stockitem_id.disabled=true; stockitem_id.style.backgroundColor='white'; stockitem_id.style.color='black'; }\n";

				$noUploads=true;
			}
		}
		if(($arrPerm[4]==1 && $ownerMemberID==getLoggedMemberID()) || ($arrPerm[4]==2 && $ownerGroupID==getLoggedGroupID()) || $arrPerm[4]==3){ // allow delete?
			$templateCode=str_replace('<%%DELETE_BUTTON%%>', "<input type=image src=delete.gif vspace=1 name=delete alt='" . $Translation['delete record'] . "' onClick=\"return confirm('" . $Translation['are you sure?'] . "');\">", $templateCode);
		}else{
			$templateCode=str_replace('<%%DELETE_BUTTON%%>', '', $templateCode);
		}
		$templateCode=str_replace('<%%DESELECT_BUTTON%%>', "<input type=image src=deselect.gif vspace=1 name=deselect alt='" . $Translation['deselect record'] . "'>", $templateCode);
	}else{
		$templateCode=str_replace('<%%UPDATE_BUTTON%%>', '', $templateCode);
		$templateCode=str_replace('<%%DELETE_BUTTON%%>', '', $templateCode);
		$templateCode=str_replace('<%%DESELECT_BUTTON%%>', ($ShowCancel ? "<input type=image src=cancel.gif vspace=1 name=deselect alt='" . $Translation['deselect record'] . "'>" : ''), $templateCode);
	}

	// process combos
	$templateCode=str_replace('<%%COMBO(contact_id)%%>', $combo_contact_id->HTML, $templateCode);
	$templateCode=str_replace('<%%COMBOTEXT(contact_id)%%>', $combo_contact_id->MatchText, $templateCode);
	$templateCode=str_replace('<%%COMBO(stockitem_id)%%>', $combo_stockitem_id->HTML, $templateCode);
	$templateCode=str_replace('<%%COMBOTEXT(stockitem_id)%%>', $combo_stockitem_id->MatchText, $templateCode);

	// process foreign key links
	if($selected_id){
		$templateCode=str_replace('<%%PLINK(contact_id)%%>', ($combo_contact_id->SelectedData ? "<span id=contacts_plink style=\"visibility: hidden;\"><a href=contacts_view.php?SelectedID=".$combo_contact_id->SelectedData."><img border=0 src=lookup.gif></a></span>" : ''), $templateCode);
		$templateCode=str_replace('<%%PLINK(stockitem_id)%%>', ($combo_stockitem_id->SelectedData ? "<span id=stockitems_plink style=\"visibility: hidden;\"><a href=stockitems_view.php?SelectedID=".$combo_stockitem_id->SelectedData."><img border=0 src=lookup.gif></a></span>" : ''), $templateCode);
	}

	// process images
	$templateCode=str_replace('<%%UPLOADFILE(id)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(donation_year)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(donation_item)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(donation_description)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(donation_msrp)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(donation_more_url)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(donation_more_text)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(contact_id)%%>', '', $templateCode);
	$templateCode=str_replace('<%%UPLOADFILE(stockitem_id)%%>', '', $templateCode);

	// process values
	if($selected_id){
		$templateCode=str_replace('<%%VALUE(id)%%>', htmlspecialchars($row['id'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_year)%%>', htmlspecialchars($row['donation_year'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_item)%%>', htmlspecialchars($row['donation_item'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_description)%%>', htmlspecialchars($row['donation_description'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_msrp)%%>', htmlspecialchars($row['donation_msrp'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_more_url)%%>', htmlspecialchars($row['donation_more_url'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_more_text)%%>', htmlspecialchars($row['donation_more_text'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(contact_id)%%>', htmlspecialchars($row['contact_id'], ENT_QUOTES), $templateCode);
		$templateCode=str_replace('<%%VALUE(stockitem_id)%%>', htmlspecialchars($row['stockitem_id'], ENT_QUOTES), $templateCode);
	}else{
		$templateCode=str_replace('<%%VALUE(id)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_year)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_item)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_description)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_msrp)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_more_url)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(donation_more_text)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(contact_id)%%>', '', $templateCode);
		$templateCode=str_replace('<%%VALUE(stockitem_id)%%>', '', $templateCode);
	}

	// process translations
	foreach($Translation as $symbol=>$trans){
		$templateCode=str_replace("<%%TRANSLATION($symbol)%%>", $trans, $templateCode);
	}

	// clear scrap
	$templateCode=str_replace('<%%', '<!--', $templateCode);
	$templateCode=str_replace('%%>', '-->', $templateCode);
	// hide links to inaccessible tables
	$templateCode.="\n\n<script>\n";
	$arrTables=getTableList();
	foreach($arrTables as $name=>$caption){
		$templateCode.="\tif(document.getElementById('".$name."_link')!=undefined){\n";
		$templateCode.="\t\tdocument.getElementById('".$name."_link').style.visibility='visible';\n";
		$templateCode.="\t}\n";
		$templateCode.="\tif(document.getElementById('".$name."_plink')!=undefined){\n";
		$templateCode.="\t\tdocument.getElementById('".$name."_plink').style.visibility='visible';\n";
		$templateCode.="\t}\n";
	}

	$templateCode.=$jsReadOnly;

	$templateCode.="\n</script>\n";


	// ajaxed auto-fill fields
	$templateCode.="<script src=\"prototype.js\"></script>";
	$templateCode.="<script>";
	$templateCode.="window.onload=function(){";


	$templateCode.="}";
	$templateCode.="</script>";

	return $templateCode;
}
?>