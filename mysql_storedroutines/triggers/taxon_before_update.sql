/***************************************************************************************

taxon_before_update trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS taxon_before_update;

DELIMITER $$

CREATE TRIGGER taxon_before_update BEFORE UPDATE ON taxon
FOR EACH ROW
    BEGIN
	      DECLARE var_fullname VARCHAR(256);
	    
        IF isnull(@DISABLE_TRIGGER) THEN 
            IF NEW.FullName != OLD.FullName OR NEW.Author != OLD.Author 
                    OR NEW.EsaStatus != OLD.EsaStatus 
                    OR (NEW.EsaStatus IS NOT NULL AND OLD.EsaStatus IS NULL) 
                    OR (NEW.EsaStatus IS NULL AND OLD.EsaStatus IS NOT NULL) THEN
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

            IF NEW.IsHybrid = true AND NEW.UsfwsCode = 'x' THEN
                IF NEW.RankID > 220 THEN
                    SET NEW.FullName = REPLACE(REPLACE(REPLACE(NEW.FullName, ' subsp. ', ' nothosubsp. '), ' var. ', ' nothovar. '), ' f. ', ' nothof. ');
                END IF;
            ELSE 
                IF NEW.RankID > 220 THEN
                    SET NEW.FullName = REPLACE(REPLACE(REPLACE(NEW.FullName, ' nothosubsp. ', ' subsp. '), ' nothovar. ', ' var. '), ' nothof. ', ' f. ');
                END IF;
            END IF;
        END IF;    
    END $$

DELIMITER ;