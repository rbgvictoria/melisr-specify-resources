/***************************************************************************************
loan_before_update trigger



***************************************************************************************/

DROP TRIGGER IF EXISTS loan_before_update;

DELIMITER $$

CREATE TRIGGER loan_before_update BEFORE UPDATE ON loan
FOR EACH ROW
  BEGIN
        DECLARE var_loan_number VARCHAR(10);
        DECLARE var_loan_to VARCHAR(6);
        DECLARE var_duedate DATE;
        DECLARE var_lending_inst VARCHAR(6);
        DECLARE var_qty_out INTEGER;
        
        IF isnull(@DISABLE_TRIGGER) THEN
            IF OLD.DisciplineID=3 THEN
                SELECT SUBSTRING(l.LoanNumber, 1, 9), a.Abbreviation
                INTO var_loan_number, var_loan_to
                FROM loan l
                JOIN shipment s ON l.LoanID=s.LoanID
                JOIN agent a ON s.ShippedToID=a.AgentID
                WHERE l.LoanID=OLD.LoanID
                LIMIT 1;

                SET NEW.LoanNumber=CONCAT(var_loan_number, ' ', var_loan_to);

                IF NEW.Version=1 THEN
                    SELECT ShipmentDate
                    INTO var_duedate
                    FROM shipment
                    WHERE LoanID=OLD.LoanID;
                    IF !isnull(var_duedate) THEN
                        SET NEW.CurrentDueDate = DATE_ADD(var_duedate, INTERVAL 12 MONTH);
                        SET NEW.OriginalDueDate = DATE_ADD(var_duedate, INTERVAL 12 MONTH);
                        IF NEW.DateReceived IS NULL THEN
                            SET NEW.SrcGeography = 'Awaiting acknowledgement';
                        END IF;
                    ELSE
                        SET NEW.CurrentDueDate = NULL;
                        SET NEW.OriginalDueDate = NULL;
                    END IF;

                END IF;

                IF !isnull(NEW.DateReceived) AND NEW.DateReceived!=OLD.DateReceived THEN
                    SET NEW.SrcGeography = 'Current';
                END IF;
            END IF;
            IF OLD.DisciplineID=32768 THEN
                SELECT a.Abbreviation
                INTO var_lending_inst
                FROM loan l
                JOIN loanagent la ON l.LoanID=la.LoanID AND la.Role='Lending institution'
                JOIN agent a ON la.AgentID=a.AgentID
                WHERE l.LoanID=NEW.LoanID;
                
                IF var_lending_inst IS NOT NULL AND SUBSTRING(NEW.SrcTaxonomy, 1, LENGTH(var_lending_inst))!=var_lending_inst THEN
                    SET NEW.SrcTaxonomy = CONCAT(var_lending_inst, ' ', NEW.SrcTaxonomy);
                END IF;

                SELECT IF(s.ShipmentID IS NOT NULL, l.Number1-SUM(s.Number1), l.Number1)
                INTO var_qty_out
                FROM loan l
                JOIN shipment s ON l.LoanID=s.LoanID
                WHERE l.LoanID=NEW.LoanID
                GROUP BY l.LoanID;

                SET NEW.Number2 = var_qty_out;

            END IF;
        END IF;
  END $$

DELIMITER ;