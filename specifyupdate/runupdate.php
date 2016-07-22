<?php
/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

require_once('collectionobjectclass.php');
require_once('loanclass.php');

@$db = new mysqli('203.55.15.78', 'admin', 'admpwd', 'melisr');
if (mysqli_connect_errno()) {
    echo 'Error: Could not connect to database' . "\n";
    exit;
}

runUpdate($db, $argv);
updateStorageID($db, $argv);
updateLoanQuantity($db, $argv);

function parseArguments($argv) {
        // parse arguments from command line; $argv[0] is the name of this script
        if(eregi('^[0-9]{4}-[0-9]{2}-[0-9]{2}$', $argv[1])) $timefrom = $argv[1];
        else {
                $timestamp=time();
                switch($argv[1]) {
                        case 'hourly':
                                $timefrom = date("Y-m-d", $timestamp-(65*60));
                                break;
                        case 'daily': 
                                $timefrom = date("Y-m-d", $timestamp-(24*60*60));
                                break;
                        case 'weekly': $timefrom = date("Y-m-d", $timestamp-(7*24*60*60));
                                break;
                        case 'monthly': $timefrom = date("Y-m-d", $timestamp-(31*24*60*60));
                                break;
                        case 'all': $timefrom = '0000-00-00';
                                break;
                        default:
                                echo 'usage: php reversegeo.php daily | weekly | monthly';
                                exit;
                }
        }

        return $timefrom;
}

function runUpdate($db, $argv) {
    $timefrom = parseArguments($argv);
    $select = "SELECT CatalogNumber, CollectionObjectID 
        FROM collectionobject
        WHERE TimestampModified >= '$timefrom'";
    $query = $db->query($select);
    if ($query->num_rows > 0) {
        while ($row = $query->fetch_object()) {
            $colobj = new CollectionObjectClass($db, $row->CollectionObjectID);
            $colobj->melNumber();
            $colobj->barcode();
			$colobj->part();
			$colobj->CatalogedDate();
            
            // turn Part into uppercase
            $update = "UPDATE collectionobject
                SET CatalogNumber=UPPER(CatalogNumber)
                WHERE CollectionObjectID=$row->CollectionObjectID";
            if (!$db->query($update)) echo "-- $row->CatalogNumber\n$update;\n\n";
            
            $colobj->updateMultisheet();
            $colobj->updateParts();
            $colobj->updateType();
        }
    } else return FALSE;
}

function updateStorageID($db, $argv) {
    $timefrom = parseArguments($argv);

    $handle = fopen('melisr_update.log', 'a');
    $time = date('Y-m-d G:i:s');

    fwrite($handle, "\n# $time\n");

    $select = "SELECT p.PreparationID, p.CollectionObjectID, co.CatalogNumber
        FROM preparation p
        JOIN collectionobject co ON p.CollectionObjectID=co.CollectionObjectID
        WHERE co.TimestampModified >= '$timefrom'";
    $query = $db->query($select);
    while ($row = $query->fetch_object()) {
        $colobj = new CollectionObjectClass($db, $row->CollectionObjectID);
        $storageid = $colobj->getStorageID();
        $update = "UPDATE preparation
            SET StorageID=$storageid
            WHERE PreparationID=$row->PreparationID";
        if(!$db->query($update))
            fwrite($handle, "-- $row->CatalogNumber\n$update;\n\n");
    }

    fclose($handle);
}

function updateLoanQuantity($db, $argv) {
    $timefrom = parseArguments($argv);
    
    $select = "SELECT LoanID
        FROM loan
        WHERE TimestampModified>$timefrom";
    $query = $db->query($select);
    while ($row = $query->fetch_object()) {
        $loanid = $row->LoanID;
        $loan = new LoanClass($db, $loanid);
        $loan->updateLoanQuantity();
    }
}



?>
