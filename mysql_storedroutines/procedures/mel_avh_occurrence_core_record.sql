/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 14/04/2019
 */
DELIMITER $$

DROP PROCEDURE IF EXISTS `melisr`.`mel_avh_occurrence_core_record` $$
CREATE PROCEDURE `melisr`.`mel_avh_occurrence_core_record` (in_col_obj_id INT(11))
BEGIN

    DECLARE var_institution_code VARCHAR(64) DEFAULT 'MEL';
    DECLARE var_collection_code VARCHAR(50) DEFAULT 'MEL';
    DECLARE var_catalog_number VARCHAR(32);
    DECLARE var_occurrence_id VARCHAR(128);
    DECLARE var_recorded_by TEXT;
    DECLARE var_record_number VARCHAR(50);
    DECLARE var_event_date DATE;
    DECLARE var_year INT(11);
    DECLARE var_month INT(11);
    DECLARE var_day INT(11);
    DECLARE var_verbatim_event_date VARCHAR(50);
    DECLARE var_habitat TEXT;
    DECLARE var_continent VARCHAR(500);
    DECLARE var_country VARCHAR(500);
    DECLARE var_state_province VARCHAR(500);
    DECLARE var_waterbody VARCHAR(64);
    DECLARE var_island_group VARCHAR(64);
    DECLARE var_island VARCHAR(64);
    DECLARE var_verbatim_locality VARCHAR(255);
    DECLARE var_geodetic_datum VARCHAR(50);
    DECLARE var_decimal_latitude VARCHAR(20);
    DECLARE var_decimal_longitude VARCHAR(20);
    DECLARE var_verbatim_latitude VARCHAR(50);
    DECLARE var_verbatim_longitude VARCHAR(50);
    DECLARE var_georeference_protocol VARCHAR(50);
    DECLARE var_coordinate_uncertainty_in_meters VARCHAR(50);
    DECLARE var_minimum_elevation_in_meters DOUBLE;
    DECLARE var_maximum_elevation_in_meters DOUBLE;
    DECLARE var_verbatim_elevation VARCHAR(50);
    DECLARE var_minimum_depth_in_meters DOUBLE;
    DECLARE var_maximum_depth_in_meters DOUBLE;
    DECLARE var_georeferenced_by VARCHAR(500);
    DECLARE var_georeferenced_date DATE;
    DECLARE var_georeference_remarks TEXT;
    DECLARE var_scientific_name VARCHAR(255);
    DECLARE var_scientific_name_authorship VARCHAR(128);
    DECLARE var_taxon_rank VARCHAR(64);
    DECLARE var_kingdom VARCHAR(500);
    DECLARE var_phylum VARCHAR(500);
    DECLARE var_class VARCHAR(500);
    DECLARE var_order VARCHAR(500);
    DECLARE var_family VARCHAR(500);
    DECLARE var_genus VARCHAR(50);
    DECLARE var_specific_epithet VARCHAR(500);
    DECLARE var_infraspecific_epithet VARCHAR(500);
    DECLARE var_taxon_remarks TEXT;
    DECLARE var_identified_by VARCHAR(500);
    DECLARE var_identification_qualifier TEXT;
    DECLARE var_date_identified DATE;
    DECLARE var_identification_remarks TEXT;
    DECLARE var_type_status VARCHAR(255);
    DECLARE var_associated_sequences TEXT;

    DECLARE var_county VARCHAR(500);
    DECLARE var_modified DATETIME;
    DECLARE var_identification_id VARCHAR(128);

    DECLARE var_geography_node_number INT(11);
    DECLARE var_geography_rank VARCHAR(16);
    DECLARE var_geography_name VARCHAR(500);
    DECLARE var_taxon_node_number INT(11);
    DECLARE var_taxonomy_rank VARCHAR(16);
    DECLARE var_taxonomy_name VARCHAR(500);

    SELECT co.CatalogNumber as var_catalog_number,
        co.GUID as var_occurrence_id,
        collectorString(ce.CollectingEventID, true) as var_recorded_by,
        ce.StationFieldNumber as var_record_number,
        mysqlDateWithPrecision(ce.StartDate, ce.StartDatePrecision) as var_event_date,
        year(ce.StartDate) as var_year, if(ce.StartDatePrecision<3, 
        month(ce.StartDate), NULL) as var_month,
        if(ce.StartDatePrecision<2, day(ce.StartDate), NULL) as var_day,
        cea.Text6 as var_verbatim_event_date,
        ce.Remarks as var_habitat,
        ld.Waterbody as var_waterbody,
        ld.IslandGroup as var_island_group,
        ld.Island as var_island,
        l.LocalityName as var_verbatim_locality,
        l.Datum as var_geodetic_datum,
        l.Latitude1 as var_decimal_latitude,
        l.Longitude1 as var_decimal_longitude,
        l.Lat1Text as var_verbatim_latitude,
        l.Long1Text as var_verbatim_longitude,
        l.LatLongMethod as var_georeference_protocol,
        l.OriginalElevationUnit as var_coordinate_uncertainty_in_meters,
        l.MinElevation as var_minimum_elevation_in_meters,
        l.MaxElevation as var_maximum_elevation_in_meters,
        l.VerbatimElevation as var_verbatim_elevation,
        ld.StartDepth as var_minimum_depth_in_meters,
        ld.EndDepth as var_maximum_depth_in_meters,
        agentName(gd.AgentID) as var_georeferenced_by,
        gd.GeoRefDetDate as var_georeferenced_date,
        gd.GeoRefRemarks as var_georeference_remarks,
        if (t.FullName LIKE '%[%', substring(t.FullName, 1, locate(' [', t.FullName)-1), t.FullName) as var_scientific_name,
        t.Author as var_scientific_name_authorship,
        td.Name as var_taxon_rank,
        t.Remarks as var_taxon_remarks,
        agentName(d.DeterminerID) as var_identified_by,
        mysqlDateWithPrecision(d.DeterminedDate, d.DeterminedDatePrecision) as var_date_identified,
        d.Text1 as var_identification_qualifier,
        d.Remarks as var_identification_remarks,
        co.Description as var_type_status,
        t.NodeNumber as var_taxon_node_number,
        g.NodeNumber as var_geography_node_number,
        d.GUID as var_identification_id,
        co.TimestampModified as var_modified
    INTO var_catalog_number,
        var_occurrence_id,
        var_recorded_by,
        var_record_number,
        var_event_date,
        var_year,
        var_month,
        var_day,
        var_verbatim_event_date,
        var_habitat,
        var_waterbody,
        var_island_group,
        var_island,
        var_verbatim_locality,
        var_geodetic_datum,
        var_decimal_latitude,
        var_decimal_longitude,
        var_verbatim_latitude,
        var_verbatim_longitude,
        var_georeference_protocol,
        var_coordinate_uncertainty_in_meters,
        var_minimum_elevation_in_meters,
        var_maximum_elevation_in_meters,
        var_verbatim_elevation,
        var_minimum_depth_in_meters,
        var_maximum_depth_in_meters,
        var_georeferenced_by,
        var_georeferenced_date,
        var_georeference_remarks,
        var_scientific_name,
        var_scientific_name_authorship,
        var_taxon_rank,
        var_taxon_remarks,
        var_identified_by,
        var_date_identified,
        var_identification_qualifier,
        var_identification_remarks,
        var_type_status,
        var_taxon_node_number,
        var_geography_node_number,
        var_identification_id,
        var_modified
    FROM collectionobject co
    JOIN collectingevent ce ON co.CollectingEventID=ce.CollectingEventID
    JOIN locality l ON ce.LocalityID=l.LocalityID
    JOIN geography g ON l.GeographyID=g.GeographyID
    JOIN determination d ON co.CollectionObjectID=d.CollectionObjectID AND d.IsCurrent=true
    JOIN taxon t ON d.TaxonID=t.TaxonID
    JOIN taxontreedefitem td ON t.TaxonTreeDefItemID=td.TaxonTreeDefItemID
    LEFT JOIN collectionobjectattribute coa ON co.CollectionObjectAttributeID=coa.CollectionObjectAttributeID
    LEFT JOIN collectingeventattribute cea ON ce.CollectingEventAttributeID=cea.CollectingEventAttributeID
    LEFT JOIN localitydetail ld ON l.LocalityID=ld.LocalityID
    LEFT JOIN geocoorddetail gd ON l.LocalityID=gd.LocalityID
    WHERE co.CollectionObjectID=in_col_obj_id;

    -- Higher geography
    higher_geography: BEGIN
        DECLARE var_finished INT DEFAULT 0;

        DEClARE higher_geography_cursor CURSOR FOR 
        SELECT gd.Name as var_geography_rank, g.Name as var_geography_name
        FROM geography g
        JOIN geographytreedefitem gd ON g.GeographyTreeDefItemID=gd.GeographyTreeDefItemID
        WHERE g.GeographyTreeDefID=1 AND g.NodeNumber <= var_geography_node_number AND g.HighestChildNodeNumber >= var_geography_node_number;

        DECLARE CONTINUE HANDLER 
            FOR NOT FOUND SET var_finished = 1;

        OPEN higher_geography_cursor;
        get_higher_geography: LOOP
            FETCH higher_geography_cursor
            INTO var_geography_rank, var_geography_name;

            CASE var_geography_rank
                WHEN 'Continent' THEN 
                    SET var_continent = var_geography_name;
                WHEN 'Country' THEN 
                    SET var_country = var_geography_name;
                WHEN 'State' THEN 
                    SET var_state_province = var_geography_name;
                WHEN 'County' THEN 
                    SET var_county = var_geography_name;
                ELSE BEGIN END;
            END CASE;

            IF var_finished = 1 THEN
                LEAVE get_higher_geography;
            END IF;
        END LOOP get_higher_geography;
        CLOSE higher_geography_cursor;
    END higher_geography;

    -- Higher taxonomy
    higher_taxonomy: BEGIN
        DECLARE var_finished INT DEFAULT 0;

        DEClARE higher_taxonomy_cursor CURSOR FOR 
        SELECT td.Name as var_taxonomy_rank, t.Name as var_taxonomy_name
        FROM taxon t
        JOIN taxontreedefitem td ON t.TaxonTreeDefItemID=td.TaxonTreeDefItemID
        WHERE t.NodeNumber <= var_taxon_node_number AND t.HighestChildNodeNumber >= var_taxon_node_number;

        DECLARE CONTINUE HANDLER 
            FOR NOT FOUND SET var_finished = 1;

        OPEN higher_taxonomy_cursor;
        get_higher_taxonomy: LOOP
            FETCH higher_taxonomy_cursor
            INTO var_taxonomy_rank, var_taxonomy_name;

            CASE var_taxonomy_rank
                WHEN 'kingdom' THEN 
                    SET var_kingdom = var_taxonomy_name;
                WHEN 'division' THEN 
                    SET var_phylum = var_taxonomy_name;
                WHEN 'class' THEN 
                    SET var_class = var_taxonomy_name;
                WHEN 'order' THEN 
                    SET var_order = var_taxonomy_name;
                WHEN 'family' THEN 
                    SET var_family = var_taxonomy_name;
                WHEN 'genus' THEN 
                    SET var_genus = var_taxonomy_name;
                WHEN 'species' THEN 
                    SET var_specific_epithet = var_taxonomy_name;
                WHEN 'subspecies' THEN 
                    SET var_infraspecific_epithet = var_taxonomy_name;
                WHEN 'variety' THEN 
                    SET var_infraspecific_epithet = var_taxonomy_name;
                WHEN 'subvariety' THEN 
                    SET var_infraspecific_epithet = var_taxonomy_name;
                WHEN 'forma' THEN 
                    SET var_infraspecific_epithet = var_taxonomy_name;
                WHEN 'subforma' THEN 
                    SET var_infraspecific_epithet = var_taxonomy_name;
                ELSE BEGIN END;
            END CASE;

            IF var_finished = 1 THEN
                LEAVE get_higher_taxonomy;
            END IF;
        END LOOP get_higher_taxonomy;
        CLOSE higher_taxonomy_cursor;
    END higher_taxonomy;

    associated_sequences: BEGIN
        DECLARE var_genbank_accession_number VARCHAR(128);
        DECLARE var_finished INT DEFAULT 0;
        
        DECLARE associated_sequences_cursor CURSOR FOR
        SELECT GenBankAccessionNumber
        FROM dnasequence
        WHERE CollectionObjectID=in_col_obj_id;

        DECLARE CONTINUE HANDLER 
            FOR NOT FOUND SET var_finished = 1;

        OPEN associated_sequences_cursor;
        get_genbank_accession_numbers: LOOP
            FETCH associated_sequences_cursor
            INTO var_genbank_accession_number;

            SET var_genbank_accession_number = CONCAT('https://www.ncbi.nlm.nih.gov/nuccore/', var_genbank_accession_number);

            IF var_associated_sequences IS NULL THEN
                SET var_associated_sequences = var_genbank_accession_number;
            ELSE
                SET var_associated_sequences = CONCAT_WS(' | ', var_associated_sequences, var_genbank_accession_number);
            END IF;

            IF var_finished = 1 THEN
                LEAVE get_genbank_accession_numbers;
            END IF;
        END LOOP get_genbank_accession_numbers;
        CLOSE associated_sequences_cursor;
    END associated_sequences;

    REPLACE INTO mel_avh_occurrence_core_test (
        `mel_avh_occurrence_coreId`,
        `institutionCode`,
        `collectionCode`,
        `catalogNumber`,
        `occurrenceId`,
        `recordedBy`,
        `recordNumber`,
        `eventDate`,
        `year`,
        `month`,
        `day`,
        `verbatimEventDate`,
        `habitat`,
        `waterbody`,
        `islandGroup`,
        `island`,
        `verbatimLocality`,
        `geodeticDatum`,
        `decimalLatitude`,
        `decimalLongitude`,
        `verbatimLatitude`,
        `verbatimLongitude`,
        `georeferenceProtocol`,
        `coordinateUncertaintyInMeters`,
        `minimumElevationInMeters`,
        `maximumElevationInMeters`,
        `verbatimElevation`,
        `minimumDepthInMeters`,
        `maximumDepthInMeters`,
        `georeferencedBy`,
        `georeferencedDate`,
        `georeferenceRemarks`,
        `scientificName`,
        `scientificNameAuthorship`,
        `taxonRank`,
        `taxonRemarks`,
        `identifiedBy`,
        `dateIdentified`,
        `identificationQualifier`,
        `identificationRemarks`,
        `typeStatus`,

        `country`,
        `stateProvince`,

        `kingdom`,
        `phylum`,
        `class`,
        `order`,
        `family`,
        `genus`,
        `specificEpithet`,
        
        `associatedSequences`,

        `continent`,
        `county`,
        `identificationID`,
        `modified`
    )
    VALUES (in_col_obj_id,
        var_institution_code,
        var_collection_code,
        var_catalog_number,
        var_occurrence_id,
        var_recorded_by,
        var_record_number,
        var_event_date,
        var_year,
        var_month,
        var_day,
        var_verbatim_event_date,
        var_habitat,
        var_waterbody,
        var_island_group,
        var_island,
        var_verbatim_locality,
        var_geodetic_datum,
        var_decimal_latitude,
        var_decimal_longitude,
        var_verbatim_latitude,
        var_verbatim_longitude,
        var_georeference_protocol,
        var_coordinate_uncertainty_in_meters,
        var_minimum_elevation_in_meters,
        var_maximum_elevation_in_meters,
        var_verbatim_elevation,
        var_minimum_depth_in_meters,
        var_maximum_depth_in_meters,
        var_georeferenced_by,
        var_georeferenced_date,
        var_georeference_remarks,
        var_scientific_name,
        var_scientific_name_authorship,
        var_taxon_rank,
        var_taxon_remarks,
        var_identified_by,
        var_date_identified,
        var_identification_qualifier,
        var_identification_remarks,
        var_type_status,

        var_country,
        var_state_province,

        var_kingdom,
        var_phylum,
        var_class,
        var_order,
        var_family,
        var_genus,
        var_specific_epithet,

        var_associated_sequences,

        var_continent,
        var_county,
        var_identification_id,
        var_modified
    );
END $$

DELIMITER ;
