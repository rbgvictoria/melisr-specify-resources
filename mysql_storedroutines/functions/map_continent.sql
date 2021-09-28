/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 15/11/2020
 */
DROP function IF EXISTS `map_continent`;

DELIMITER $$
CREATE DEFINER=`admin`@`%` FUNCTION `map_continent`(in_continent varchar(64)) RETURNS varchar(32) CHARSET utf8
BEGIN
	DECLARE out_continent VARCHAR(32);
    SET out_continent = CASE in_continent
      WHEN '1. Europe' THEN 'Europe'
      WHEN '2. Africa' THEN 'Africa'
      WHEN '3. Asia-Temperate' THEN 'Asia'
      WHEN '4. Asia-Tropical' THEN 'Asia'
      WHEN '5. Australasia' THEN 'Oceania'
      WHEN '6. Pacific' THEN 'Oceania'
      WHEN '7. Northern America' THEN 'North America'
	  WHEN '8. Southern America' THEN 'South America'
      WHEN '9. Antarctica' THEN 'Antarctica' 
      ELSE NULL
	END;
RETURN out_continent;
END$$

DELIMITER ;

