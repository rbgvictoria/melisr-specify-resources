/***************************************************************************************

attachment_before_insert trigger

Sets the Title to the name of the uploaded file [NK 2014-04-04]
***************************************************************************************/

DROP TRIGGER IF EXISTS attachment_before_insert;

DELIMITER $$

CREATE TRIGGER attachment_before_insert BEFORE INSERT ON attachment
FOR EACH ROW
  BEGIN
    IF isnull(@DISABLE_TRIGGER) THEN
      SET NEW.Title = SUBSTRING_INDEX(NEW.origFilename, '\\', -1);
    END IF;
  END $$

DELIMITER ;
