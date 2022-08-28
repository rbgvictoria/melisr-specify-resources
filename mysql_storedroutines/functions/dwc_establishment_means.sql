USE `melisr`;
DROP function IF EXISTS `dwc_establishment_means`;

USE `melisr`;
DROP function IF EXISTS `melisr`.`dwc_establishment_means`;
;

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
	CASE var_introduced
		WHEN 'Native' THEN
			CASE var_cultivated
				WHEN 'Cultivated' THEN
					SET out_establishment_means = 'introduced';
				WHEN 'Not cultivated' THEN
					SET out_establishment_means = 'native';
				WHEN 'Presumably cultivated' THEN
					SET out_establishment_means = 'uncertain';
				WHEN 'Possibly cultivated' THEN
					SET out_establishment_means = 'uncertain';
				WHEN 'Unknown' THEN
					SET out_establishment_means = 'uncertain';
				ELSE
					SET out_establishment_means = 'native';
			END CASE;
		WHEN 'Not Native' THEN
			CASE var_cultivated
				WHEN 'Cultivated' THEN
					SET out_establishment_means = 'introduced';
				WHEN 'Not cultivated' THEN
					SET out_establishment_means = 'introduced';
				WHEN 'Possibly cultivated' THEN
					SET out_establishment_means = 'introduced';
				WHEN 'Presumably cultivated' THEN
					SET out_establishment_means = 'introduced';
				WHEN 'Unknown' THEN
					SET out_establishment_means = 'uncertain';
				ELSE
					set out_establishment_means = 'introduced';
			END CASE;
		WHEN 'Unkbown' THEN
			set out_establishment_means = 'uncertain';
		ELSE
			CASE var_cultivated 
				WHEN 'Cultivated' THEN
					SET out_establishment_means = 'introduced';
				WHEN 'Possibly cultivated' THEN
					SET out_establishment_means = 'uncertain';
				WHEN 'Presumably cultivated' THEN
					SET out_establishment_means = 'uncertain';
				ELSE
					SET out_establishment_means = NULL;
			END CASE;
	END CASE;
				
	RETURN out_establishment_means;
END$$

DELIMITER ;
;

