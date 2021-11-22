drop view if exists colmngmt_mel_storage_view;
create view colmngmt_mel_storage_view as
select 
  s.StorageID,
  s.`Name` as StorageName,
  substring_index(reverse(substring_index(reverse(s.FullName), ' – ', 2)), ' – ', 1) as major_group,
  if (s.`Name`!=substring_index(reverse(substring_index(reverse(s.FullName), ' – ', 2)), ' – ', 1), s.Name, null) as subgroup,
  reverse(substring_index(reverse(s.FullName), ' – ', 1)) as collection, 
  count(distinct au.CollectionObjectID) as australian_collections,
  count(distinct f.CollectionObjectID) as foreign_collections,
  count(distinct cul.CollectionObjectID) as cultivated_collections
from `storage` s
join preparation p on s.StorageID=p.StorageID
left join (
  select co.CollectionObjectID
  from collectionobject co
  join collectingevent ce on co.CollectingEventID=ce.CollectingEventID
  join locality l on ce.LocalityID=l.LocalityID
  join geography g on l.GeographyID=g.GeographyID
  where co.CollectionID=4 and g.FullName like '%Australia%'
) au on p.CollectionObjectID=au.CollectionObjectID
left join (
  select co.CollectionObjectID
  from collectionobject co
  join collectingevent ce on co.CollectingEventID=ce.CollectingEventID
  join locality l on ce.LocalityID=l.LocalityID
  join geography g on l.GeographyID=g.GeographyID
  where co.CollectionID=4 and g.FullName not like '%Australia%' and g.FullName not like '%Cultivated%'
) f on p.CollectionObjectID=f.CollectionObjectID
left join (
  select co.CollectionObjectID
  from collectionobject co
  join collectingevent ce on co.CollectingEventID=ce.CollectingEventID
  join locality l on ce.LocalityID=l.LocalityID
  join geography g on l.GeographyID=g.GeographyID
  where co.CollectionID=4 and g.FullName like '%Cultivated%'
) cul on p.CollectionObjectID=cul.CollectionObjectID
group by s.StorageID
order by major_group, subgroup, collection;

drop view if exists colmngmt_mel_storage_pivot_view;
create view colmngmt_mel_storage_pivot_view as
select 
  ms.`Name`, 
  substring_index(reverse(substring_index(reverse(ms.FullName), ' – ', 2)), ' – ', 1) as major_group,
  if (ms.`Name`!=substring_index(reverse(substring_index(reverse(ms.FullName), ' – ', 2)), ' – ', 1), ms.Name, null) as subgroup,
  coalesce(mst.australian_collections, 0) as australian_collections, 
  coalesce(tst.australian_collections, 0) as australian_types,
  coalesce(mst.foreign_collections, 0) as foreign_collections,
  coalesce(tst.foreign_collections, 0) as foreign_types,
  coalesce(mst.cultivated_collections, 0) as cultivated_collections
from `storage` ms 
left join `storage` ts on ms.FullName=replace(ts.FullName, 'Types', 'Main collection') and ms.StorageID!=ts.StorageID
left join colmngmt_mel_storage mst on ms.StorageID=mst.StorageID
left join colmngmt_mel_storage tst on ts.StorageID=tst.StorageID
where ms.FullName like '%Main collection'
order by major_group, subgroup;
