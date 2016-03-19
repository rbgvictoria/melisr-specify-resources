<?php

require_once('mypdoconnect.php');

$handle = fopen('S:\\COLLECT\\Loans & exchange\\Exchange\\Incoming exchange\\PERTH\\PERTH 11062012\\PERTH_untruncate.csv', 'r');

// prepared statements
$select = "SELECT CollectionObjectID, CollectingEventID
    FROM collectionobject
    WHERE CatalogNumber=?";
$selectCOStmt = $db->prepare($select);

$update = "UPDATE collectionobject
    SET Text1=?
    WHERE CollectionObjectID=?";
$updateCOStmt = $db->prepare($update);

$update = "UPDATE collectingevent
    SET Remarks=?, VerbatimLocality=?
    WHERE CollectingEventID=?";
$updateCEStmt = $db->prepare($update);

$max = "SELECT MAX(CollectingEventID)
    FROM collectingevent";
$maxCEIdStmt = $db->prepare($max);

$insert = "INSERT INTO collectingevent (CollectingEventID, TimestampCreated, Version, Remarks, VerbatimLocality, CreatedByAgentID)
    VALUES (?, NOW(), 0, ?, ?, 2)";
$insertCEStmt = $db->prepare($insert);

$update = "UPDATE collectionobject
    SET CollectingEventID=?
    WHERE CollectionObjectID=?";
$updateCEIdStmt = $db->prepare($update);

$first = TRUE;
while (!feof($handle)) {
    $line = fgetcsv($handle);
    if ($first) {
        $first = FALSE;
        continue;
    }
    
    $selectCOStmt->execute(array($line[0]));
    $row = $selectCOStmt->fetch(5);
    
    $coID = $row->CollectionObjectID;
    $ceID = $row->CollectingEventID;
    
    $updateCOStmt->execute(array($line[1], $coID));
    if ($updateCOStmt->errorCode() != '00000') {
        $error = $updateCOStmt->errorInfo();
        array_unshift($error, 'Descriptive note');
        array_unshift($error, $line[0]);
        print_r($error);
    }
    
    if ($ceID) {
        $updateCEStmt->execute(array($line[2], $line[3], $ceID));
        if ($updateCEStmt->errorCode() != '00000') {
            $error = $updateCEStmt->errorInfo();
            array_unshift($error, 'Habitat (update)');
            array_unshift($error, $line[0]);
            print_r($error);
        }
    }
    else {
        $maxCEIdStmt->execute();
        $row = $maxCEIdStmt->fetch(3);
        $ceID = $row[0] + 1;
        
        $insertCEStmt->execute(array($ceID, $line[2], $line[3]));
        if ($insertCEStmt->errorCode() != '00000') {
            $error = $insertCEStmt->errorInfo();
            array_unshift($error, 'Habitat (insert)');
            array_unshift($error, $line[0]);
            print_r($error);
        }
        
        $updateCEIdStmt->execute($ceID, $coID);
        if ($updateCEIdStmt->errorCode() != '00000') {
            $error = $updateCEIdStmt->errorInfo();
            array_unshift($error, 'Update CollectingEventID');
            array_unshift($error, $line[0]);
            print_r($error);
        }
    }
}


?>
