/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 15/04/2019
 */
DELIMITER $$

DROP PROCEDURE IF EXISTS `melisr`.`reindex_higher_geography` $$
CREATE PROCEDURE `melisr`.`reindex_higher_geography` ()
BEGIN
    
    DECLARE var_geography_id INTEGER(11);
    DECLARE var_node_number INT;
    DECLARE var_geography_rank VARCHAR(16);

    DECLARE var_finished INT DEFAULT 0;
    DECLARE geography_cursor CURSOR FOR 
        SELECT g.GeographyID, g.NodeNumber, gd.Name
        FROM geography g
        JOIN geographytreedefitem gd ON g.GeographyTreeDefItemID=gd.GeographyTreeDefItemID
        JOIN locality l ON g.GeographyID=l.GeographyID
        JOIN collectingevent ce ON l.LocalityID=ce.CollectingEventID
        JOIN collectionobject co ON ce.CollectingEventID=co.CollectingEventID
        WHERE co.CollectionID=4
        GROUP BY g.GeographyID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;

    TRUNCATE aux_highergeography_test;

    OPEN geography_cursor;
    geography_loop: LOOP
        FETCH geography_cursor 
        INTO var_geography_id, var_node_number, var_geography_rank;

        CALL replace_higher_geography_record(var_geography_id, var_node_number, var_geography_rank);

        IF var_finished = 1 THEN
            LEAVE geography_loop;
        END IF;
    END LOOP geography_loop;
    CLOSE geography_cursor;
END $$

DELIMITER ;

