/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 12/11/2020
 */

DROP function IF EXISTS `dwc_reproductive_condition`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `dwc_reproductive_condition`(in_collection_object_id INT) RETURNS varchar(128) CHARSET utf8
BEGIN
	declare var_flower varchar(8);
	declare var_fruit varchar(8);
	declare var_buds varchar(8);
	declare var_fertile varchar(8);
	declare var_sterile varchar(8);
    declare out_reproductive_condition varchar(128);
    
	SELECT coa.Text13, coa.Text14, coa.Text15, coa.Text17, coa.Text18
    INTO var_flower, var_fruit, var_buds, var_fertile, var_sterile
	FROM collectionobjectattribute coa
	JOIN collectionobject co ON coa.CollectionObjectAttributeID=co.CollectionObjectAttributeID
    WHERE co.CollectionObjectID=in_collection_object_id;
    
    SET out_reproductive_condition=NULL;
    IF var_flower='1' OR var_fruit='1' OR var_buds='1' THEN
        IF var_flower='1' THEN
            SET out_reproductive_condition='flowers';
        END IF;
        IF var_fruit='1' THEN
			IF out_reproductive_condition IS NOT NULL THEN
                SET out_reproductive_condition = CONCAT_WS(' | ', out_reproductive_condition, 'fruit');
			ELSE 
				SET out_reproductive_condition = 'fruit';
            END IF;
        END IF;
        IF var_buds='1' THEN
			IF out_reproductive_condition IS NOT NULL THEN
                SET out_reproductive_condition = CONCAT_WS(' | ', out_reproductive_condition, 'buds');
			ELSE 
				SET out_reproductive_condition = 'buds';
            END IF;
        END IF;
	ELSEIF var_fertile='1' OR var_sterile='1' THEN 
		IF var_fertile='1' THEN
			SET out_reproductive_condition='fertile';
		ELSEIF var_sterile='1' THEN
			SET out_reproductive_condition='sterile';
		END IF;
    END IF;

    
RETURN out_reproductive_condition;
END$$

DELIMITER ;