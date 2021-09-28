DELIMITER $$

DROP PROCEDURE IF EXISTS `update_dwc_establishment_means`$$
CREATE PROCEDURE `update_dwc_establishment_means`()
BEGIN
    UPDATE collectingeventattribute cea
    JOIN collectingevent ce ON cea.CollectingEventAttributeID=ce.CollectingEventAttributeID
    JOIN collectionobject co ON ce.CollectingEventID=co.CollectingEventID
    SET cea.Text7=NULL
    WHERE co.CollectionID=4;

    UPDATE collectingeventattribute cea
    JOIN collectingevent ce ON cea.CollectingEventAttributeID=ce.CollectingEventAttributeID
    JOIN collectionobject co ON ce.CollectingEventID=co.CollectingEventID
    SET cea.Text7=dwc_establishment_means(co.CollectionObjectID)
    WHERE co.CollectionID=4 AND (cea.Text11 IS NOT NULL OR cea.Text13 IS NOT NULL);
END$$
DELIMITER ;
