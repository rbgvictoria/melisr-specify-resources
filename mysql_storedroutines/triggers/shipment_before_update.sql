/***************************************************************************************
shipment_before_update trigger



***************************************************************************************/

DROP TRIGGER IF EXISTS shipment_before_update;

DELIMITER $$

CREATE TRIGGER shipment_before_update BEFORE UPDATE ON shipment
FOR EACH ROW
    BEGIN
        DECLARE var_duedate DATE;
        DECLARE var_loanid INTEGER(11);
        DECLARE var_acknowledged DATE;
        
        IF isnull(@DISABLE_TRIGGER) THEN
            SELECT DateReceived
            INTO var_acknowledged
            FROM loan
            WHERE LoanID=OLD.LoanID;
            
            IF !isnull(OLD.LoanID) AND !isnull(NEW.ShipmentDate) AND NEW.ShipmentDate!=OLD.ShipmentDate AND OLD.DisciplineID=4 AND var_acknowledged IS NOT NULL THEN
                SET var_duedate = DATE_ADD(NEW.ShipmentDate, INTERVAL 12 MONTH);
                SET var_loanid = NEW.LoanID;
                UPDATE loan
                SET CurrentDueDate=var_duedate, OriginalDueDate=var_duedate, SrcGeography='Awaiting acknowledgement'
                WHERE LoanID=var_loanid;
            END IF;
        END IF;
    END $$
DELIMITER ;