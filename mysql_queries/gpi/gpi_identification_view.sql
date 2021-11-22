drop view if exists gpi_identification;
create view gpi_identification as
select 
  d.CollectionObjectID,
  d.DeterminationID as IdentificationID,
  
  -- Family
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
    else null 
  end as Family,

  -- Genus
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
    else null 
  end as Genus,

  -- SpecificEpithet
  case 
    when tdi0.Name='species' then t0.Name 
    when tdi1.Name='species' then t1.Name 
    when tdi2.Name='species' then t2.Name 
    else null 
  end as SpecificEpithet,

  -- InfraspecificRank
  if (tdi0.RankID>220, tdi0.TextBefore, null) as InfraspecificRank,

  -- InfraspecificEpithet
  if (tdi0.RankID>220, t0.Name, null) as InfraspecificEpithet,

  -- Author
  t0.Author,
  
  -- Identifier
  if (a.LastName is not null, 
    concat_ws(', ', a.LastName, a.FirstName), 'Not on sheet') as Identifier,
  
  -- IdentificationDate
  if(d.DeterminedDatePrecision=1, dayofmonth(d.DeterminedDate), null) 
    as IdentificationDateStartDay,
  if(d.DeterminedDatePrecision<3, month(d.DeterminedDate), null) 
    as IdentificationDateStartMonth,
  year(d.DeterminedDate) as IdentificationDateStartYear,
  if(d.DeterminedDate is null, 'Not on sheet', null) 
    as IdentificationDateOtherText,
  
  -- TypeStatus
  if (d.YesNo1=true, if(d.VarQualifier is null, 
    case d.TypeStatusName
      when 'Paralectotype' then 'Syntype'
      when 'Paraneotype' then 'Syntype'
      else d.TypeStatusName
    end,
    'Type ?'
  ), null) as TypeStatus,
  
  -- StoredUnder
  d.YesNo1=true as StoredUnder,
  
  -- CurrentDetermination
  d.IsCurrent=true as CurrentDetermination

  
from determination d
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

left join agent a on d.DeterminerID=a.AgentID
where d.IsCurrent=true or (d.FeatureOrBasis='Type status' and d.YesNo1=true 
  and d.TypeStatusName not in ('Authentic specimen'));