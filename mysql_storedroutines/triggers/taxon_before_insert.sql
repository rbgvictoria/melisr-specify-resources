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

            IF NEW.IsHybrid = true AND NEW.UsfwsCode = 'x' THEN
                IF NEW.RankID > 220 THEN
                    SET NEW.FullName = REPLACE(REPLACE(REPLACE(NEW.FullName, ' subsp. ', ' nothosubsp. '), ' var. ', ' nothovar. '), ' f. ', ' nothof. ');
                END IF;
            END IF;
        END IF;
    END $$
DELIMITER ;