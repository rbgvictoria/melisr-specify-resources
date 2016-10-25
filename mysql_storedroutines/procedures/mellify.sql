/*
*
* Mellify procedure
*
* Moves records from the staging collection to the National Herbarium of Victoria
* collection and correctly formats the catalogue number and barcode. [2016-10-11]
*
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS mellify $$
CREATE PROCEDURE mellify ()
BEGIN
    START TRANSACTION;
    SET @DISABLE_TRIGGER=1;
    UPDATE collectionobject co
    LEFT JOIN collectionobjectattribute coa ON co.CollectionObjectAttributeID=coa.CollectionObjectAttributeID
    LEFT JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    LEFT JOIN preparation p ON co.CollectionObjectID=p.CollectionObjectID
    LEFT JOIN otheridentifier oi ON co.CollectionObjectID=oi.CollectionObjectID
    SET co.AltCatalogNumber=CAST(SUBSTR(co.CatalogNumber, 5) AS UNSIGNED),
      co.Modifier='A',
      co.`Name`=CONCAT('MEL ', CAST(SUBSTR(co.CatalogNumber, 5) AS UNSIGNED)),
      co.CatalogNumber=CONCAT(SUBSTR(co.CatalogNumber, 5), 'A'),
      co.CollectionID=4,
      co.CollectionMemberID=4,
      coa.CollectionMemberID=4,
      d.CollectionMemberID=4,
      p.CollectionMemberID=4,
      p.PrepTypeID=1,
      oi.CollectionMemberID=4,
      co.TimestampModified=NOW()
    WHERE co.CollectionID=131072 AND co.CatalogNumber IS NOT NULL;
    SET @DISABLE_TRIGGER=NULL;
    COMMIT;
END $$

DELIMITER ;



