/***************************************************************************************

collectionobject_before_update trigger

Trigger that adds a record to the mel_recataloguenumbered table when a 
catalogue number of a record that is not made on the same day is changed. (These records 
will have been delivered to AVH with the old catalog number and need to be deleted 
from AVH.) -- NK 2013-03-18

***************************************************************************************/

DROP TRIGGER IF EXISTS collectionobject_before_update;

DELIMITER $$

CREATE TRIGGER collectionobject_before_update BEFORE UPDATE ON collectionobject
FOR EACH ROW
  BEGIN
    IF isnull(@DISABLE_TRIGGER) THEN
        IF DATE(NEW.TimestampCreated)<DATE(NOW()) AND NEW.CatalogNumber!=OLD.CatalogNumber THEN
            INSERT INTO mel_recataloguenumbered (TimestampCreated, CollectionObjectID, PreviousCatalogNumber, CreatedByAgentID)
            VALUES (NOW(), NEW.CollectionObjectID, OLD.CatalogNumber, NEW.ModifiedByAgentID);

            IF NEW.CollectionID=4 THEN
              SET NEW.CatalogNumber=CONCAT(SUBSTRING(NEW.CatalogNumber, 1, 7), UPPER(SUBSTRING(NEW.CatalogNumber, 8)));
              SET NEW.AltCatalogNumber=CAST(SUBSTRING(NEW.CatalogNumber, 1, 7) AS unsigned);
              SET NEW.Name=CONCAT('MEL ', CAST(SUBSTRING(NEW.CatalogNumber, 1, 7) AS unsigned));
              SET NEW.Modifier=UPPER(SUBSTRING(NEW.CatalogNumber, 8));

              -- dwc:typeStatus
              SET NEW.Description = dwc_type_status(NEW.CollectionObjectID);
            END IF;
        END IF;

    END IF;
  END $$

DELIMITER ;