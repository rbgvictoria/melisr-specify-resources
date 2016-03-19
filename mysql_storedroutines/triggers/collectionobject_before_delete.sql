/***************************************************************************************

collectionobject_before_delete trigger

This trigger creates a record in the mel_deleted table when a record is deleted that
was not created on the same day.

***************************************************************************************/

DROP TRIGGER IF EXISTS collectionobject_before_delete;

DELIMITER $$

CREATE TRIGGER collectionobject_before_delete BEFORE DELETE ON collectionobject
FOR EACH ROW
  BEGIN
    IF isnull(@DISABLE_TRIGGER) THEN
      IF DATE(NOW())>DATE(OLD.TimestampCreated) THEN
        INSERT INTO mel_deleted (TimestampCreated, CollectionObjectID, CatalogNumber, GUID)
        VALUES (NOW(), OLD.CollectionObjectID, OLD.CatalogNumber, OLD.GUID);
      END IF;
    END IF;
  END $$

DELIMITER ;