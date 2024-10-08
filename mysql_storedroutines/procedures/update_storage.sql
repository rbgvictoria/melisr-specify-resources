DELIMITER $$

DROP PROCEDURE IF EXISTS update_storage $$
CREATE PROCEDURE update_storage (in_collectionobjectid INTEGER(11))
BEGIN

	DECLARE var_taxonid INTEGER(11);
	DECLARE var_type BIT(1);
	DECLARE var_rankid INTEGER(11);
	DECLARE var_nodenumber INTEGER(11);
        DECLARE var_main_storage VARCHAR(128);
        DECLARE var_type_storage VARCHAR(128);
	DECLARE var_storageid INTEGER(11);

	SELECT TaxonID
	INTO var_taxonid
	FROM determination
	WHERE YesNo1=1 AND CollectionObjectID=in_collectionobjectid
	LIMIT 1;

	IF var_taxonid THEN
            SET var_type = 1;
	ELSE
            SET var_type = 0;
            SELECT TaxonID
            INTO var_taxonID
            FROM determination
            WHERE IsCurrent=1 AND CollectionObjectID=in_collectionobjectid
            LIMIT 1;
	END IF; 

	/* find rank */

	SELECT RankID, NodeNumber
	INTO var_rankid, var_nodenumber
	FROM taxon
	WHERE TaxonID=var_taxonid;

	If var_rankid >= 180 THEN
            SELECT TaxonID, Text3, Text4
            INTO var_taxonid, var_main_storage, var_type_storage
            FROM taxon
            WHERE NodeNumber<=var_nodenumber AND HighestChildNodeNumber>=var_nodenumber
                    AND RankID=180
            LIMIT 1;
        ELSE
            SELECT TaxonID, Text3, Text4
            INTO var_taxonid, var_main_storage, var_type_storage
            FROM taxon
            WHERE TaxonID=var_taxonid;
	END IF;

	IF var_type=1 THEN
		SELECT StorageID
		INTO var_storageid
		FROM `storage`
		WHERE FullName=var_type_storage
                LIMIT 1;
	ELSE
		SELECT StorageID
		INTO var_storageid
		FROM `storage`
		WHERE FullName=var_main_storage
                LIMIT 1;
	END IF;

	UPDATE preparation
           SET StorageID=var_storageid, TimestampModified=NOW()
           WHERE CollectionObjectID=in_collectionobjectid;

END $$

DELIMITER ;