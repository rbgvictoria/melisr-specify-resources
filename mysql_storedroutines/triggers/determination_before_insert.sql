/***************************************************************************************

determination trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS determination_before_insert;

DELIMITER $$

CREATE TRIGGER determination_before_insert BEFORE INSERT ON determination
FOR EACH ROW
  BEGIN
		IF isnull(@DISABLE_TRIGGER) THEN
            IF LOCATE('|', NEW.Remarks) THEN
                SET NEW.NameUsage = TRIM(SUBSTRING(NEW.Remarks, 1, LOCATE('|', NEW.Remarks)-1));
                SET NEW.Remarks = TRIM(SUBSTRING(NEW.Remarks, LOCATE('|', NEW.Remarks)+1));
            END IF;
		END IF;
  END $$

DELIMITER ;
