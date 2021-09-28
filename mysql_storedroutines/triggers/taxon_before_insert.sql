/***************************************************************************************

taxon_before_insert trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS taxon_before_insert;

DELIMITER $$

CREATE TRIGGER taxon_before_insert BEFORE INSERT ON taxon
FOR EACH ROW
    BEGIN
        IF isnull(@DISABLE_TRIGGER) THEN
            IF !isnull(NEW.EsaStatus) AND NEW.EsaStatus!='' THEN
                SET NEW.FullName = CONCAT(NEW.FullName, ' [', NEW.EsaStatus, ']');
            END IF;
        END IF;
    END $$
DELIMITER ;