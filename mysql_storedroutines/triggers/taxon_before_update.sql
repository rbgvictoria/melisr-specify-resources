/***************************************************************************************

taxon_before_update trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS taxon_before_update;

DELIMITER $$

CREATE TRIGGER taxon_before_update BEFORE UPDATE ON taxon
FOR EACH ROW
    BEGIN
        DECLARE var_fullname VARCHAR(255);

        IF isnull(@DISABLE_TRIGGER) THEN
            -- full scientific name string
            SET NEW.UnitName1 = full_scientific_name_string(NEW.TaxonID, NEW.RankID);

            -- genus
            IF NEW.RankID=180 OR RankID>=220 THEN
                SET NEW.UnitName2 = split_string(NEW.FullName, ' ', 1);
            END IF;

            -- specific epithet
            IF NEW.RankID>=220 THEN
                SET NEW.UnitName3 = split_string(NEW.FullName, ' ', 2);
            END IF;

            -- infraspecific epithet
            IF NEW.RankID>220 THEN
                SET NEW.UnitName4 = split_string(NEW.FullName, ' ', 4);
            END IF;

            -- Add 'ms' suffix for manuscript names
            IF (NEW.NcbiTaxonNumber='ms') THEN
                SET NEW.UnitName1=CONCAT(NEW.UnitName1,' ms');
            END IF;

            -- Append nomenclatural status to full name
            IF !isnull(NEW.EsaStatus) AND NEW.EsaStatus!='' THEN
                SET var_fullname = IF(NEW.FullName LIKE '%[%', SUBSTRING(NEW.FullName, 1, LOCATE('[', NEW.FullName)-2), NEW.FullName);
                SET NEW.FullName = CONCAT(var_fullname, ' [', NEW.EsaStatus, ']');
            END IF;

        END IF;
    END $$

DELIMITER ;