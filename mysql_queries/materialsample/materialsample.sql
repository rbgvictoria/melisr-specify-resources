/*
* Queries to implement Material Sample and changing Molecular Isolate 
* preparations into Material Samples
*/

insert into materialsample (TimestampCreated, TimestampModified, `Version`, CollectionMemberID, GGBNSampleDesignation, PreparationID, ExtractionDate, ExtractorID)
select now(), now(), 1, 4, mi.SampleNumber, coalesce(p2.PreparationID, p1.PreparationID, p3.PreparationID), mi.PreparedDate, mi.PreparedByID
from collectionobject co
join (
	select co.CollectionObjectID, co.CatalogNumber, p.SampleNumber, p.PreparedDate, p.PreparedByID
	from collectionobject co
	join preparation p on co.CollectionObjectID=p.CollectionObjectID
	join dnasequence dna on co.CollectionObjectID=dna.CollectionObjectID
	where p.PrepTypeID=27 and (p.SampleNumber is not null and p.SampleNumber!='')
	group by co.CollectionObjectID, p.PreparationID) as mi on co.CollectionObjectID=mi.CollectionObjectID
left join preparation p1 on co.CollectionObjectID=p1.CollectionObjectID and p1.PrepTypeID=1
left join preparation p2 on co.CollectionObjectID=p2.CollectionObjectID and p2.PrepTypeID=7
left join preparation p3 on co.CollectionObjectID=p3.CollectionObjectID and p3.PrepTypeID=4;

update dnasequence dna
join collectionobject co on dna.CollectionObjectID=co.CollectionObjectID
join preparation p on co.CollectionObjectID=p.CollectionObjectID
join materialsample ms on p.PreparationID=ms.PreparationID
set dna.MaterialSampleID=ms.MaterialSampleID
where dna.CollectionMemberID=4;

delete from preparation where PrepTypeID=27;
delete from preptype where PrepTypeID=27;

insert into materialsample (TimestampCreated, TimestampModified, `Version`, CollectionMemberID, GGBNSampleDesignation, PreparationID, ExtractorID, ExtractionDate)
select now(), now(), 1, 32769, p.SampleNumber, p.PreparationID, p.PreparedByID, p.PreparedDate
from preparation p
join collectionobject co on p.CollectionObjectID=co.CollectionObjectID
join dnasequence dna on co.CollectionObjectID=dna.CollectionObjectID
where PrepTypeID=28
group by p.PreparationID;

update dnasequence dna
join collectionobject co on dna.CollectionObjectID=co.CollectionObjectID
join preparation p on co.CollectionObjectID=p.CollectionObjectID
join materialsample ms on p.PreparationID=ms.PreparationID
set dna.MaterialSampleID=ms.MaterialSampleID
where dna.CollectionMemberID=32769;

create temporary table molecular_isolates_to_delete
select p.PreparationID
from preparation p
left join materialsample ms on p.PreparationID=ms.PreparationID
where p.PrepTypeID=28 and ms.MaterialSampleID is null;

alter table molecular_isolates_to_delete add index (PreparationID);

delete from preparation where PreparationID in (select PreparationID from molecular_isolates_to_delete);

drop table molecular_isolates_to_delete;

update preparation set PrepTypeID=20 where PrepTypeID=28;

delete from preptype where PrepTypeID=28;

update dnasequence set CollectionObjectID=null where MaterialSampleID is not null;

delete from preptype where PrepTypeID IN (88, 119);
