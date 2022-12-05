-- Change columns that were changed to decimals back to doubles

alter table locality 
	modify column ElevationAccuracy double,
	modify column LatLongAccuracy double,
	modify column MinElevation double, 
	modify column MaxElevation double;

alter table localitydetail 
	modify column StartDepth double,
	modify column EndDepth double;

alter table geocoorddetail 
	modify column GeoRefAccuracy double;

alter table attachmentimageattribute 
	modify column Magnification double,
	modify column Resolution double;
