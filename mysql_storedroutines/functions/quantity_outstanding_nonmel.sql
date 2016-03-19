DELIMITER $$

DROP FUNCTION IF EXISTS quantity_outstanding_nonmel $$
CREATE FUNCTION quantity_outstanding_nonmel(p_loanid int) RETURNS int
    READS SQL DATA
BEGIN
RETURN (
    SELECT IF(s.ShipmentID IS NOT NULL, l.Number1-SUM(s.Number1), l.Number1)
    FROM loan l
    LEFT JOIN shipment s ON l.LoanID=s.LoanID
    WHERE l.DisciplineID=32768 AND l.LoanID=p_loanid
    GROUP BY l.LoanID
);

END $$

DELIMITER ;