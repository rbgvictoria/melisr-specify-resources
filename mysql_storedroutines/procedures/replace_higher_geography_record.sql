/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 15/04/2019
 */
DROP procedure IF EXISTS `replace_higher_geography_record`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` PROCEDURE `replace_higher_geography_record`(in_geography_id INTEGER(11), in_node_number INT, in_geography_rank VARCHAR(16))
BEGIN
    DECLARE var_continent VARCHAR(64);
    DECLARE var_country VARCHAR(64);
    DECLARE var_state VARCHAR(64);
    DECLARE var_county VARCHAR(64);
    DECLARE var_higher_geography TEXT;

    DECLARE var_geography_rank VARCHAR(16);
    DECLARE var_geography_name VARCHAR(128);
    DECLARE var_geography_full_name VARCHAR(128);
    DECLARE var_geography_code VARCHAR(16);
    DECLARE var_country_code VARCHAR(4);

    DECLARE var_finished INT DEFAULT 0;
    DECLARE higher_geography_cursor CURSOR FOR
        SELECT gd.Name as var_rank, g.name as var_name, g.GeographyCode AS var_code
        FROM geography g
        JOIN geographytreedefitem gd ON g.GeographyTreeDefItemID=gd.GeographyTreeDefItemID
        WHERE g.NodeNumber<=in_node_number AND g.HighestChildNodeNumber>=in_node_number 
            AND g.NodeNumber>1 AND g.GeographyTreeDefID=1
        ORDER BY gd.RankID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;

    OPEN higher_geography_cursor;
    higher_geography_loop: LOOP
        FETCH higher_geography_cursor
        INTO var_geography_rank, var_geography_name, var_geography_code;
        
        IF var_geography_rank = 'Continent' THEN
			SET var_geography_name = map_continent(var_geography_name);
        END IF;

        IF var_geography_rank != in_geography_rank THEN
            IF var_higher_geography IS NULL THEN
                SET var_higher_geography = var_geography_name;
            ELSE
                SET var_higher_geography = CONCAT_WS(' | ', var_higher_geography, var_geography_name);
            END IF;
        END IF;

        CASE var_geography_rank
            WHEN 'continent' THEN 
				SET var_continent = var_geography_name;
            WHEN 'country' THEN 
				SET var_country = var_geography_name; 
                SET var_country_code=var_geography_code;
            WHEN 'state' THEN 
				SET var_state = var_geography_name;
            WHEN 'county' THEN 
				SET var_county = var_geography_name;
            ELSE BEGIN END;
        END CASE;

        IF var_finished = 1 THEN
            LEAVE higher_geography_loop;
        END IF;
    END LOOP higher_geography_loop;

    REPLACE INTO aux_highergeography_test (GeographyID, geographyRank,
        continent, country, `state`, county, higherGeography, countryCode, modified)
    VALUES (in_geography_id, in_geography_rank, 
        var_continent, var_country, var_state, var_county, var_higher_geography, var_country_code, now());
    CLOSE higher_geography_cursor;
END$$

DELIMITER ;