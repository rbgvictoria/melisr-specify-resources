/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 11/10/2020
 */

DROP function IF EXISTS `coordinate_uncertainty_in_meters`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `coordinate_uncertainty_in_meters`(in_precision varchar(2)) RETURNS int(11)
BEGIN
	DECLARE out_uncertainty INTEGER;
    SET out_uncertainty = CASE in_precision
      WHEN '1' THEN 50
      WHEN '2' THEN 1000
      WHEN '3' THEN 10000
      WHEN '4' THEN 25000
      ELSE NULL
	END;
RETURN out_uncertainty;
END$$

DELIMITER ;
