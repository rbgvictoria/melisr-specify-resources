/***************************************************************************************

determination trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS determination_after_update;

DELIMITER $$

CREATE TRIGGER determination_after_update AFTER UPDATE ON determination
FOR EACH ROW
  BEGIN
    IF isnull(@DISABLE_TRIGGER) THEN
        CALL update_storage(OLD.CollectionObjectID);
    END IF;
  END $$

DELIMITER ;
