/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 12/11/2020
 */
DROP function IF EXISTS `identification_string`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `identification_string`(in_scientific_name varchar(128), in_identified_by varchar(128), in_date_identified varchar(16), in_identification_remarks text) RETURNS text CHARSET utf8
BEGIN
	DECLARE out_identification_string TEXT;
    SET out_identification_string = in_scientific_name;
    IF in_identified_by IS NOT NULL AND in_identified_by!='' THEN
		SET out_identification_string = CONCAT(out_identification_string, ', ', in_identified_by);
        IF in_date_identified IS NOT NULL AND in_date_identified!='' THEN
			SET out_identification_string = CONCAT(out_identification_string, ', ', in_date_identified);
		END IF;
	ELSE
        IF in_date_identified IS NOT NULL AND in_date_identified!='' THEN
			SET out_identification_string = CONCAT(out_identification_string, ', ', in_date_identified);
		END IF;
    END IF;
    IF in_identification_remarks IS NOT NULL AND in_identification_remarks!='' THEN
		SET out_identification_string = CONCAT(out_identification_string, ', ', in_identification_remarks);
    END IF;
    
RETURN out_identification_string;
END$$

DELIMITER ;

