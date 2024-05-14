/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 12/11/2020
 */
DROP function IF EXISTS `previous_identifications`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `melisr`.`previous_identifications`(in_collection_object_id INTEGER) RETURNS text CHARSET utf8 COLLATE utf8_general_ci
BEGIN
	DECLARE out_previous_identifications TEXT;
	select 
	  group_concat(identification_string(concat_ws(', ', concat_ws(' ', if(d.Qualifier is not null, fn_verbatim_identification(d.DeterminationID), if(t.FullName LIKE '% [%' , substring(t.FullName, 1, LOCATE(' [', t.FullName)-1), t.FullName)), t.author), t.EsaStatus), 
		concat_ws(' ', a.LastName, a.FirstName), dateWithPrecision(d.DeterminedDate, d.DeterminedDatePrecision), d.Remarks) SEPARATOR ' | ') as previousIdentifications
	into out_previous_identifications
	from determination d
	join taxon t on d.TaxonID=t.TaxonID
	left join agent a on d.DeterminerID=a.AgentID
	where d.CollectionObjectID=in_collection_object_id and (d.IsCurrent=false or d.IsCurrent is null) and (d.FeatureOrBasis!='Type status' or d.FeatureOrBasis is null)
	group by d.CollectionObjectID;
RETURN out_previous_identifications;
END$$

DELIMITER ;

