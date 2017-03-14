DELIMITER $$

DROP PROCEDURE IF EXISTS `incoming` $$
CREATE DEFINER=`admin`@`%` PROCEDURE `incoming`()
BEGIN
    DECLARE var_collectionID INT;
    SET var_collectionID = 163840;
    SET @DISABLE_TRIGGER=1;

    START TRANSACTION;
    UPDATE collectionobject co
    LEFT JOIN collectionobjectattribute coa ON co.CollectionObjectAttributeID=coa.CollectionObjectAttributeID
    LEFT JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID
    LEFT JOIN preparation p ON co.CollectionObjectID=p.CollectionObjectID
    LEFT JOIN preptype pt1 ON p.PrepTypeID=pt1.PrepTypeID
    LEFT JOIN preptype pt2 ON pt1.Name=pt2.Name AND pt2.CollectionID=4
    LEFT JOIN otheridentifier oi ON co.CollectionObjectID=oi.CollectionObjectID
    SET co.AltCatalogNumber=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CAST(SUBSTR(co.AltCatalogNumber, 5) AS UNSIGNED), CAST(SUBSTR(co.AltCatalogNumber, 1, 7) AS UNSIGNED)),
      co.Modifier=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', 'A', SUBSTR(co.AltCatalogNumber, 8)),
      co.`Name`=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CONCAT('MEL ', CAST(SUBSTR(co.AltCatalogNumber, 5) AS UNSIGNED)), CONCAT('MEL ', CAST(SUBSTR(co.AltCatalogNumber, 1, 7) AS UNSIGNED))),
      co.CatalogNumber=IF(SUBSTRING(co.AltCatalogNumber, 1, 3)='MEL', CONCAT(SUBSTR(co.AltCatalogNumber, 5), 'A'), co.AltCatalogNumber),
      co.CollectionID=4,
      co.CollectionMemberID=4,
      coa.CollectionMemberID=4,
      d.CollectionMemberID=4,
      p.CollectionMemberID=4,
      p.PrepTypeID=pt2.PrepTypeID,
      oi.CollectionMemberID=4,
      co.TimestampCreated=NOW(),
      co.TimestampModified=NOW(),
      co.Version=1
    WHERE co.CollectionID=var_collectionID AND co.AltCatalogNumber IS NOT NULL;
    SET @DISABLE_TRIGGER=NULL;
    COMMIT;
END $$

DELIMITER ;
