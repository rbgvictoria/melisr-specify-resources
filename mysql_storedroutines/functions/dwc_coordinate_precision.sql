DROP FUNCTION IF EXISTS melisr.dwc_coordinate_precision;

DELIMITER $$
$$
CREATE DEFINER=`admin`@`%` FUNCTION `melisr`.`dwc_coordinate_precision`(in_lat varchar(32), in_lng varchar(32)) RETURNS decimal(11,10)
BEGIN
	
	DECLARE out_coordinate_precision DECIMAL(11,10);

	DECLARE var_verbatim_coordinate_system VARCHAR(32);

	DECLARE var_lat_degrees VARCHAR(32);
	DECLARE var_lat_minutes VARCHAR(32);
	DECLARE var_lat_seconds VARCHAR(32);
	DECLARE var_lat_factor SMALLINT;
	DECLARE var_lng_degrees VARCHAR(32);
	DECLARE var_lng_minutes VARCHAR(32);
	DECLARE var_lng_seconds VARCHAR(32);
	DECLARE var_lng_factor SMALLINT;

	SET var_verbatim_coordinate_system = dwc_verbatim_coordinate_system(in_lat, in_lng);  

	CASE var_verbatim_coordinate_system
		WHEN 'degrees minutes seconds' THEN
			SET var_lat_seconds = REPLACE(SUBSTRING(SUBSTRING_INDEX(in_lat, ' ', -2), 1, LOCATE(' ', SUBSTRING_INDEX(in_lat, ' ', -2))-1), '"', '');
			IF var_lat_seconds NOT LIKE '%.%' OR var_lat_seconds LIKE '%°%' OR var_lat_seconds LIKE '%''&' THEN
				SET var_lat_factor = 0;
			ELSE
				SET var_lat_factor = LENGTH(SUBSTRING(var_lat_seconds, LOCATE('.', var_lat_seconds)+1)); 
			END IF;

			SET var_lng_seconds = REPLACE(SUBSTRING(SUBSTRING_INDEX(in_lat, ' ', -2), 1, LOCATE(' ', SUBSTRING_INDEX(in_lat, ' ', -2))-1), '"', '');
			IF var_lng_seconds NOT LIKE '%.%' OR var_lng_seconds LIKE '%°%' OR var_lng_seconds LIKE '%''&' THEN
				SET var_lng_factor = 0;
			ELSE
				SET var_lng_factor = LENGTH(SUBSTRING(var_lng_seconds, LOCATE('.', var_lng_seconds)+1)); 
			END IF;
		
			IF var_lat_factor >= var_lng_factor THEN
				SET out_coordinate_precision = 0.00027777778 * POWER(10, 0 - var_lat_factor);
			ELSE
				SET out_coordinate_precision = 0.00027777778 * POWER(10, 0 - var_lng_factor);
			END IF;
		
		WHEN 'degrees decimal minutes' THEN

			SET var_lat_minutes = REPLACE(SUBSTRING(SUBSTRING_INDEX(in_lat, ' ', -2), 1, LOCATE(' ', SUBSTRING_INDEX(in_lat, ' ', -2))-1), '''', '');
			IF var_lat_minutes NOT LIKE '%.%' OR var_lat_minutes LIKE '%°%' OR var_lat_minutes LIKE '%''&' THEN
				SET var_lat_factor = 0;
			ELSE
				SET var_lat_factor = LENGTH(SUBSTRING(var_lat_minutes, LOCATE('.', var_lat_minutes)+1)); 
			END IF;

			SET var_lng_minutes = REPLACE(SUBSTRING(SUBSTRING_INDEX(in_lat, ' ', -2), 1, LOCATE(' ', SUBSTRING_INDEX(in_lat, ' ', -2))-1), '''', '');
			IF var_lng_minutes NOT LIKE '%.%' OR var_lng_minutes LIKE '%°%' THEN
				SET var_lng_factor = 0;
			ELSE
				SET var_lng_factor = LENGTH(SUBSTRING(var_lng_minutes, LOCATE('.', var_lng_minutes)+1)); 
			END IF;
		
			IF var_lat_factor >= var_lng_factor THEN
				SET out_coordinate_precision = 0.01666666667 * POWER(10, 0 - var_lat_factor);
			ELSE
				SET out_coordinate_precision = 0.01666666667 * POWER(10, 0 - var_lng_factor);
			END IF;

		WHEN 'decimal degrees' THEN
		
			SET var_lat_degrees = REPLACE(SUBSTRING(SUBSTRING_INDEX(in_lat, ' ', -2), 1, LOCATE(' ', SUBSTRING_INDEX(in_lat, ' ', -2))-1), '°', '');
			IF var_lat_degrees NOT LIKE '%.%' OR var_lat_degrees LIKE '%°%' OR var_lat_degrees LIKE '%''&' THEN
				SET var_lat_factor = 0;
			ELSE
				SET var_lat_factor = LENGTH(SUBSTRING(var_lat_degrees, LOCATE('.', var_lat_degrees)+1)); 
			END IF;

			SET var_lng_degrees = REPLACE(SUBSTRING(SUBSTRING_INDEX(in_lat, ' ', -2), 1, LOCATE(' ', SUBSTRING_INDEX(in_lat, ' ', -2))-1), '°', '');
			IF var_lng_degrees NOT LIKE '%.%' THEN
				SET var_lng_factor = 0;
			ELSE
				SET var_lng_factor = LENGTH(SUBSTRING(var_lng_degrees, LOCATE('.', var_lng_degrees)+1)); 
			END IF;
		
			IF var_lat_factor >= var_lng_factor THEN
				SET out_coordinate_precision = POWER(10, 0 - var_lat_factor);
			ELSE
				SET out_coordinate_precision = POWER(10, 0 - var_lng_factor);
			END IF;
		
		ELSE
		
			SET out_coordinate_precision = NULL;
		
	END CASE;

	RETURN out_coordinate_precision;
	
END$$
DELIMITER ;
