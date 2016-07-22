<?php

class LoanClass {
    private $db;
    private $loanid;
    
    public function __construct($db, $loanid) {
        $this->db = $db;
        $this->loanid = $loanid;
    }
    
    public function updateLoanQuantity() {
        $select = "SELECT sum(lp.Quantity)-sum(lp.QuantityReturned) AS QuantityOutstanding
            FROM loanreturnpreparation lrp
            RIGHT JOIN loanpreparation lp ON lp.LoanPreparationID=lrp.LoanPreparationID
            JOIN loan l ON lp.LoanID=l.LoanID
            JOIN preparation p ON lp.PreparationID=p.PreparationID
            JOIN collectionobject co ON p.CollectionObjectID=co.CollectionObjectID
            WHERE SUBSTRING(co.CatalogNumber, 8)='A'
            AND l.LoanID=$this->loanid";
        $query = $this->db->query($select);
        $row = $query->fetch_object();
        $loanquantity = $row->QuantityOutstanding;
        
        $update = "UPDATE loan
            SET Number1=$loanquantity
            WHERE LoanID=$this->loanid";
        $this->db->query($update);
    }
    
}

?>
