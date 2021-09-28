DELIMITER $$

DROP PROCEDURE IF EXISTS update_dwc_identification_qualifier $$
CREATE PROCEDURE update_dwc_identification_qualifier ()
BEGIN
    SET @DISABLE_TRIGGER = 1;

    UPDATE determination
    SET Text1=dwc_identification_qualifier(Qualifier, VarQualifier, TaxonID)
    WHERE Qualifier IS NOT NULL AND TaxonID IS NOT NULL;

    UPDATE determination d
    SET d.Text1=NULL
    WHERE d.Qualifier IS NULL AND d.Text1 IS NOT NULL;

    SET @DISABLE_TRIGGER = NULL;
END $$

DELIMITER ;

