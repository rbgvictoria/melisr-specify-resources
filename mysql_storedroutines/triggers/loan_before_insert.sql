/***************************************************************************************
loan_before_insert trigger



***************************************************************************************/

DROP TRIGGER IF EXISTS loan_before_insert;

DELIMITER $$

CREATE TRIGGER loan_before_insert BEFORE INSERT ON loan
FOR EACH ROW
  BEGIN
        DECLARE var_loan_year INTEGER(11);
        DECLARE var_loan_seqnumber INTEGER(11);
        DECLARE var_loan_to VARCHAR(6);
        DECLARE var_melrefno VARCHAR(4);
        
        IF isnull(@DISABLE_TRIGGER) THEN
            IF NEW.DisciplineID=3 THEN
                IF NEW.LoanNumber='####/####' THEN
                    SELECT MAX(substring(LoanNumber, 1, 4))
                    INTO var_loan_year
                    FROM loan
                    WHERE DisciplineID=3;

                    SELECT MAX(substring(LoanNumber, 6, 4))+1
                    INTO var_loan_seqnumber
                    FROM loan
                    WHERE substring(LoanNumber, 1, 4)=var_loan_year
                      AND DisciplineID=3;

                    SET NEW.LoanNumber=CONCAT(var_loan_year, '/', LPAD(var_loan_seqnumber, 4, '0'));

                END IF;
            ELSE 
                SELECT LPAD(MAX(LoanNumber)+1, 4, '0')
                INTO var_melrefno
                FROM loan
                WHERE DisciplineID=32768;

                SET NEW.LoanNumber=var_melrefno;
            END IF;
        END IF;
  END $$

DELIMITER ;