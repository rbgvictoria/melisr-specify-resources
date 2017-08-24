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

      ELSEIF NEW.PrepTypeID=14 THEN -- VCSB
        SELECT IF(max(SampleNumber) IS NOT NULL, max(SampleNumber)+1, 1)
        INTO new_number
        FROM preparation
        WHERE PrepTypeID=14;

        SELECT IF(max(CatalogNumber)>new_number, max(CatalogNumber)+1, new_number)
        INTO new_number
        FROM collectionobject
        WHERE CollectionID=294912;

        SET new_number=lpad(new_number, 7, '0');

      ELSEIF NEW.PrepTypeID=155 THEN -- Seedling
        SELECT IF(max(SampleNumber) IS NOT NULL, MAX(CAST(SampleNumber AS unsigned))+1, 1)
        INTO new_number
        FROM preparation
        WHERE PrepTypeID=155;

      ELSE
        SET new_number=NEW.SampleNumber;

      END IF;

      SET NEW.SampleNumber=new_number;

    END IF;
  END $$

DELIMITER ;
