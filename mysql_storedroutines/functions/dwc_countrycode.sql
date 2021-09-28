USE `melisr`;
DROP function IF EXISTS `dwc_countrycode`;

DELIMITER $$
USE `melisr`$$
CREATE FUNCTION `dwc_countrycode` (in_geography_id INTEGER)
RETURNS VARCHAR(32)
BEGIN
    DECLARE var_node_number INTEGER;
    DECLARE var_country_code VARCHAR(32);
    
    SELECT NodeNumber
    INTO var_node_number
    FROM geography
    WHERE GeographyID=in_geography_id;
    
    SELECT GeographyCode
    INTO var_country_code
    FROM geography
    WHERE NodeNumber<=var_node_number AND HighestChildNodeNumber>=var_node_number AND RankID=200
    LIMIT 1;

RETURN var_country_code;
END$$

DELIMITER ;