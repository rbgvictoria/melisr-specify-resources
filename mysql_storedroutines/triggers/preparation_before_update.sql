/***************************************************************************************
preparation_before_update trigger

Populates the Sample Number field for Vic. Ref. Set samples. [NK 2013-10-10]

***************************************************************************************/

DROP TRIGGER IF EXISTS preparation_before_update;

DELIMITER $$

CREATE TRIGGER preparation_before_update BEFORE UPDATE ON preparation
FOR EACH ROW
  BEGIN
    DECLARE new_number VARCHAR(32);

    IF isnull(@DISABLE_TRIGGER) THEN
      IF NEW.PrepTypeID=18 AND OLD.PrepTypeID=24 AND NEW.SampleNumber IS NULL AND OLD.SampleNumber IS NULL THEN -- Vic. Ref. Set specimen
        IF NEW.SampleNumber IS NULL THEN
          SELECT IF(MAX(SampleNumber) IS NOT NULL, MAX(SampleNumber)+1, 1)
          INTO new_number
          FROM preparation
          WHERE PrepTypeID=18;

          SET NEW.SampleNumber = LPAD(new_number, 6, '0');
        END IF;
      END IF;
    END IF;
  END $$

DELIMITER ;
