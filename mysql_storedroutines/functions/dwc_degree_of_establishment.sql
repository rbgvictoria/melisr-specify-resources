USE `melisr`;
DROP function IF EXISTS `dwc_degree_of_establishment`;

USE `melisr`;
DROP function IF EXISTS `melisr`.`dwc_degree_of_establishment`;
;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `dwc_degree_of_establishment`(in_collection_object_id INT) RETURNS varchar(50) CHARSET utf8
BEGIN
	DECLARE var_introduced varchar(50);
    DECLARE var_cultivated varchar(50);
    DECLARE out_degree_of_establishment varchar(50);
    
    SELECT cea.Text11, cea.text13
    INTO var_introduced, var_cultivated
    FROM collectionobject co
    JOIN collectingevent ce ON co. CollectingEventID=ce.CollectingEventID
    JOIN collectingeventattribute cea ON ce.CollectingEventAttributeID=cea.CollectingEventAttributeID
    WHERE co.CollectionObjectID=in_collection_object_id;
    
    SET out_degree_of_establishment = NULL;
    
    CASE var_introduced 
		WHEN 'Native' THEN 
			CASE var_cultivated
				WHEN 'Cultivated' THEN
					SET out_degree_of_establishment = 'cultivated';
				WHEN 'Not cultivated' THEN
					SET out_degree_of_establishment = 'native';
				WHEN 'Possibly cultivated' THEN
					SET out_degree_of_establishment = 'native';
				WHEN 'Unknown' THEN
					SET out_degree_of_establishment = NULL;
				ELSE
					SET out_degree_of_establishment = NULL;
			END CASE;
		WHEN 'Not native' THEN 
			CASE var_cultivated
				WHEN 'Cultivated' THEN
					SET out_degree_of_establishment = 'cultivated';  
				WHEN 'Not cultivated' THEN
					SET out_degree_of_establishment = 'established';
				WHEN 'Possibly cultivated' THEN
					SET out_degree_of_establishment = NULL;
				WHEN 'Presumably cultivated' THEN
					SET out_degree_of_establishment = NULL;
				WHEN 'Unknown' THEN
					SET out_degree_of_establishment = NULL;
				ELSE
					SET out_degree_of_establishment = NULL;
			END CASE;
		WHEN 'Unknown' THEN
			SET out_degree_of_establishment = NULL;
		ELSE
			CASE var_cultivated
				WHEN 'Cultivated' THEN
					SET out_degree_of_establishment = 'cultivated';
				ELSE
					SET out_degree_of_establishment = NULL;
			END CASE;
		END CASE;
    
	RETURN out_degree_of_establishment;
END$$

DELIMITER ;
;

