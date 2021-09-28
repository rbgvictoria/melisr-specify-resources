/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 15/04/2019
 */
DROP procedure IF EXISTS `replace_higher_taxonomy_record`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` PROCEDURE `replace_higher_taxonomy_record`(in_taxon_id INTEGER(11), in_node_number INT, in_taxon_rank VARCHAR(16))
BEGIN
    DECLARE var_kingdom VARCHAR(64);
    DECLARE var_phylum VARCHAR(64);
    DECLARE var_class VARCHAR(64);
    DECLARE var_order VARCHAR(64);
    DECLARE var_family VARCHAR(64);
    DECLARE var_genus VARCHAR(64);
    DECLARE var_specific_epithet VARCHAR(64);
    DECLARE var_infraspecific_epithet VARCHAR(64);
    DECLARE var_higher_taxonomy TEXT;

    DECLARE var_taxonomy_rank VARCHAR(16);
    DECLARE var_taxonomy_name VARCHAR(128);
    DECLARE var_taxonomy_full_name VARCHAR(128);

    DECLARE var_finished INT DEFAULT 0;
    DECLARE higher_taxonomy_cursor CURSOR FOR
        SELECT td.Name as var_rank, t.name as var_name, if(t.FullName LIKE '% [%' , substring(t.FullName, 1, LOCATE(' [', t.FullName)-1), t.FullName)
        FROM taxon t
        JOIN taxontreedefitem td ON t.TaxonTreeDefItemID=td.TaxonTreeDefItemID
        WHERE NodeNumber<=in_node_number AND HighestChildNodeNumber>=in_node_number 
            AND NodeNumber>1 AND t.Name NOT LIKE '%indet.'
        ORDER BY td.RankID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;

    OPEN higher_taxonomy_cursor;
    higher_taxonomy_loop: LOOP
        FETCH higher_taxonomy_cursor
        INTO var_taxonomy_rank, var_taxonomy_name, var_taxonomy_full_name;

        IF var_taxonomy_rank != in_taxon_rank THEN
            IF var_higher_taxonomy IS NULL THEN
                SET var_higher_taxonomy = var_taxonomy_full_name;
            ELSE
                SET var_higher_taxonomy = CONCAT_WS(' | ', var_higher_taxonomy, var_taxonomy_full_name);
            END IF;
        END IF;

        CASE var_taxonomy_rank
            WHEN 'kingdom' THEN 
				SET var_kingdom = var_taxonomy_name;
            WHEN 'division' THEN 
				SET var_phylum = var_taxonomy_name; 
            WHEN 'class' THEN 
				SET var_class = var_taxonomy_name;
            WHEN 'order' THEN 
				SET var_order = var_taxonomy_name;
            WHEN 'family' THEN 
				SET var_family = var_taxonomy_name;
            WHEN 'genus' THEN SET var_genus = var_taxonomy_name;
            WHEN 'species' THEN 
				SET var_specific_epithet = var_taxonomy_name;
            WHEN 'subspecies' THEN 
				SET var_infraspecific_epithet = var_taxonomy_name;
            WHEN 'variety' THEN 
				SET var_infraspecific_epithet = var_taxonomy_name;
            WHEN 'subvariety' THEN 
				SET var_infraspecific_epithet = var_taxonomy_name;
            WHEN 'forma' THEN 
				SET var_infraspecific_epithet = var_taxonomy_name;
            WHEN 'subforma' THEN 
				SET var_infraspecific_epithet = var_taxonomy_name;
            ELSE 
				BEGIN END;
        END CASE;

        IF var_finished = 1 THEN
            LEAVE higher_taxonomy_loop;
        END IF;
    END LOOP higher_taxonomy_loop;
    
    IF in_taxon_rank='division' THEN 
		SET in_taxon_rank='phylum'; 
	END IF;

    REPLACE INTO aux_highertaxonomy_test (TaxonID, taxonRank,
        kingdom, phylum, `class`, `order`, family, genus, specificEpithet, infraspecificEpithet,
        higherTaxonomy, modified)
    VALUES (in_taxon_id, in_taxon_rank, 
        var_kingdom, var_phylum, var_class, var_order, var_family, var_genus,
        var_specific_epithet, var_infraspecific_epithet, var_higher_taxonomy, now());
    CLOSE higher_taxonomy_cursor;
END$$

DELIMITER ;