DROP procedure IF EXISTS `insert_mel_avh_occurrence_records`;

DELIMITER $$

CREATE PROCEDURE `insert_mel_avh_occurrence_records` (in_limit INTEGER, in_offset INTEGER)
BEGIN
	insert into mel_avh_occurrence_core_test
	select co.CollectionObjectID as id, co.GUID as occurrenceID,
	  -- record level terms
	  'PhysicalObject' as "type",
	  co.TimestampModified as modified,
	  'https://creativecommons.org/licenses/by/4.0/legalcode' AS license,
	  'Royal Botanic Gardens Board' AS rightsHolder,
	  'MEL' as institutionCode,
	  'MEL' as collectionCode,
	  'PreservedSpecimen' as basisOfRecord,
	  
	  -- Occurrence
	  concat('MEL ', co.CatalogNumber) as catalogNumber,
	  ce.VerbatimLocality as occurrenceRemarks,
	  ce.StationFieldNumber as recordNumber,
	  collectorstring(ce.CollectingEventID, '|', true) as recordedBy,
	  recorded_by_id(ce.CollectingEventID) as recordedByID,
	  dwc_reproductive_condition(co.CollectionObjectID) as reproductiveCondition,
	  dwc_establishment_means(co.CollectionObjectID) as establishmentMeans,
	  'present' as occurrenceStatus,
	  preparations(co.CollectionObjectID) as preparations,
	  associated_sequences(co.CollectionObjectID) as associatedSequences,
	  -- associatedTaxa,
	  
	  -- Organism
	  previous_identifications(co.CollectionObjectID) previousIdentifications,
	  
	  -- Event
	  ce.GUID as eventID,
	  ctr.CollectingTripName as parentEventID,
	  concat_ws('/', dateWithPrecision(ce.StartDate, ce.StartDatePrecision), dateWithPrecision(ce.EndDate, ce.EndDatePrecision)) as eventDate,
	  if(ce.EndDate is null and ce.StartDatePrecision=1, dayofyear(ce.StartDate), null) as startDayOfYear,
	  if(ce.EndDate is null, year(ce.StartDate), null) as "year",
	  if(ce.EndDate is null and ce.StartDatePrecision in (1, 2), month(ce.StartDate), null) as "month",
	  if(ce.EndDate is null and ce.StartDatePrecision=1, day(ce.StartDate), null) as "day",
	  ce.VerbatimDate as verbatimEventDate,
	  ce.Remarks as habitat,
	  
	  -- Location
	  l.GUID as locationID,
	  hg.higherGeography,
	  ld.WaterBody as waterBody,
	  ld.IslandGroup as islandGroup,
	  ld.Island as island,
	  hg.continent,
	  hg.Country as country,
	  g.Text1 as countryCode,
	  hg.State as stateProvince,
	  hg.County as county,
	  l.LocalityName as verbatimLocality,
	  l.LocalityName as locality,
	  CASE 
		WHEN l.VerbatimElevation IS NOT NULL THEN l.VerbatimElevation
		ELSE
		  CASE l.Text1
			WHEN 'ft' THEN CASE WHEN l.MaxElevation IS NULL THEN CONCAT_WS(' ', l.MinElevation, l.Text1) ELSE CONCAT(l.MinElevation, '–', l.MaxElevation, ' ', l.Text1) END
			ELSE NULL
		  END
	  END as verbatimElevation,
	  CASE l.Text1 WHEN 'ft' THEN round(l.MinElevation * 0.3048) ELSE l.MinElevation END as minimumElevationInMeters,
	  CASE 
		WHEN l.MaxElevation Is Null THEN
		  CASE l.Text1 WHEN 'ft' THEN round(l.MinElevation * 0.3048) ELSE l.MinElevation END
		ELSE 
		  CASE l.Text1 WHEN 'ft' THEN round(l.MaxElevation * 0.3048) ELSE l.MaxElevation END
	  END as maximumElevationInMeters,
	  CASE 
		WHEN EndDepth IS NULL THEN
		  CASE StartDepthUnit
			WHEN '2' THEN CONCAT(StartDepth, ' ft')
			WHEN '3' THEN CONCAT(StartDepth, ' fathoms')
			ELSE NULL
		  END
		ELSE
		  CASE StartDepthUnit
			WHEN '2' THEN CONCAT(StartDepth, '–', EndDepth, ' ft')
			WHEN '3' THEN CONCAT(StartDepth, '–', ENDDepth, ' fathoms')
			ELSE NULL
		  END
	  END as verbatimDepth,
	  CASE StartDepthUnit WHEN '1' THEN StartDepth WHEN '2' THEN ROUND(StartDepth * 0.3048) WHEN '3' THEN ROUND(StartDepth * 1.8288) END as minimumDepthInMeters,
	  CASE 
		WHEN EndDepth IS NULL THEN
		  CASE StartDepthUnit WHEN '1' THEN StartDepth WHEN '2' THEN ROUND(StartDepth * 0.3048) WHEN '3' THEN ROUND(StartDepth * 1.8288) END
		ELSE
		  CASE StartDepthUnit WHEN '1' THEN EndDepth WHEN '2' THEN ROUND(EndDepth * 0.3048) WHEN '3' THEN ROUND(EndDepth * 1.8288) END
	  END as maximumDepthInMeters,
	  if(l.Latitude1 is not null and l.Longitude1 is not null, l.Lat1Text, null) as verbatimLatitude,
	  if(l.Latitude1 is not null and l.Longitude1 is not null, l.Long1Text, null) as verbatimLongitude,
	  gc.OriginalCoordSystem as verbatimCoordinateSystem,
	  srs_from_datum(l.Datum) as verbatimSRS,
	  l.Latitude1 as decimalLatitude,
	  l.Longitude1 as decimalLongitude,
	  srs_from_datum(l.Datum) as geodeticDatum,
	  if(gc.MaxUncertaintyEst IS NOT NULL, ROUND(gc.MaxUncertaintyEst), coordinate_uncertainty_in_meters(l.OriginalElevationUnit)) as coordinateUncertaintyInMeters,
	  gc.NamedPlaceExtent as coordinatePrecision,
	  concat_ws(', ', gca.LastName, gca.FirstName) as georeferencedBy,
	  gc.GeoRefDetDate as georeferencedDate,
	  l.LatLongMethod as georeferenceProtocol,
	  gc.Text1 as georeferenceSources,
	  replace(gc.GeoRefVerificationStatus, 'Corrected', 'Verified') as georeferenceVerificationStatus,
	  gc.GeoRefRemarks as georeferenceRemarks,
	  
	  -- Identification
	  d.GUID as identificationID,
	  concat_ws(', ', da.LastName, da.FirstName) as identifiedBy,
	  identified_by_id(d.DeterminationID) as identifiedByID,
	  dateWithPrecision(d.DeterminedDate, d.DeterminedDatePrecision) as dateIdentified,
	  d.Remarks as identificationRemarks,
	  dwc_identification_qualifier(d.Qualifier, d.VarQualifier, t.TaxonID) as identificationQualifier,
	  dwc_type_status(co.CollectionObjectID) as typeStatus,
		  
	  -- Taxon
	  if(t.FullName LIKE '% [%' , substring(t.FullName, 1, LOCATE(' [', t.FullName)-1), t.FullName) as scientificName,
	  t.Author as scientificNameAuthorship,
	  hc.higherTaxonomy as higherClassification,
	  hc.kingdom,
	  hc.phylum,
	  hc.`class`,
	  hc.`order`,
	  hc.family,
	  hc.genus,
	  hc.specificEpithet,
	  hc.infraspecificEpithet,
	  hc.taxonRank,
	  t.Remarks,
	  'ICN' as nomenclaturalCode,
	  t.EsaStatus as nomenclaturalStatus

	from collectionobject co
	join collectingevent ce on co.CollectingEventID=ce.CollectingEventID
	left join collectingtrip ctr ON ce.CollectingTripID=ctr.CollectingTripID
	join locality l on ce.LocalityID=l.LocalityID
	left join geography g on l.GeographyID=g.GeographyID
	left join aux_highergeography_test hg on g.GeographyID=hg.GeographyID
	left join localitydetail ld on l.LocalityID=ld.LocalityID
	left join geocoorddetail gc on l.LocalityID=gc.LocalityID
	left join agent gca on gc.AgentID=gca.AgentID
	left join determination d on co.CollectionObjectID=d.CollectionObjectID and d.IsCurrent=true
	left join agent da on d.DeterminerID=da.AgentID
	left join taxon t on d.TaxonID=t.TaxonID
	left join aux_highertaxonomy_test hc on t.TaxonID=hc.TaxonID
	where co.CollectionID=4
	limit in_offset, in_limit;
END$$

DELIMITER ;