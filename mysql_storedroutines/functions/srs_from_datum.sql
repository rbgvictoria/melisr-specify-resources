/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 15/10/2020
 */
DROP function IF EXISTS `srs_from_datum`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `srs_from_datum`(in_datum varchar(16)) RETURNS varchar(16) CHARSET utf8
BEGIN
    DECLARE out_srs VARCHAR(16);
    SET out_srs = CASE in_datum
      WHEN 'WGS84' THEN 'epsg:4326'
      WHEN 'GDA94' THEN 'epsg:4283'
      WHEN 'AGD84' THEN 'epsg:4203'
      WHEN 'AGD66' THEN 'epsg:4202'
      WHEN 'Minna' THEN 'epsg:4263'
      ELSE 'epsg:4326'
    END;
RETURN 1;
END$$

DELIMITER ;
