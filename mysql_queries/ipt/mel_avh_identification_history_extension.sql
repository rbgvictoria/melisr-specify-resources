/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 18/04/2019
 */
SELECT
  co.occurrenceID as "occurrenceID",
  d.GUID as "identificationID",
  IF(a.LastName IS NOT NULL, concat_ws(', ', LastName, FirstName), NULL) as "identifiedBy",
  dateWithPrecision(DeterminedDate, DeterminedDatePrecision) as "dateIdentified",
  t.FullName as "scientificName",
  t.Author as "scientificNameAuthorship",
  d.Text1 as "identificationQualifier",
  d.Remarks as "identificationRemarks"
FROM mel_avh_occurrence_core co
JOIn determination d ON co.mel_avh_occurrence_coreid=d.CollectionObjectID
JOIN taxon t ON d.TaxonID=t.TaxonID
LEFT JOIN agent a ON d.DeterminerID=a.AgentID
WHERE d.FeatureOrBasis NOT IN ('Type status') OR d.FeatureOrBasis IS NULL
