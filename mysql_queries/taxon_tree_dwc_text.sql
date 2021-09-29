drop view if exists taxon_tree_dwc_text;
create view taxon_tree_dwc_text as
select 
  t0.TaxonID as taxon_id,
  if(t0.FullName like '%[%', substring(t0.FullName, 1, locate(' [', t0.FullName)), 
      t0.FullName) as scientific_name, 
  t0.Author as scientific_name_authorship, 
  replace(tdi0.Name, 'division', 'phylum') as taxon_rank,
  case 
    when tdi0.Name='kingdom' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='kingdom' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='kingdom' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='kingdom' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='kingdom' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='kingdom' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='kingdom' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='kingdom' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='kingdom' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='kingdom' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='kingdom' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='kingdom' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='kingdom' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as kingdom,
  case 
    when tdi0.Name='division' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='division' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='division' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='division' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='division' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='division' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='division' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='division' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='division' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='division' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='division' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='division' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='division' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as phylum,
  case 
    when tdi0.Name='class' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='class' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='class' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='class' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='class' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='class' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='class' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='class' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='class' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='class' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='class' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='class' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='class' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as `class`,
  case 
    when tdi0.Name='order' and t0.Name!='Incertae sedis' then t0.Name 
    when tdi1.Name='order' and t1.Name!='Incertae sedis' then t1.Name 
    when tdi2.Name='order' and t2.Name!='Incertae sedis' then t2.Name 
    when tdi3.Name='order' and t3.Name!='Incertae sedis' then t3.Name 
    when tdi4.Name='order' and t4.Name!='Incertae sedis' then t4.Name 
    when tdi5.Name='order' and t5.Name!='Incertae sedis' then t5.Name 
    when tdi6.Name='order' and t6.Name!='Incertae sedis' then t6.Name 
    when tdi7.Name='order' and t7.Name!='Incertae sedis' then t7.Name 
    when tdi8.Name='order' and t8.Name!='Incertae sedis' then t8.Name 
    when tdi9.Name='order' and t9.Name!='Incertae sedis' then t9.Name 
    when tdi10.Name='order' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='order' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='order' and t12.Name!='Incertae sedis' then t12.Name 
    else null 
  end as `order`,
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
    when tdi10.Name='family' and t10.Name!='Incertae sedis' then t10.Name 
    when tdi11.Name='family' and t11.Name!='Incertae sedis' then t11.Name 
    when tdi12.Name='family' and t12.Name!='Incertae sedis' then t12.Name 
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
    when t12.TaxonID is not null and tdi12.Name!='life' then concat_ws(' | ', 
        if(t12.Name!='Incertae sedis', t12.Name, null), 
        if(t11.Name!='Incertae sedis', t11.Name, null), 
        if(t10.Name!='Incertae sedis', t10.Name, null), 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t11.TaxonID is not null and tdi11.Name!='life' then concat_ws(' | ', 
        if(t11.Name!='Incertae sedis', t11.Name, null), 
        if(t10.Name!='Incertae sedis', t10.Name, null), 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t10.TaxonID is not null and tdi10.Name!='life' then concat_ws(' | ', 
        if(t10.Name!='Incertae sedis', t10.Name, null), 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t9.TaxonID is not null and tdi9.Name!='life' then concat_ws(' | ', 
        if(t9.Name!='Incertae sedis', t9.Name, null), 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t8.TaxonID is not null and tdi8.Name!='life' then concat_ws(' | ', 
        if(t8.Name!='Incertae sedis', t8.Name, null), 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t7.TaxonID is not null and tdi7.Name!='life' then concat_ws(' | ', 
        if(t7.Name!='Incertae sedis', t7.Name, null), 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
    		if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t6.TaxonID is not null and tdi6.Name!='life' then concat_ws(' | ', 
        if(t6.Name!='Incertae sedis', t6.Name, null), 
        if(t5.Name!='Incertae sedis', t5.Name, null), 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t5.TaxonID is not null and tdi5.Name!='life' then concat_ws(' | ', 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t4.TaxonID is not null and tdi4.Name!='life' then concat_ws(' | ', 
        if(t4.Name!='Incertae sedis', t4.Name, null), 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t3.TaxonID is not null and tdi3.Name!='life' then concat_ws(' | ', 
        if(t3.Name!='Incertae sedis', t3.Name, null), 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t2.TaxonID is not null and tdi2.Name!='life' then concat_ws(' | ', 
        if(t2.Name!='Incertae sedis', t2.Name, null), 
        if(t1.Name!='Incertae sedis', t1.Name, null)
      )
    when t1.TaxonID is not null and tdi1.Name!='life' then 
        if(t1.Name!='Incertae sedis', t1.Name, null)
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