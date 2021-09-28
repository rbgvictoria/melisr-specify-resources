DROP function IF EXISTS `dwc_identification_qualifier`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `dwc_identification_qualifier`(in_qualifier VARCHAR(8), in_rank VARCHAR(16), in_taxonID INT) RETURNS varchar(255) CHARSET utf8
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
        
        CASE 
            WHEN var_rank_id < 220 THEN SET num = 1; 
            WHEN var_rank_id = 220 THEN SET num = 2; 
            WHEN var_rank_id > 220 THEN SET num = 3; 
            ELSE BEGIN END;
        END CASE;

        
        CASE in_rank
            WHEN 'family' THEN SET ins = 1;     
            WHEN 'genus' THEN SET ins = 1;      
            WHEN 'species' THEN SET ins = 2;    
            WHEN 'subspecies' THEN SET ins = 3; 
            WHEN 'variety' THEN SET ins = 3;    
            WHEN 'forma' THEN SET ins = 3;      
            ELSE SET ins = num;
        END CASE;

        
        IF ins > num THEN 
            SET ins = num;
        END IF;

        IF in_qualifier='?' THEN
            SET spacer='';
        ELSE
            SET spacer=' ';
        END IF;

        
        CASE ins
            WHEN 1 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 1), split_string(var_name, ' ', 2),
                    split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
            WHEN 2 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 2),
                    split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
            WHEN 3 THEN
                RETURN CONCAT(in_qualifier, spacer, CONCAT_WS(' ', split_string(var_name, ' ', 3), split_string(var_name, ' ', 4)));
			ELSE 
				BEGIN END;
        END CASE;
        
    END IF;


END$$

DELIMITER ;