drop view if exists geography_tree_dwc_text;
create view geography_tree_dwc_text as
select 
  g0.GeographyID as geography_id,
  g0.Name as geography_name,
  lower(gdi0.Name) as geography_rank,
  case 
    when gdi0.Name='Continent' then map_continent(g0.Name) 
    when gdi1.Name='Continent' then map_continent(g1.Name) 
    when gdi2.Name='Continent' then map_continent(g2.Name) 
    when gdi3.Name='Continent' then map_continent(g3.Name) 
    when gdi4.Name='Continent' then map_continent(g4.Name) 
    else null 
  end as continent,
  case 
    when gdi0.Name='Country' AND g0.GeographyCode is not null then g0.Name 
    when gdi1.Name='Country' AND g1.GeographyCode is not null then g1.Name 
    when gdi2.Name='Country' AND g2.GeographyCode is not null then g2.Name 
    when gdi3.Name='Country' AND g3.GeographyCode is not null then g3.Name 
    when gdi4.Name='Country' AND g4.GeographyCode is not null then g4.Name 
    else null 
  end as country,
  case 
    when gdi0.Name='Country' then g0.GeographyCode 
    when gdi1.Name='Country' then g1.GeographyCode 
    when gdi2.Name='Country' then g2.GeographyCode 
    when gdi3.Name='Country' then g3.GeographyCode 
    when gdi4.Name='Country' then g4.GeographyCode 
    else null 
  end as country_code,
  case 
    when gdi0.Name='State' then g0.Name 
    when gdi1.Name='State' then g1.Name 
    when gdi2.Name='State' then g2.Name 
    when gdi3.Name='State' then g3.Name 
    when gdi4.Name='State' then g4.Name 
    else null 
  end as state_province,
  case 
    when gdi0.Name='County' then g0.Name 
    when gdi1.Name='County' then g1.Name 
    when gdi2.Name='County' then g2.Name 
    when gdi3.Name='County' then g3.Name 
    when gdi4.Name='County' then g4.Name 
    else null 
  end as county,
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
  end as higher_geography

from geography g0
join geographytreedefitem gdi0 
  on g0.GeographyTreeDefItemID=gdi0.GeographyTreeDefItemID
left join geography g1 on g0.ParentID=g1.GeographyID
left join geographytreedefitem gdi1 
  on g1.GeographyTreeDefItemID=gdi1.GeographyTreeDefItemID
left join geography g2 on g1.ParentID=g2.GeographyID
left join geographytreedefitem gdi2 
  on g2.GeographyTreeDefItemID=gdi2.GeographyTreeDefItemID
left join geography g3 on g2.ParentID=g3.GeographyID
left join geographytreedefitem gdi3 on 
  g3.GeographyTreeDefItemID=gdi3.GeographyTreeDefItemID
left join geography g4 on g3.ParentID=g4.GeographyID
left join geographytreedefitem gdi4 
  on g4.GeographyTreeDefItemID=gdi4.GeographyTreeDefItemID;