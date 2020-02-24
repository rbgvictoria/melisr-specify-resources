/***************************************************************************************

collectionobject_before_insert trigger

Creates AltCatalogNumber, Modifier (part) and Name (barcode) and capitalises the part
CatalogNumber [NK, 2011-12-30]

Added statement that sets the Cataloged Date with the date the record is created.
This way the statistics in the Specify Welcome screen will be correct. [NK, 2012-01-03]

Added statement to replace CreatedByAgentID with CatalogerID, if the two are 
different, so that Workbench uploads are assigned to the correct agent. [NK, 2012-01-03]
***************************************************************************************/

DROP TRIGGER IF EXISTS collectionobject_before_insert;

DELIMITER $$

CREATE TRIGGER collectionobject_before_insert BEFORE INSERT ON collectionobject
FOR EACH ROW
  BEGIN
  IF isnull(@DISABLE_TRIGGER) THEN
    IF NEW.CatalogedDate IS NULL THEN
      SET NEW.CatalogedDate=DATE(NEW.TimestampCreated);
      SET NEW.CatalogedDatePrecision=1;
    END IF;
    IF NEW.CollectionID=4 THEN
      SET NEW.CatalogNumber=CONCAT(SUBSTRING(NEW.CatalogNumber, 1, 7), UPPER(SUBSTRING(NEW.CatalogNumber, 8)));
      SET NEW.AltCatalogNumber=CAST(SUBSTRING(NEW.CatalogNumber, 1, 7) AS unsigned);
      SET NEW.Name=CONCAT('MEL ', CAST(SUBSTRING(NEW.CatalogNumber, 1, 7) AS unsigned));
      SET NEW.Modifier=UPPER(SUBSTRING(NEW.CatalogNumber, 8));
    ELSE
      IF NEW.CollectionID=65536 THEN
          SET NEW.AltCatalogNumber=CAST(NEW.CatalogNumber AS unsigned);
          SET NEW.Name=CONCAT('VRS ', NEW.CatalogNumber);
      END IF;
    END IF;
    IF NEW.CreatedByAgentID!=NEW.CatalogerID THEN
      SET NEW.CreatedByAgentID=NEW.CatalogerID;
    END IF;
  END IF;
  END $$

DELIMITER ;