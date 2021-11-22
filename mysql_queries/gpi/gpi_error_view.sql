drop view if exists gpi_error;
create view gpi_error as
select 
  dco.GpiDatasetID as DatasetID,
  dco.CollectionObjectID,
  -- notAType
  if(ty.DeterminationID is null, 1, 0) as notAType,
  
  -- typeStatusIsCurrent
  if(ty.DeterminationID=cd.DeterminationID, 1, 0) 
    as typeStatusDeterminationIsCurrentDetermination,
  
  -- notABasionym
  err.notABasionym,
  
  -- noAuthor
  err.noAuthor,
  
  -- noSpecificEpithet
  err.noSpecificEpithet,
  
  -- noProtologue
  err.noProtologue,
  
  -- hasError
  if(
	  if(ty.DeterminationID is null, 1, 0)=1 or
    if(ty.DeterminationID=cd.DeterminationID, 1, 0)=1 or
	  err.notABasionym>0 or
	  err.noAuthor>0 or
    err.noSpecificEpithet>0 or
    err.noProtologue>0, 
    1, 0
  ) as hasError
  
from gpi_dataset_collectionobject dco
left join determination cd 
  on dco.CollectionObjectID=cd.CollectionObjectID and cd.IsCurrent=true
left join determination ty 
  on dco.CollectionObjectID=ty.CollectionObjectID and ty.YesNo1=true
left join (
  select 
    collectionObjectID, 
    sum(notABasionym) as notABasionym, sum(noAuthor) as noAuthor, 
    sum(noSpecificEpithet) as noSpecificEpithet, 
    sum(noProtologue) as noProtologue
  from (
    select
      d.CollectionObjectID,
      d.DeterminationID,
      
      -- notABasionym
      if (d.YesNo1=true and t0.Author like '(%', 1, 0) as notABasionym,
      
      -- noAuthor
      if (d.YesNo1=true and (t0.Author is null or trim(t0.Author)=''), 1, 0) 
        as noAuthor,
      
      -- noSpecificEpithet
      if(d.YesNo1=true and case 
          when tdi0.Name='species' then t0.Name 
          when tdi1.Name='species' then t1.Name 
          when tdi2.Name='species' then t2.Name 
          else null 
        end is null, 1, 0) as noSpecificEpithet,
      
      -- noProtologue
      if(t0.YesNo1=true and (t0.Author IS NULL OR t0.CommonName IS NULL 
        OR t0.Number2 IS NULL), 1, 0) as noProtologue

    from determination d
    left join taxon t0 on d.TaxonID=t0.TaxonID
    left join taxontreedefitem tdi0 
      on t0.TaxonTreeDefItemID=tdi0.TaxonTreeDefItemID
    left join taxon t1 on t0.ParentID=t1.TaxonID
    left join taxontreedefitem tdi1 
      on t1.TaxonTreeDefItemID=tdi1.TaxonTreeDefItemID
    left join taxon t2 on t1.ParentID=t2.TaxonID
    left join taxontreedefitem tdi2 
      on t2.TaxonTreeDefItemID=tdi2.TaxonTreeDefItemID  
    join gpi_dataset_collectionobject dco 
      on d.CollectionObjectID=dco.CollectionObjectID
  ) id_err
  group by CollectionObjectID
) as err on dco.CollectionObjectID=err.CollectionObjectID;