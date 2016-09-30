DELIMITER $$

DROP FUNCTION IF EXISTS `dwc_type_status` $$
CREATE FUNCTION `dwc_type_status` (colobjid INT) RETURNS VARCHAR(1024) CHARSET utf8
BEGIN
    DECLARE var_typeOfType VARCHAR(32);
    DECLARE var_scientificName VARCHAR(128);
    DECLARE var_author VARCHAR(128);
    DECLARE var_protologue VARCHAR(255);
    DECLARE var_year INT;

    DECLARE str VARCHAR(1024);

    SELECT d.TypeStatusName, t.FullName, t.Author, t.CommonName, t.Number2
    INTO var_typeOfType, var_scientificName, var_author, var_protologue, var_year
    FROM determination d
    JOIN taxon t ON d.TaxonID=t.TaxonID
    WHERE d.CollectionObjectID=colobjid AND d.TypeStatusName IS NOT NULL AND d.YesNo1=1
        AND d.SubspQualifier IS NULL AND d.TypeStatusName!='Authentic specimen'
    LIMIT 1;

    IF var_typeOfType IS NULL THEN
        RETURN NULL;
    ELSE
        SET str = CONCAT_WS(' ', var_typeOfType, 'of', var_scientificName, var_author);
        IF var_protologue IS NOT NULL AND var_year IS NOT NULL THEN
            SET str = CONCAT(str, ', ', var_protologue, ' (', var_year, ')');
        END IF;
        RETURN str;
    END IF;

END $$

DELIMITER ;
