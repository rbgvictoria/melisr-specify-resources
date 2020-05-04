DELIMITER $$

DROP PROCEDURE IF EXISTS `update_dwc_reproductive_condition`$$
CREATE PROCEDURE `update_dwc_reproductive_condition`()
BEGIN
	UPDATE collectionobjectattribute coa
    JOIN collectionobject co ON coa.CollectionObjectAttributeID=co.CollectionObjectAttributeID
    SET coa.Text28=dwc_reproductive_condition(co.CollectionObjectID);
END$$
DELIMITER ;
