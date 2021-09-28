/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 11/11/2020
 */
SELECT 
    occurrence_id as occurrenceID, 
    dc_type as "type", 
    dc_format as format, 
    identifier, 
    title, 
    description, 
    digitization_date as created,
    dc_creator, 
    provider_literal as publisher, 
    dcterms_rights as license, 
    `owner` as rightsHolder
FROM mel_avh_multimedia
