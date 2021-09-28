DELIMITER $$

DROP PROCEDURE IF EXISTS `update_dwc_countrycode`$$
CREATE PROCEDURE `update_dwc_countrycode`()
BEGIN
    UPDATE geography
    SET Text1=dwc_countrycode(GeographyID)
    WHERE GeographyTreeDefID=1 AND RankID>=200;
END$$
DELIMITER ;
