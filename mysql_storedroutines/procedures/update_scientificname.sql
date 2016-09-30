DELIMITER $$

DROP PROCEDURE IF EXISTS update_full_scientific_name_string $$
CREATE PROCEDURE update_full_scientific_name_string(p_taxonid int)
BEGIN
    UPDATE taxon
    SET UnitName1=full_scientific_name_string(TaxonID, RankID)
    WHERE TaxonID=p_taxonID;
END $$

DELIMITER ;