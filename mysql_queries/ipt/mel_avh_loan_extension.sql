/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 18/04/2019
 */
SELECT 
  co.GUID as occurrenceId, 
  substring(l.LoanNumber, 1, locate(' ', l.LoanNumber)-1) AS loanIdentifier, 
  substring(l.LoanNumber, locate(' ', l.LoanNumber)+1) AS loanDestination
FROM melisr.collectionobject co
JOIN melisr.preparation p ON co.CollectionObjectID=p.CollectionObjectID
JOIN melisr.loanpreparation lp ON p.PreparationID=lp.PreparationID
LEFT JOIN melisr.loanreturnpreparation lrp ON lp.LoanPreparationID=lrp.LoanPreparationID
JOIN melisr.loan l ON lp.LoanID=l.LoanID
WHERE co.CollectionID=4 AND lrp.LoanReturnPreparationID IS NULL