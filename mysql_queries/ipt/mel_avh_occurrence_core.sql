select 
  co.CollectionObjectID as id, 

  -- occurrenceID
  co.GUID as occurrenceID,

  /*
  * Record Level Terms
  */

  -- type
  'PhysicalObject' as "type",

  -- modified
  co.TimestampModified as modified,

  -- license
  'https://creativecommons.org/licenses/by/4.0/legalcode' AS license,

  -- rightsHolder
  'Royal Botanic Gardens Board' AS rightsHolder,

  -- institutionCode
  'MEL' as institutionCode,

  -- collectionCode
  'MEL' as collectionCode,

  -- basisOfRecord
  'PreservedSpecimen' as basisOfRecord,

  -- informationWithheld
  coa.Text26 as informationWithheld,

  -- dataGeneralizations
  coa.Text25 as dataGeneralizations,

  /* 
  *  Occurrence
  */

  -- catalogNumber
  concat('MEL ', co.CatalogNumber) as catalogNumber,

  -- occurrenceRemarks
  occurrenceRemarks(ce.VerbatimLocality, co.Remarks) as occurrenceRemarks,

  -- recordNumber
  ce.StationFieldNumber as recordNumber,

  -- recordedBy
  collectorstring(ce.CollectingEventID, ' | ', null) as recordedBy,

  -- recordedByID
  recorded_by_id(ce.CollectingEventID) as recordedByID,

  -- reproductiveCondition
  dwc_reproductive_condition(co.CollectionObjectID) as reproductiveCondition,

  -- establishmentMeans
  dwc_establishment_means(co.CollectionObjectID) as establishmentMeans,
  
  -- degreeOfEstablishment
  dwc_degree_of_establishment(co.CollectionObjectID) as degreeOfEstablishment,

  -- occurrenceStatus
  'present' as occurrenceStatus,

  -- preparations
  preparations(co.CollectionObjectID) as preparations,

  -- associatedSequences
  seq.associated_sequences as associatedSequences,

  -- associatedTaxa
  
  /*
  * Organism
  */

  -- previousIdentifications
  previous_identifications(co.CollectionObjectID) as previousIdentifications,
  
  /*
  * Event
  */

  -- eventID
  ce.GUID as eventID,

  -- parentEventID
  ctr.CollectingTripName as parentEventID,

  -- eventDate
  concat_ws('/', dateWithPrecision(ce.StartDate, ce.StartDatePrecision), 
      dateWithPrecision(ce.EndDate, ce.EndDatePrecision)) as eventDate,

  -- startDayOfYear
  if(ce.EndDate is null and ce.StartDatePrecision=1, dayofyear(ce.StartDate), 
      null) as startDayOfYear,

  -- year
  if(ce.EndDate is null, year(ce.StartDate), null) as "year",

  -- month
  if(ce.EndDate is null and ce.StartDatePrecision in (1, 2), 
      month(ce.StartDate), null) as "month",

  -- day
  if(ce.EndDate is null and ce.StartDatePrecision=1, day(ce.StartDate), null) 
      as "day",

  -- verbatimEventDate
  ce.VerbatimDate as verbatimEventDate,

  -- habitat
  ce.Remarks as habitat,
  
  /*
  * Location
  */

  -- locationID
  l.GUID as locationID,

  -- higherGeography
  case 
    when g4.GeographyID is not null AND g4.Name!='Earth' then concat_ws(' | ', 
      if(gdi4.Name='Continent', map_continent(g4.Name), g4.Name), 
      if(gdi3.Name='Continent', map_continent(g3.Name), g3.Name), 
      if(gdi2.Name='Continent', map_continent(g2.Name), g2.Name), 
      if(gdi1.Name='Continent', map_continent(g1.Name), g1.Name)
    )
    when g3.GeographyID is not null AND g3.Name!='Earth' then concat_ws(' | ', 
      if(gdi3.Name='Continent', map_continent(g3.Name), g3.Name), 
      if(gdi2.Name='Continent', map_continent(g2.Name), g2.Name), 
      if(gdi1.Name='Continent', map_continent(g1.Name), g1.Name)
    )
    when g2.GeographyID is not null AND g2.Name!='Earth' then concat_ws(' | ', 
      if(gdi2.Name='Continent', map_continent(g2.Name), g2.Name), 
      if(gdi1.Name='Continent', map_continent(g1.Name), g1.Name)
    )
    when g1.GeographyID is not null AND g1.Name!='Earth' then 
      if(gdi1.Name='Continent', map_continent(g1.Name), g1.Name)
    else null 
  end as higherGeography,

  -- waterBody
  ld.WaterBody as waterBody,

  -- islandGroup
  ld.IslandGroup as islandGroup,

  -- island
  ld.Island as island,

  -- continent
  case 
    when gdi0.Name='Continent' then map_continent(g0.Name) 
    when gdi1.Name='Continent' then map_continent(g1.Name) 
    when gdi2.Name='Continent' then map_continent(g2.Name) 
    when gdi3.Name='Continent' then map_continent(g3.Name) 
    when gdi4.Name='Continent' then map_continent(g4.Name) 
    else null 
  end as continent,

  -- country
  case 
    when gdi0.Name='Country' AND g0.GeographyCode is not null then g0.Name 
    when gdi1.Name='Country' AND g1.GeographyCode is not null then g1.Name 
    when gdi2.Name='Country' AND g2.GeographyCode is not null then g2.Name 
    when gdi3.Name='Country' AND g3.GeographyCode is not null then g3.Name 
    when gdi4.Name='Country' AND g4.GeographyCode is not null then g4.Name 
    else null 
  end as country,

  -- countryCode
  case 
    when gdi0.Name='Country' then g0.GeographyCode 
    when gdi1.Name='Country' then g1.GeographyCode 
    when gdi2.Name='Country' then g2.GeographyCode 
    when gdi3.Name='Country' then g3.GeographyCode 
    when gdi4.Name='Country' then g4.GeographyCode 
    else null 
  end as countryCode,

  -- stateProvince
  case 
    when gdi0.Name='State' then g0.Name 
    when gdi1.Name='State' then g1.Name 
    when gdi2.Name='State' then g2.Name 
    when gdi3.Name='State' then g3.Name 
    when gdi4.Name='State' then g4.Name 
    else null 
  end as stateProvince,

  -- county
  case 
    when gdi0.Name='County' then g0.Name 
    when gdi1.Name='County' then g1.Name 
    when gdi2.Name='County' then g2.Name 
    when gdi3.Name='County' then g3.Name 
    when gdi4.Name='County' then g4.Name 
    else null 
  end as county,

  -- verbatimLocality
  l.LocalityName as verbatimLocality,

  -- locality
  l.LocalityName as locality,

  -- verbatimElevation
  CASE 
    WHEN l.VerbatimElevation IS NOT NULL THEN l.VerbatimElevation
    ELSE
      CASE l.Text1
        WHEN 'ft' THEN 
          CASE 
            WHEN l.MaxElevation IS NULL 
                THEN CONCAT_WS(' ', l.MinElevation, l.Text1) 
            ELSE CONCAT(l.MinElevation, '–', l.MaxElevation, ' ', l.Text1) 
          END
        ELSE NULL
      END
  END as verbatimElevation,

  -- minimumElevationInMeters
  CASE l.Text1 
    WHEN 'ft' THEN round(l.MinElevation * 0.3048) 
    ELSE l.MinElevation 
  END as minimumElevationInMeters,

  -- maximumElevationInMeters
  CASE 
    WHEN l.MaxElevation Is Null THEN
      CASE l.Text1 
        WHEN 'ft' THEN round(l.MinElevation * 0.3048) 
        ELSE l.MinElevation 
      END
    ELSE 
      CASE l.Text1 
        WHEN 'ft' THEN round(l.MaxElevation * 0.3048) 
        ELSE l.MaxElevation 
      END
  END as maximumElevationInMeters,

  -- verbatimDepth
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

  -- minimumDepthInMeters
  CASE StartDepthUnit 
    WHEN '1' THEN StartDepth 
    WHEN '2' THEN ROUND(StartDepth * 0.3048) 
    WHEN '3' THEN ROUND(StartDepth * 1.8288) 
  END as minimumDepthInMeters,

  -- maximumDepthInMeters
  CASE 
  WHEN EndDepth IS NULL THEN
    CASE StartDepthUnit 
      WHEN '1' THEN StartDepth 
      WHEN '2' THEN ROUND(StartDepth * 0.3048) 
      WHEN '3' THEN ROUND(StartDepth * 1.8288) 
    END
  ELSE
    CASE StartDepthUnit 
      WHEN '1' THEN EndDepth 
      WHEN '2' THEN ROUND(EndDepth * 0.3048) 
      WHEN '3' THEN ROUND(EndDepth * 1.8288) 
    END
  END as maximumDepthInMeters,

  -- verbatimLatitude
  if(l.Latitude1 is not null and l.Longitude1 is not null, l.Lat1Text, null) 
      as verbatimLatitude,

  -- verbatimLongitude
  if(l.Latitude1 is not null and l.Longitude1 is not null, l.Long1Text, null) 
      as verbatimLongitude,

  -- verbatimCoordinateSystem
  gc.OriginalCoordSystem as verbatimCoordinateSystem,

  -- verbatimSRS
  srs_from_datum(l.Datum) as verbatimSRS,

  -- decimalLatitude
  l.Latitude1 as decimalLatitude,

  -- decimalLongitude
  l.Longitude1 as decimalLongitude,

  -- geodeticDatum
  if(l.Latitude1 is not null and l.Longitude1 is not null, 
      if(l.Datum is not null, 
      srs_from_datum(l.Datum), 'epsg:4326'), null
    ) as geodeticDatum,

  -- coordinateUncertaintyInMeters
  coalesce(ROUND(gc.GeoRefAccuracy), ROUND(gc.MaxUncertaintyEst), 
      coordinate_uncertainty_in_meters(l.OriginalElevationUnit)) 
      as coordinateUncertaintyInMeters,

  -- coordinatePrecision
  gc.NamedPlaceExtent as coordinatePrecision,

  -- georeferencedBy
  concat_ws(', ', gca.LastName, gca.FirstName) as georeferencedBy,

  -- georeferenceDate
  gc.GeoRefDetDate as georeferencedDate,

  -- georeferenceProtocol
  l.LatLongMethod as georeferenceProtocol,

  -- georeferenceSources
  gc.Text1 as georeferenceSources,

  -- georeferenceVerificationStatus
  replace(gc.GeoRefVerificationStatus, 'Corrected', 'Verified') 
      as georeferenceVerificationStatus,

  -- georeferenceRemarks
  gc.GeoRefRemarks as georeferenceRemarks,
  
  /*
  * Identification
  */
  
  -- identificationID
  d.GUID as identificationID,

  -- identifiedBy,
  if(d.FeatureOrBasis='Acc. name change' or d.FeatureOrBasis='AVH annot.', 
      'National Herbarium of Victoria (MEL)', 
      concat_ws(', ', da.LastName, da.FirstName)
  ) as identifiedBy,

  -- identifiedByID
  identified_by_id(d.DeterminationID) as identifiedByID,

  -- dateIdentified
  dateWithPrecision(d.DeterminedDate, d.DeterminedDatePrecision) 
      as dateIdentified,

  -- identificationRemarks
  d.Remarks as identificationRemarks,

  -- identificationQualifier
  dwc_identification_qualifier(d.Qualifier, d.VarQualifier, t0.TaxonID) 
      as identificationQualifier,

  -- typeStatus
  dwc_type_status(co.CollectionObjectID) as typeStatus,
    
  /*
  * Taxon
  */

  -- scientificName
  if(t0.FullName LIKE '% [%' , 
      substring(t0.FullName, 1, LOCATE(' [', t0.FullName)-1), 
      t0.FullName
  ) as scientificName,

  -- scientificNameAuthorship
  t0.Author as scientificNameAuthorship,

  -- higherClassification
  case
    when t12.TaxonID is not null and tdi12.Name!='life' then concat_ws(' | ', 
        if(t12.Name!='Incertae sedis', t12.Name, null), 
        if(t11.Name!='Incertae sedis', t11.Name, null), 
        if(t10.Name!='Incertae sedis', t10.Name, null), 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t11.TaxonID is not null and tdi11.Name!='life' then concat_ws(' | ', 
        if(t11.Name!='Incertae sedis', t11.Name, null), 
        if(t10.Name!='Incertae sedis', t10.Name, null), 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t10.TaxonID is not null and tdi10.Name!='life' then concat_ws(' | ', 
        if(t10.Name!='Incertae sedis', t10.Name, null), 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t9.TaxonID is not null and tdi9.Name!='life' then concat_ws(' | ', 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t8.TaxonID is not null and tdi8.Name!='life' then concat_ws(' | ', 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t7.TaxonID is not null and tdi7.Name!='life' then concat_ws(' | ', 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
		if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t6.TaxonID is not null and tdi6.Name!='life' then concat_ws(' | ', 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t5.TaxonID is not null and tdi5.Name!='life' then concat_ws(' | ', 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t4.TaxonID is not null and tdi4.Name!='life' then concat_ws(' | ', 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t3.TaxonID is not null and tdi3.Name!='life' then concat_ws(' | ', 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t2.TaxonID is not null and tdi2.Name!='life' then concat_ws(' | ', 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t1.TaxonID is not null and tdi1.Name!='life' then 
        if(t1.Name!='Incertae sedis', t1.Name, null)
    else null
  end as higherClassification,

  -- kingdom
  case 
    when tdi0.Name='kingdom' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='kingdom' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='kingdom' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='kingdom' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='kingdom' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='kingdom' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='kingdom' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='kingdom' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='kingdom' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='kingdom' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='kingdom' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='kingdom' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='kingdom' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as kingdom,

  -- phylum
  case 
    when tdi0.Name='division' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='division' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='division' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='division' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='division' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='division' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='division' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='division' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='division' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='division' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='division' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='division' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='division' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as phylum,

  -- class
  case 
    when tdi0.Name='class' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='class' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='class' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='class' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='class' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='class' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='class' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='class' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='class' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='class' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='class' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='class' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='class' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as `class`,

  -- order
  case 
    when tdi0.Name='order' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='order' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='order' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='order' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='order' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='order' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='order' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='order' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='order' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='order' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='order' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='order' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='order' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as `order`,

  -- family
  case 
    when tdi0.Name='family' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='family' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='family' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='family' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='family' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='family' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='family' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='family' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='family' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='family' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='family' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='family' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='family' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as family,

  -- genus
  case 
    when tdi0.Name='genus' then t0.Name 
    when tdi1.Name='genus' then t1.Name 
    when tdi2.Name='genus' then t2.Name 
    when tdi3.Name='genus' then t3.Name 
    when tdi4.Name='genus' then t4.Name 
    when tdi5.Name='genus' then t5.Name 
    when tdi6.Name='genus' then t6.Name 
    when tdi7.Name='genus' then t7.Name 
    when tdi8.Name='genus' then t8.Name 
    when tdi9.Name='genus' then t9.Name 
    when tdi10.Name='genus' then t10.Name 
    when tdi11.Name='genus' then t11.Name 
    when tdi12.Name='genus' then t12.Name 
    else null 
  end as genus,

  -- specificEpithet
  case 
    when tdi0.Name='species' then t0.Name 
    when tdi1.Name='species' then t1.Name 
    when tdi2.Name='species' then t2.Name 
    else null 
  end as specificEpithet,

  -- infraspecificEpithet
  if (tdi0.RankID>220, t0.Name, null) as infraspecificEpithet,

  -- taxonRank
  replace(tdi0.Name, 'division', 'phylum') as taxonRank,

  -- taxonRemarks
  t0.Remarks as taxonRemarks,

  -- nomenclaturalCode
  'ICN' as nomenclaturalCode,

  -- nomenclaturalStatus
  t0.EsaStatus as nomenclaturalStatus

from collectionobject co
left join collectionobjectattribute coa 
  on co.CollectionObjectAttributeID=coa.CollectionObjectAttributeID
join collectingevent ce on co.CollectingEventID=ce.CollectingEventID
left join collectingtrip ctr ON ce.CollectingTripID=ctr.CollectingTripID
join locality l on ce.LocalityID=l.LocalityID

left join geography g0 on l.GeographyID=g0.GeographyID
left join geographytreedefitem gdi0 
  on g0.GeographyTreeDefItemID=gdi0.GeographyTreeDefItemID
left join geography g1 on g0.ParentID=g1.GeographyID
left join geographytreedefitem gdi1 
  on g1.GeographyTreeDefItemID=gdi1.GeographyTreeDefItemID
left join geography g2 on g1.ParentID=g2.GeographyID
left join geographytreedefitem gdi2 
  on g2.GeographyTreeDefItemID=gdi2.GeographyTreeDefItemID
left join geography g3 on g2.ParentID=g3.GeographyID
left join geographytreedefitem gdi3 
  on g3.GeographyTreeDefItemID=gdi3.GeographyTreeDefItemID
left join geography g4 on g3.ParentID=g4.GeographyID
left join geographytreedefitem gdi4 
  on g4.GeographyTreeDefItemID=gdi4.GeographyTreeDefItemID

left join localitydetail ld on l.LocalityID=ld.LocalityID
left join geocoorddetail gc on l.LocalityID=gc.LocalityID
left join agent gca on gc.AgentID=gca.AgentID
left join determination d on co.CollectionObjectID=d.CollectionObjectID 
    and d.IsCurrent=true
left join agent da on d.DeterminerID=da.AgentID

left join taxon t0 on d.TaxonID=t0.TaxonID
left join taxontreedefitem tdi0 on t0.TaxonTreeDefItemID=tdi0.TaxonTreeDefItemID
left join taxon t1 on t0.ParentID=t1.TaxonID
left join taxontreedefitem tdi1 on t1.TaxonTreeDefItemID=tdi1.TaxonTreeDefItemID
left join taxon t2 on t1.ParentID=t2.TaxonID
left join taxontreedefitem tdi2 on t2.TaxonTreeDefItemID=tdi2.TaxonTreeDefItemID
left join taxon t3 on t2.ParentID=t3.TaxonID
left join taxontreedefitem tdi3 on t3.TaxonTreeDefItemID=tdi3.TaxonTreeDefItemID
left join taxon t4 on t3.ParentID=t4.TaxonID
left join taxontreedefitem tdi4 on t4.TaxonTreeDefItemID=tdi4.TaxonTreeDefItemID
left join taxon t5 on t4.ParentID=t5.TaxonID
left join taxontreedefitem tdi5 on t5.TaxonTreeDefItemID=tdi5.TaxonTreeDefItemID
left join taxon t6 on t5.ParentID=t6.TaxonID
left join taxontreedefitem tdi6 on t6.TaxonTreeDefItemID=tdi6.TaxonTreeDefItemID
left join taxon t7 on t6.ParentID=t7.TaxonID
left join taxontreedefitem tdi7 on t7.TaxonTreeDefItemID=tdi7.TaxonTreeDefItemID
left join taxon t8 on t7.ParentID=t8.TaxonID
left join taxontreedefitem tdi8 on t8.TaxonTreeDefItemID=tdi8.TaxonTreeDefItemID
left join taxon t9 on t8.ParentID=t9.TaxonID
left join taxontreedefitem tdi9 on t9.TaxonTreeDefItemID=tdi9.TaxonTreeDefItemID
left join taxon t10 on t9.ParentID=t10.TaxonID
left join taxontreedefitem tdi10 
  on t10.TaxonTreeDefItemID=tdi10.TaxonTreeDefItemID
left join taxon t11 on t10.ParentID=t11.TaxonID
left join taxontreedefitem tdi11 
  on t11.TaxonTreeDefItemID=tdi11.TaxonTreeDefItemID
left join taxon t12 on t11.ParentID=t12.TaxonID
left join taxontreedefitem tdi12 
  on t12.TaxonTreeDefItemID=tdi12.TaxonTreeDefItemID

left join mel_avh_associated_sequences seq 
  on co.CollectionObjectID=seq.CollectionObjectID
where co.CollectionID=4