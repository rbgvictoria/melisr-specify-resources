DELIMITER $$

DROP FUNCTION IF EXISTS higher_geography $$
CREATE FUNCTION  higher_geography(p_geographyid int, p_rank varchar(64)) 
    RETURNS varchar(128) CHARSET utf8
    READS SQL DATA
BEGIN

    DECLARE var_rankid INTEGER(11);
    DECLARE var_nodenumber INTEGER(11);
    DECLARE var_highestdescendantnodenumber INTEGER(11);
    DECLARE out_highergeography VARCHAR(128);

    SELECT RankID
    INTO var_rankid
    FROM geographytreedefitem
    WHERE Name=p_rank AND GeographyTreeDefID=1;

    SELECT NodeNumber, HighestChildNodenumber
    INTO var_nodenumber, var_highestdescendantnodenumber
    FROM geography
    WHERE GeographyID=p_geographyid;

    SELECT Name
    INTO out_highergeography
    FROM geography
    WHERE NodeNumber<=var_nodenumber AND HighestChildNodeNumber>=var_highestdescendantnodenumber AND RankID=var_rankid AND GeographyTreeDefID=1;

    RETURN out_highergeography;

END;

$$

DELIMITER ;