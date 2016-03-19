/***************************************************************************************

other_identifier trigger

The trigger will look for a space in the  Institution field and then put the bit before
the first space in the Institution field  and the bit after in the Catalogue no. field.
This way curation officers can use the  barcode scanner to enter the Other identifier.
[NK, 2012-02-03]
***************************************************************************************/

DROP TRIGGER IF EXISTS otheridentifier_before_insert;

DELIMITER $$

CREATE TRIGGER otheridentifier_before_insert BEFORE INSERT ON otheridentifier
FOR EACH ROW
  BEGIN
		IF isnull(@DISABLE_TRIGGER) THEN
			IF ISNULL(NEW.Institution) AND LOCATE(' ', NEW.Identifier) > 0 THEN
				SET NEW.Institution=SUBSTRING(NEW.Identifier, LOCATE(' ', NEW.Identifier) + 1);
				SET NEW.Identifier=SUBSTRING(NEW.Identifier, 1, LOCATE(' ', NEW.Identifier));
			END IF;
		END IF;
  END $$

DELIMITER ;
