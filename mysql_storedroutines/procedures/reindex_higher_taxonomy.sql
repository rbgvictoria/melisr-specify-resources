/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 15/04/2019
 */
DELIMITER $$

DROP PROCEDURE IF EXISTS `melisr`.`reindex_higher_taxonymy` $$
CREATE PROCEDURE `melisr`.`reindex_higher_taxonymy` ()
taxa: BEGIN
    
    DECLARE var_taxon_id INTEGER(11);
    DECLARE var_node_number INT;
    DECLARE var_taxon_rank VARCHAR(16);

    DECLARE var_finished INT DEFAULT 0;
    DECLARE taxon_cursor CURSOR FOR 
        SELECT t.TaxonID, t.NodeNumber, td.Name
        FROM taxon t
        JOIN taxontreedefitem td ON t.TaxonTreeDefItemID=td.TaxonTreeDefItemID
        JOIN determination d ON t.TaxonID=d.TaxonID
        WHERE d.CollectionMemberID=4
        GROUP BY t.TaxonID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;

    TRUNCATE aux_highertaxonomy_test;

    OPEN taxon_cursor;
    taxon_loop: LOOP
        FETCH taxon_cursor 
        INTO var_taxon_id, var_node_number, var_taxon_rank;

        CALL replace_higher_taxonomy_record(var_taxon_id, var_node_number, var_taxon_rank);

        IF var_finished = 1 THEN
            LEAVE taxon_loop;
        END IF;
    END LOOP taxon_loop;
    CLOSE taxon_cursor;

    



    
END taxa $$

DELIMITER ;

