/***************************************************************************************

genusstorage_after_update trigger

Sets or updates the Storage ID when Genus Storage for a taxon is updated. The trigger
first queries for all Collection Objects that are stored under the genus and then calls
the update_storage procedure to update the storage for each of them.

***************************************************************************************/

DROP TRIGGER IF EXISTS genusstorage_after_update;

DELIMITER $$

CREATE TRIGGER genusstorage_after_update AFTER UPDATE ON genusstorage
FOR EACH ROW
  BEGIN
		DECLARE done INT DEFAULT FALSE;
		DECLARE var_collectionobjectid INTEGER(11);
		DECLARE cur_collectionobjectid CURSOR FOR
			SELECT CollectionObjectID
			FROM determination
			WHERE TaxonID=OLD.TaxonID AND (IsCurrent=1 OR YesNo1=1);
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

		IF isnull(@DISABLE_TRIGGER) THEN
			OPEN cur_collectionobjectid;
			cur_loop: LOOP
				FETCH cur_collectionobjectid INTO var_collectionobjectid;
				IF done THEN
					LEAVE cur_loop;
				END IF;
				CALL update_storage(var_collectionobjectid);
			END LOOP cur_loop;
		END IF;
  END $$

DELIMITER ;