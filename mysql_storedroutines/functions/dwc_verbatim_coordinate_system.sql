DROP FUNCTION IF EXISTS melisr.dwc_verbatim_coordinate_system;

DELIMITER $$
$$
CREATE FUNCTION melisr.dwc_verbatim_coordinate_system(in_lat VARCHAR(32), in_lng VARCHAR(32))
RETURNS VARCHAR(32)
BEGIN
	DECLARE out_verbatim_coordinate_system VARCHAR(32);

	CASE
		WHEN LENGTH(in_lat)-LENGTH(REPLACE(in_lat, ' ', '')) = 3 OR LENGTH(in_lng)-LENGTH(REPLACE(in_lng, ' ', '')) = 3 THEN
			SET out_verbatim_coordinate_system='degrees minutes seconds';
		WHEN LENGTH(in_lat)-LENGTH(REPLACE(in_lat, ' ', '')) = 2 OR LENGTH(in_lng)-LENGTH(REPLACE(in_lng, ' ', '')) = 2 THEN
			SET out_verbatim_coordinate_system='degrees decimal minutes';
		WHEN in_lat IS NOT NULL AND in_lng IS NOT NULL THEN
			SET out_verbatim_coordinate_system='decimal degrees';
		ELSE SET out_verbatim_coordinate_system=NULL;
	END CASE;
	
	RETURN out_verbatim_coordinate_system;
			
END$$
DELIMITER ;