/***************************************************************************************

determination trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS determination_before_update;

DELIMITER $$

CREATE TRIGGER determination_before_update BEFORE UPDATE ON determination
FOR EACH ROW
  BEGIN
    IF isnull(@DISABLE_TRIGGER) THEN
        -- dwc:identificationQualifier
        IF NEW.Qualifier IS NOT NULL THEN
            SET NEW.Text2 = dwc_identification_qualifier(NEW.Qualifier, NEW.VarQualifier, NEW.TaxonID);
        END IF;
    END IF;
  END $$

DELIMITER ;

