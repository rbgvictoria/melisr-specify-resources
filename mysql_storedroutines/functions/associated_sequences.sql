/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 12/11/2020
 */
DROP function IF EXISTS `associated_sequences`;

DELIMITER $$
USE `melisr`$$
CREATE DEFINER=`admin`@`%` FUNCTION `associated_sequences`(in_collection_object_id int) RETURNS varchar(256) CHARSET utf8
BEGIN
	DECLARE out_associated_sequences varchar(256);
    
	select group_concat(concat('https://www.ncbi.nlm.nih.gov/nuccore/', coalesce(dna1.GenBankAccessionNumber, dna2.GenBankAccessionNumber)) SEPARATOR ' | ')
    into out_associated_sequences
	from collectionobject co
	left join dnasequence dna1 on co.CollectionObjectID=dna1.CollectionObjectID
	left join preparation p on co.CollectionObjectID=p.CollectionObjectID
	left join materialsample ms on p.PreparationID=ms.PreparationID
	left join dnasequence dna2 on ms.MaterialSampleID=dna2.MaterialSampleID
	where (dna1.DNASequenceID is not null or dna2.DNASequenceID is not null) and co.CollectionObjectID=in_collection_object_id
	group by co.CollectionObjectID;
    
    RETURN out_associated_sequences;
END$$

DELIMITER ;

