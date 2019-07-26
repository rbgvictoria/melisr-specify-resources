/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 18/04/2019
 */
SELECT co.occurrenceID,
  substring(l.LoanNumber, 1, locate(' ', l.LoanNumber)-1) as "loanID",
  substring(l.LoanNumber, locate(' ', l.LoanNumber)+1) as "loanDestination"
FROM mel_avh_occurrence_core co
JOIN preparation p ON co.mel_avh_occurrence_coreId=p.CollectionObjectID
JOIN loanpreparation lp ON p.PreparationID=lp.PreparationID
JOIN loan l ON lp.LoanID=l.LoanID
WHERE lp.IsResolved=false;

