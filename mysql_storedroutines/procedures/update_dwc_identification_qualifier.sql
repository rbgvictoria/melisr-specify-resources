DELIMITER $$

DROP PROCEDURE IF EXISTS update_dwc_type_status $$
CREATE PROCEDURE update_dwc_type_status ()
BEGIN
    UPDATE determination
    SET Text1=dwc_identification_qualifier(Qualifier, VarQualifier, TaxonID)
    WHERE Qualifier IS NOT NULL AND TaxonID IS NOT NULL;
END $$

DELIMITER ;

