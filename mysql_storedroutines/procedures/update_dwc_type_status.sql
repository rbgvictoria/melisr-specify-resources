DELIMITER $$

DROP PROCEDURE IF EXISTS update_dwc_type_status $$
CREATE PROCEDURE update_dwc_type_status ()
BEGIN
    UPDATE collectionobject
    SET Description=dwc_type_status(CollectionObjectID)
    WHERE CollectionObjectID IN (
        SELECT CollectionObjectID
        FROM determination
        WHERE TypeStatusName IS NOT NULL
            AND YesNo1=1 AND SubspQualifier IS NULL AND TypeStatusName!='Authentic specimen'
    );
END $$

DELIMITER ;

