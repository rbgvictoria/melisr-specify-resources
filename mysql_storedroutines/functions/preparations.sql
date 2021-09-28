/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 12/11/2020
 */
DROP function IF EXISTS `preparations`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `preparations`(in_collection_object_id INTEGER) RETURNS varchar(256) CHARSET utf8
BEGIN
	DECLARE out_preparations VARCHAR(256);
	SELECT GROUP_CONCAT(DISTINCT pt.Name ORDER BY pt.PrepTypeID SEPARATOR ' | ')
    INTO out_preparations
	FROM preparation p
	JOIN preptype pt ON p.PrepTypeID=pt.PrepTypeID
	WHERE p.CollectionObjectID=in_collection_object_id AND pt.PrepTypeID NOT IN (13, 15, 16, 17, 18, 24)
	GROUP BY p.CollectionObjectID;
RETURN out_preparations;
END$$

DELIMITER ;

