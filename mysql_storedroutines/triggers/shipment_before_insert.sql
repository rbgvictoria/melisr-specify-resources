/***************************************************************************************
shipment_before_insert trigger



***************************************************************************************/

DROP TRIGGER IF EXISTS shipment_before_insert;

DELIMITER $$

CREATE TRIGGER shipment_before_insert BEFORE INSERT ON shipment
FOR EACH ROW
    BEGIN
        DECLARE var_duedate DATE;
        DECLARE var_loanid INTEGER(11);
        DECLARE var_shipmentnumber varchar(5);
        
        IF isnull(@DISABLE_TRIGGER) THEN
            SELECT LPAD(MAX(ShipmentNumber)+1, 5, '0')
            INTO var_shipmentnumber
            FROM shipment;
            SET NEW.ShipmentNumber=var_shipmentnumber;

            /*IF !isnull(NEW.ShipmentDate) AND !isnull(NEW.LoanID) AND NEW.DisciplineID=3 THEN
                SET var_duedate = DATE_ADD(NEW.ShipmentDate, INTERVAL 12 MONTH);
                SET var_loanid = NEW.LoanID;
                -- CALL update_loandates(var_loanid, var_duedate);
            END IF;*/
        END IF;
    END $$
DELIMITER ;