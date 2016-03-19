/***************************************************************************************

collectionobject_after_update trigger

Sets or updates the Storage ID when a Collection Object record is created or updated.
Every time a Determination or Preparation record is inserted or updated, the Collection
Object record is changed as well. Therefore the update of the Collection Object record
triggers the update of the storage. When a new Collection Object record is inserted
through the Specify client, the same record is updated more than once. The last of
these updates updates the Version field. As this is the only update that is certain to
occur after Determination or Preparation tables have been changed, we first test
whether the Version field is updated, so we don't run the same procedure more than once
in the same transaction.

***************************************************************************************/

DROP TRIGGER IF EXISTS collectionobject_after_update;

DELIMITER $$

CREATE TRIGGER collectionobject_after_update AFTER UPDATE ON collectionobject
FOR EACH ROW
  BEGIN
    IF isnull(@DISABLE_TRIGGER) THEN
        IF !isnull(NEW.Version) THEN
            CALL update_storage(OLD.CollectionObjectID);
        END IF;
    END IF;
  END $$
DELIMITER ;