DELIMITER $$

/*
* Function splits the input string (str) on a delimiter (del) and returns the
* bit indicated by the third parameter (i).
*/
DROP FUNCTION IF EXISTS `split_string` $$
CREATE FUNCTION `split_string`(str VARCHAR(1024) , del VARCHAR(1) , i INT) 
    RETURNS VARCHAR(1024) CHARSET utf8
BEGIN
    DECLARE n INT ;
    SET n = LENGTH(s) - LENGTH(REPLACE(str, del, '')) + 1;
    IF i > n THEN
        RETURN NULL;
    ELSE
        RETURN SUBSTRING_INDEX(SUBSTRING_INDEX(str, del, i) , del , -1 );
    END IF;
END $$

/*
* Function creates the Darwin Core identificationQualifier string from elements
* in the Determination and Taxon tables. The DwC identificationQualifier is the 
* qualifier plus the part of the scientific name that follows it.
*/
DROP FUNCTION IF EXISTS `dwc_identification_qualifier` $$
CREATE FUNCTION `dwc_identification_qualifier` (in_qualifier VARCHAR(8), in_rank VARCHAR(16), in_taxonID INT) 
    RETURNS VARCHAR(255) CHARSET utf8
BEGIN
    DECLARE var_name VARCHAR(255);
    DECLARE var_rank_id INT;

    DECLARE num INT;
    DECLARE ins INT;
    DECLARE spacer VARCHAR(1);

    SELECT t.RankID, t.FullName
    INTO var_rank_id, var_name
    FROM taxon t
    WHERE t.TaxonID=in_taxonID;

    IF in_qualifier IS NULL THEN
        RETURN NULL;
    ELSE
        -- number of name elements
        CASE 
            WHEN var_rank_id < 220 THEN SET num = 1; -- genus or monomial
            WHEN var_rank_id = 220 THEN SET num = 2; -- species
            WHEN var_rank_id > 220 THEN SET num = 3; -- infraspecific taxon
        END CASE;

        -- qualifier insertion point
        CASE in_rank
            WHEN 'family' THEN SET ins = 1;     -- preceding name
            WHEN 'genus' THEN SET ins = 1;      --    ,,
            WHEN 'species' THEN SET ins = 2;    -- preceding first epithet
            WHEN 'subspecies' THEN SET ins = 3; -- preceding second epithet
            WHEN 'variety' THEN SET ins = 3;    --    ,,
            WHEN 'forma' THEN SET ins = 3;      --    ,,
            ELSE SET ins = num;
        END CASE;

        -- by default the qualifier is inserted before the last name element 
        IF ins > num THEN 
            SET ins = num;
        END IF;

        IF in_qualifier='?' THEN
            SET spacer='';
        ELSE
            SET spacer=' ';
        END IF;

        -- return dwc:identificationQualifier
        CASE ins
            WHEN 1 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 1), split_string(var_name, ' ', 2),
                    split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
            WHEN 2 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 2),
                    split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
            WHEN 3 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
        END CASE;
        
    END IF;


END $$


DELIMITER ;


