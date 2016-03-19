/***************************************************************************************
gift_before_insert trigger



***************************************************************************************/

DROP TRIGGER IF EXISTS gift_before_insert;

DELIMITER $$

CREATE TRIGGER gift_before_insert BEFORE INSERT ON gift
FOR EACH ROW
  BEGIN
		DECLARE var_gift_number INTEGER(11);
        DECLARE var_exchangein_number INTEGER(11);
        
        IF isnull(@DISABLE_TRIGGER) THEN
            SELECT MAX(GiftNumber)
            INTO var_gift_number
            FROM gift;

            SELECT MAX(Text1)
            INTO var_exchangein_number
            FROM exchangein;

            IF var_gift_number>=var_exchangein_number THEN
                SET NEW.GiftNumber=LPAD(var_gift_number+1, 4, '0');
            ELSE
                SET NEW.GiftNumber=LPAD(var_exchangein_number+1, 4, '0');
            END IF;
        END IF;
  END $$

DELIMITER ;