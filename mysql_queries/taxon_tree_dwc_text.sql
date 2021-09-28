drop view if exists taxon_tree_dwc_text;
create view taxon_tree_dwc_text as
select 
  t0.TaxonID as taxon_id,
  t0.FullName as scientific_name, 
  t0.Author as scientific_name_authorship, 
  tdi0.Name as taxonRank,
  case 
    when tdi0.Name='kingdom' then t0.Name 
    when tdi1.Name='kingdom' then t1.Name 
    when tdi2.Name='kingdom' then t2.Name 
    when tdi3.Name='kingdom' then t3.Name 
    when tdi4.Name='kingdom' then t4.Name 
    when tdi5.Name='kingdom' then t5.Name 
    when tdi6.Name='kingdom' then t6.Name 
    when tdi7.Name='kingdom' then t7.Name 
    when tdi8.Name='kingdom' then t8.Name 
    when tdi9.Name='kingdom' then t9.Name 
    when tdi10.Name='kingdom' then t10.Name 
    when tdi11.Name='kingdom' then t11.Name 
    when tdi12.Name='kingdom' then t12.Name 
    else null 
  end as kingdom,
  case 
    when tdi0.Name='division' then t0.Name 
    when tdi1.Name='division' then t1.Name 
    when tdi2.Name='division' then t2.Name 
    when tdi3.Name='division' then t3.Name 
    when tdi4.Name='division' then t4.Name 
    when tdi5.Name='division' then t5.Name 
    when tdi6.Name='division' then t6.Name 
    when tdi7.Name='division' then t7.Name 
    when tdi8.Name='division' then t8.Name 
    when tdi9.Name='division' then t9.Name 
    when tdi10.Name='division' then t10.Name 
    when tdi11.Name='division' then t11.Name 
    when tdi12.Name='division' then t12.Name 
    else null 
  end as phylum,
  case 
    when tdi0.Name='class' then t0.Name 
    when tdi1.Name='class' then t1.Name 
    when tdi2.Name='class' then t2.Name 
    when tdi3.Name='class' then t3.Name 
    when tdi4.Name='class' then t4.Name 
    when tdi5.Name='class' then t5.Name 
    when tdi6.Name='class' then t6.Name 
    when tdi7.Name='class' then t7.Name 
    when tdi8.Name='class' then t8.Name 
    when tdi9.Name='class' then t9.Name 
    when tdi10.Name='class' then t10.Name 
    when tdi11.Name='class' then t11.Name 
    when tdi12.Name='class' then t12.Name 
    else null 
  end as `class`,
  case 
    when tdi0.Name='order' then t0.Name 
    when tdi1.Name='order' then t1.Name 
    when tdi2.Name='order' then t2.Name 
    when tdi3.Name='order' then t3.Name 
    when tdi4.Name='order' then t4.Name 
    when tdi5.Name='order' then t5.Name 
    when tdi6.Name='order' then t6.Name 
    when tdi7.Name='order' then t7.Name 
    when tdi8.Name='order' then t8.Name 
    when tdi9.Name='order' then t9.Name 
    when tdi10.Name='order' then t10.Name 
    when tdi11.Name='order' then t11.Name 
    when tdi12.Name='order' then t12.Name 
    else null 
  end as `order`,
  case 
    when tdi0.Name='family' then t0.Name 
    when tdi1.Name='family' then t1.Name 
    when tdi2.Name='family' then t2.Name 
    when tdi3.Name='family' then t3.Name 
    when tdi4.Name='family' then t4.Name 
    when tdi5.Name='family' then t5.Name 
    when tdi6.Name='family' then t6.Name 
    when tdi7.Name='family' then t7.Name 
    when tdi8.Name='family' then t8.Name 
    when tdi9.Name='family' then t9.Name 
    when tdi10.Name='family' then t10.Name 
    when tdi11.Name='family' then t11.Name 
    when tdi12.Name='family' then t12.Name 
    else null 
  end as family,
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
    when tdi10.Name='genus' then t10.Name 
    when tdi11.Name='genus' then t11.Name 
    when tdi12.Name='genus' then t12.Name 
    else null 
  end as genus,
  case 
    when tdi0.Name='species' then t0.Name 
    when tdi1.Name='species' then t1.Name 
    when tdi2.Name='species' then t2.Name 
    else null 
  end as specific_epithet,
  if (tdi0.RankID>220, t0.Name, null) as infraspecific_epithet,
  case
    when t12.TaxonID is not null and tdi12.Name!='life'
      then concat_ws(' | ', t12.Name, t11.Name, t10.Name, t9.Name, t8.Name, 
        t7.Name, t6.Name, t5.Name, t4.Name, t3.Name, t2.Name, t1.Name)
    when t11.TaxonID is not null and tdi11.Name!='life'
      then concat_ws(' | ', t11.Name, t10.Name, t9.Name, t8.Name, t7.Name, 
        t6.Name, t5.Name, t4.Name, t3.Name, t2.Name, t1.Name)
    when t10.TaxonID is not null and tdi10.Name!='life'
      then concat_ws(' | ', t10.Name, t9.Name, t8.Name, t7.Name, t6.Name, 
        t5.Name, t4.Name, t3.Name, t2.Name, t1.Name)
    when t9.TaxonID is not null and tdi9.Name!='life'
      then concat_ws(' | ', t9.Name, t8.Name, t7.Name, t6.Name, t5.Name, 
        t4.Name, t3.Name, t2.Name, t1.Name)
    when t8.TaxonID is not null and tdi8.Name!='life'
      then concat_ws(' | ', t8.Name, t7.Name, t6.Name, t5.Name, t4.Name, 
        t3.Name, t2.Name, t1.Name)
    when t7.TaxonID is not null and tdi7.Name!='life'
      then concat_ws(' | ', t7.Name, t6.Name, t5.Name, t4.Name, t3.Name, 
        t2.Name, t1.Name)
    when t6.TaxonID is not null and tdi6.Name!='life'
      then concat_ws(' | ', t6.Name, t5.Name, t4.Name, t3.Name, t2.Name, 
        t1.Name)
    when t5.TaxonID is not null and tdi5.Name!='life'
      then concat_ws(' | ', t4.Name, t3.Name, t2.Name, t1.Name)
    when t4.TaxonID is not null and tdi4.Name!='life'
      then concat_ws(' | ', t4.Name, t3.Name, t2.Name, t1.Name)
    when t3.TaxonID is not null and tdi3.Name!='life'
      then concat_ws(' | ', t3.Name, t2.Name, t1.Name)
    when t2.TaxonID is not null and tdi2.Name!='life'
      then concat_ws(' | ', t2.Name, t1.Name)
    when t1.TaxonID is not null and tdi1.Name!='life'
      then t1.Name
    else null
  end as higher_classification
  
from taxon t0
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
left join taxon t10 on t9.ParentID=t10.TaxonID
left join taxontreedefitem tdi10 
  on t10.TaxonTreeDefItemID=tdi10.TaxonTreeDefItemID
left join taxon t11 on t10.ParentID=t11.TaxonID
left join taxontreedefitem tdi11 
  on t11.TaxonTreeDefItemID=tdi11.TaxonTreeDefItemID
left join taxon t12 on t11.ParentID=t12.TaxonID
left join taxontreedefitem tdi12 
  on t12.TaxonTreeDefItemID=tdi12.TaxonTreeDefItemID;