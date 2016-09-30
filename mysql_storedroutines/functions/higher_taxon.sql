DELIMITER $$
/*
* Function returns name of higher taxon; parameters are the ID of the taxon
* record and the rank of the higher taxon.
*/
DROP FUNCTION IF EXISTS higher_taxon$$
CREATE FUNCTION  higher_taxon(p_taxonid int, p_rank varchar(64)) RETURNS varchar(128)
    READS SQL DATA
BEGIN

    DECLARE var_rankid INTEGER(11);
    DECLARE var_nodenumber INTEGER(11);
    DECLARE var_highestdescendantnodenumber INTEGER(11);
    DECLARE out_highertaxon VARCHAR(128);

    SELECT RankID
    INTO var_rankid
    FROM taxontreedefitem
    WHERE Name=p_rank AND TaxonTreeDefID=1;

    SELECT NodeNumber, HighestChildNodenumber
    INTO var_nodenumber, var_highestdescendantnodenumber
    FROM taxon
    WHERE taxonid=p_taxonid;

    IF (var_rankid<220) THEN
        SELECT Name
        INTO out_highertaxon
        FROM taxon
        WHERE NodeNumber<=var_nodenumber AND HighestChildNodeNumber>=var_highestdescendantnodenumber AND RankID=var_rankid AND TaxonTreeDefID=1;
    ELSEIF (var_rankid=220) THEN
        SELECT FullName
        INTO out_highertaxon
        FROM taxon
        WHERE NodeNumber<=var_nodenumber AND HighestChildNodeNumber>=var_highestdescendantnodenumber AND RankID=var_rankid AND TaxonTreeDefID=1;
    END IF;

    RETURN out_highertaxon;

END;

$$

DELIMITER ;