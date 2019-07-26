/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 14/04/2019
 */
DELIMITER $$

DROP PROCEDURE IF EXISTS `melisr`.`mel_avh_occurrence_core` $$
CREATE PROCEDURE `melisr`.`mel_avh_occurrence_core` (in_update_date DATETIME)
BEGIN
    DECLARE var_collection_object_id INT(11);
    DECLARE var_finished INT DEFAULT 0;

    DECLARE collection_object_cursor CURSOR FOR
    SELECT co.CollectionObjectID
    FROM collectionobject co
    JOIN collectingevent ce ON co.CollectingEventID=ce.CollectingEventID
    JOIN locality l ON ce.LocalityID=l.LocalityID
    JOIN geography g ON l.GeographyID=g.GeographyID
    JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID AND d.IsCurrent=true
    JOIN taxon t ON d.TaxonID=t.TaxonID
    WHERE co.CollectionID=4 AND (
        co.TimestampModified > in_update_date 
        OR ce.TimestampModified > in_update_date 
        OR l.TimestampModified > in_update_date 
        OR g.TimestampModified > in_update_date 
        OR t.TimestampModified > in_update_date 
    );

    DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET var_finished = 1;

    
    IF in_update_date='0000-00-00' THEN
        TRUNCATE mel_avh_occurrence_core_test;
    END IF;

    OPEN collection_object_cursor;
    get_id: LOOP
        FETCH collection_object_cursor
        INTO var_collection_object_id;

        CALL mel_avh_occurrence_core_record(var_collection_object_id);

        IF var_finished = 1 THEN
            LEAVE get_id;
        END IF;
    END LOOP get_id;
    CLOSE collection_object_cursor;

END $$

DELIMITER ;

