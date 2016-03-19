/***************************************************************************************
preparation_autonumber trigger

Populates the Sample Number field for silicagel samples. [NK 2012-02-23]

***************************************************************************************/

DROP TRIGGER IF EXISTS preparation_before_insert;

DELIMITER $$

CREATE TRIGGER preparation_before_insert BEFORE INSERT ON preparation
FOR EACH ROW
  BEGIN
    DECLARE new_number VARCHAR(32);
    IF isnull(@DISABLE_TRIGGER) THEN
      IF NEW.PrepTypeID=2 THEN -- spirit collection
        IF NEW.SampleNumber IS NULL THEN
            SELECT MAX(CAST(SampleNumber AS UNSIGNED))+1
            INTO new_number
            FROM preparation
            WHERE PrepTypeID=2;
        ELSE
            SET new_number=NEW.SampleNumber;
        END IF;

      ELSEIF NEW.PrepTypeID=6 THEN -- microscope slide
        IF NEW.SampleNumber IS NULL THEN
            SELECT MAX(CAST(SampleNumber AS UNSIGNED))+1
            INTO new_number
            FROM preparation
            WHERE PrepTypeID=6;
        ELSE
            SET new_number=NEW.SampleNumber;
        END IF;

      ELSEIF NEW.PrepTypeID=7 THEN  -- silicagel sample
        SELECT MAX(CAST(SampleNumber AS UNSIGNED))+1
        INTO new_number
        FROM preparation
        WHERE PrepTypeID=7;

      ELSEIF NEW.PrepTypeID=18 THEN -- Vic. Ref. Set specimen
        SELECT IF(MAX(SampleNumber) IS NOT NULL, MAX(SampleNumber)+1, 1)
        INTO new_number
        FROM preparation
        WHERE PrepTypeID=18;

        SET new_number=LPAD(new_number, 6, '0');

      ELSE
        SET new_number=NEW.SampleNumber;

      END IF;

      SET NEW.SampleNumber=new_number;

    END IF;
  END $$

DELIMITER ;
