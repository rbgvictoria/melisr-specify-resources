DELIMITER $$

DROP PROCEDURE IF EXISTS update_scientificname $$
CREATE PROCEDURE update_scientificname(p_taxonid int)
BEGIN

UPDATE taxon
SET UnitName1=scientificname(TaxonID, RankID)
WHERE TaxonID=p_taxonID;

END $$

DELIMITER ;