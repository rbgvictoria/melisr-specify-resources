drop view if exists gpi_unit;
create view gpi_unit as
select 
  -- CollectionObjectID
  co.CollectionObjectID,

  -- UnitID
  concat('MEL', co.AltCatalogNumber, replace(co.Modifier, 'A', ''))
    as UnitID,

  -- DateLAstModified
  date(co.TimestampModified) as DateLastModified,

  -- Collectors
  collectorstring(ce.CollectingEventID, '; ', null) as Collectors,

  -- CollectorNumber
  ce.StationFieldNumber as CollectorNumber,

  -- CollectionDate
  if(ce.StartDatePrecision=1, dayofmonth(ce.StartDate), null) 
    as CollectionDateStartDay,
  if(ce.StartDatePrecision<3, month(ce.StartDate), null) 
    as CollectionDateStartMonth,
  year(ce.StartDate) as CollectionDateStartYear,
  if(ce.EndDatePrecision=1, dayofmonth(ce.EndDate), null) 
    as CollectionDateEndDay,
  if(ce.EndDatePrecision<3, month(ce.EndDate), null) as CollectionDateEndMonth,
  year(ce.EndDate) as CollectionDateEndYear,
  case 
      when cea.Text6 is not null then cea.Text6 
      when ce.StartDate is null then 'Not on sheet' 
      else null 
    end as CollectionDateOtherText,

  -- UnitTypeStatus
  null as UnitTypeStatus,
  
  -- CountryName
  case 
    when gdi0.Name='Country' AND g0.GeographyCode is not null then g0.Name 
    when gdi1.Name='Country' AND g1.GeographyCode is not null then g1.Name 
    when gdi2.Name='Country' AND g2.GeographyCode is not null then g2.Name 
    when gdi3.Name='Country' AND g3.GeographyCode is not null then g3.Name 
    when gdi4.Name='Country' AND g4.GeographyCode is not null then g4.Name 
    else null 
  end as CountryName,

  -- ISO2Letter
  case 
    when gdi0.Name='Country' then g0.GeographyCode 
    when gdi1.Name='Country' then g1.GeographyCode 
    when gdi2.Name='Country' then g2.GeographyCode 
    when gdi3.Name='Country' then g3.GeographyCode 
    when gdi4.Name='Country' then g4.GeographyCode 
    else null 
  end as ISO2Letter,
  
  -- Locality
  l.LocalityName as Locality,
  
  -- Altitude
  CASE l.Text1 
    WHEN 'ft' THEN round(l.MinElevation * 0.3048) 
    ELSE l.MinElevation 
  END as Altitude,
  
  -- Notes
  null as Notes

from collectionobject co
join collectingevent ce on co.CollectingEventID=ce.CollectingEventID
left join collectingeventattribute cea 
  on ce.CollectingEventAttributeID=cea.CollectingEventAttributeID
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
where co.CollectionID=4;