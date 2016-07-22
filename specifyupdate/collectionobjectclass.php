<?php
/* 
 * Class for background scripts on collectionobjects.
 * We can't use any CodeIgniter functions in this class, as we need to be able to run it from the command line
 */

class CollectionObjectClass {
    var $db;
    var $collectionobjectid;
    
    public function __construct($db, $collectionobjectid) {
        $this->db = $db;
        $this->collectionobjectid = $collectionobjectid;
    }

    function melNumber() {
        $update = "UPDATE collectionobject
            SET AltCatalognumber=CAST(substring(CatalogNumber, 1, 7) AS unsigned)
            WHERE CollectionObjectID=$this->collectionobjectid";
        $this->db->query($update);
    }
	
	function part() {
        $update = "UPDATE collectionobject
            SET Modifier=upper(substring(CatalogNumber, 8))
            WHERE CollectionObjectID=$this->collectionobjectid";
        $this->db->query($update);
	}
    
    function barcode() {
        $update = "UPDATE collectionobject
            SET Name=CONCAT('MEL ', CAST(substring(CatalogNumber, 1, 7) AS unsigned))
            WHERE CollectionObjectID=$this->collectionobjectid";
        $this->db->query($update);
    }
	
	function CatalogedDate() {
		$update = "UPDATE collectionobject
			SET CatalogedDate=DATE(TimestampCreated)
			WHERE isnull(CatalogedDate)
			AND CollectionObjectID=$this->collectionobjectid";
        $this->db->query($update);
	}
    
    function getStorageID() {
        $select = "SELECT d.TaxonID, t.RankID, t.NodeNumber 
            FROM determination d
            JOIN taxon t ON d.TaxonID=t.TaxonID
            WHERE d.CollectionObjectID=$this->collectionobjectid AND d.YesNo1=1";
        $query = $this->db->query($select);
        if ($query->num_rows > 0) { // it is a type
            $row = $query->fetch_assoc();
            if ($row['RankID'] <= 180) { // it is a taxon of generic or higher rank
                $s1 = "SELECT StorageIDTypes 
                    FROM `genusstorage`
                    WHERE TaxonID=$row[TaxonID]";
                $q1 = $this->db->query($s1);
                if ($q1->num_rows > 0) {
                    $r1 = $q1->fetch_assoc();
                    return $r1['StorageIDTypes'];
                }
            } else { // lower than generic rank
                $s1 = "SELECT TaxonID
                    FROM taxon
                    WHERE NodeNumber<$row[NodeNumber] AND HighestChildNodeNumber>=$row[NodeNumber] AND RankID=180";
                $q1 = $this->db->query($s1);
                $r1 = $q1->fetch_assoc();
                $s2 = "SELECT StorageIDTypes
                    FROM `genusstorage`
                    WHERE TaxonID=$r1[TaxonID]";
                $q2 = $this->db->query($s2);
                if ($q1->num_rows) {
                    $r2 = $q2->fetch_assoc();
                    return $r2['StorageIDTypes'];
                } else return FALSE;
            }
        } else {
            $select = "SELECT d.TaxonID, t.RankID, t.NodeNumber
                FROM determination d
                JOIN taxon t ON d.TaxonID=t.TaxonID
                WHERE d.CollectionObjectID=$this->collectionobjectid AND d.IsCurrent=1";
            $query = $this->db->query($select);
            if ($query->num_rows > 0) {
                $row = $query->fetch_assoc();
                if ($row['RankID'] <= 180) { // it is a taxon of generic or higher rank
                    $s1 = "SELECT StorageID
                        FROM `genusstorage`
                        WHERE TaxonID=$row[TaxonID]";
                    $q1 = $this->db->query($s1);
                    if ($q1->num_rows > 0) {
                        $r1 = $q1->fetch_assoc();
                        return $r1['StorageID'];
                    }
                } else { // lower than generic rank
                    $s1 = "SELECT TaxonID
                        FROM taxon
                        WHERE NodeNumber<$row[NodeNumber] AND HighestChildNodeNumber>=$row[NodeNumber] AND RankID=180";
                    $q1 = $this->db->query($s1);
                    $r1 = $q1->fetch_assoc();
                    $s2 = "SELECT StorageID
                        FROM `genusstorage`
                        WHERE TaxonID=$r1[TaxonID]";
                    $q2 = $this->db->query($s2);
                    if ($q1->num_rows) {
                        $r2 = $q2->fetch_assoc();
                        return $r2['StorageID'];
                    } else return FALSE;
                }
            } return false;
        }
    }

    function updateType() {
        $select = "SELECT COUNT(*) AS t
            FROM determination
            WHERE CollectionObjectID=$this->collectionobjectid
            AND YesNo1=1";
        $query = $this->db->query($select);
        $row = $query->fetch_assoc();
        $type = ($row['t'] > 0) ? 1 : 0;
        $update = "UPDATE collectionobject SET YesNo1=$type WHERE CollectionObjectID=$this->collectionobjectid";
        if (!$this->db->query($update)) echo "$update\n\n";
    }

    function updateMultisheet() {
        $select = "SELECT COUNT(*) AS t
            FROM preparation
            WHERE CollectionObjectID=$this->collectionobjectid
            AND !isnull(Remarks) AND TRIM(Remarks)!=''";
        $query = $this->db->query($select);
        $row = $query->fetch_assoc();
        $multi = ($row['t'] > 0) ? 1 : 0;
        $update = "UPDATE collectionobject SET YesNo2=$multi WHERE CollectionObjectID=$this->collectionobjectid";
        if (!$this->db->query($update)) echo "$update\n\n";
    }

    function updateParts() {
        $sel = "SELECT AltCatalogNumber
            FROM collectionobject
            WHERE CollectionObjectID=$this->collectionobjectid";
        $q = $this->db->query($sel);
        $r = $q->fetch_object();
        $melno = $r->AltCatalogNumber;
        
        $select = "SELECT CollectionObjectID
            FROM collectionobject
            WHERE AltCatalogNumber='$melno'
            GROUP BY AltCatalogNumber";
        $query = $this->db->query($select);
        if ($query->num_rows > 1) {
            $collectionobjects = array();
            while ($row = $query->fetch_object()) {
                $collectionobjects[] = $row->CollectionObjectID;
            }
            $collectionobjects = implode(',', $collectionobjects);

            $update = "UPDATE collectionobject 
                SET Notifications=$query->num_rows
                WHERE CollectionObjectID IN ($collectionobjects)";
            if (!$this->db->query($update))
                echo "$update\n\n";

        }
    }
    
}

?>
