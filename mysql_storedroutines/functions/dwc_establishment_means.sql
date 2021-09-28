DROP function IF EXISTS `dwc_establishment_means`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `dwc_establishment_means`(in_collection_object_id INT) RETURNS varchar(50) CHARSET utf8
BEGIN
    DECLARE var_introduced varchar(50);
    DECLARE var_cultivated varchar(50);
    DECLARE out_establishment_means varchar(50);
    
    SELECT cea.text11, cea.text13
    INTO var_introduced, var_cultivated
    FROM collectionobject co
    JOIN collectingevent ce ON co. CollectingEventID=ce.CollectingEventID
    JOIN collectingeventattribute cea ON ce.CollectingEventAttributeID=cea.CollectingEventAttributeID
    WHERE co.CollectionObjectID=in_collection_object_id;
    
    SET out_establishment_means = NULL;
    IF var_introduced = 'Native' THEN
        SET out_establishment_means = 'native';
	ELSE
        IF var_introduced = 'Not native' THEN
            SET out_establishment_means = 'introduced';
		END IF;
	END IF;
    
    IF var_cultivated='Cultivated' THEN
        SET out_establishment_means = 'cultivated';
	END IF;
    
RETURN out_establishment_means;
END$$

DELIMITER ;