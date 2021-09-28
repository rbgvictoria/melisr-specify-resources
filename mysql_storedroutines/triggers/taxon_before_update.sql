/***************************************************************************************

taxon_before_update trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS taxon_before_update;

DELIMITER $$

CREATE TRIGGER taxon_before_update BEFORE UPDATE ON taxon
FOR EACH ROW
    BEGIN
        IF isnull(@DISABLE_TRIGGER) THEN 
          IF NEW.FullName != OLD.FullName OR NEW.Author != OLD.Author THEN
            IF !isnull(NEW.EsaStatus) AND NEW.EsaStatus!='' THEN
                SET var_fullname = IF(NEW.FullName LIKE '%[%', SUBSTRING(NEW.FullName, 1, LOCATE('[', NEW.FullName)-2), NEW.FullName);
                SET NEW.FullName = CONCAT(var_fullname, ' [', NEW.EsaStatus, ']');
            END IF;

          END IF;

          IF NEW.TaxonTreeDefItemID=12 
              AND ((NEW.Text3 IS NOT NULL AND (NEW.Text3<>OLD.Text3 OR OLD.Text3 IS NULL)) 
              OR  (NEW.Text4 IS NOT NULL AND (NEW.Text4<>OLD.Text4 OR OLD.Text4 IS NULL))) THEN
            SET NEW.YesNo1=true;
          END IF;
        END IF;    
    END $$

DELIMITER ;