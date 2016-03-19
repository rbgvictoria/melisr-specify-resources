/***************************************************************************************

geocoorddetail trigger

This trigger will set the georeferencedDate to NULL if latitudeDecimal and/or 
longitudeDecimal are NULL. [NK 2015-03-13]
***************************************************************************************/

DROP TRIGGER IF EXISTS geocoorddetail_before_insert;

DELIMITER $$

CREATE TRIGGER geocoorddetail_before_insert BEFORE INSERT ON geocoorddetail
FOR EACH ROW
  BEGIN

    DECLARE var_latitude DECIMAL(12,10);
    DECLARE var_longitude DECIMAL(12,10);

    IF isnull(@DISABLE_TRIGGER) THEN
        SELECT Latitude1, Longitude1
        INTO var_latitude, var_longitude
        FROM locality
        WHERE LocalityID=NEW.LocalityID;

        IF var_latitude IS NULL OR var_longitude IS NULL THEN
            SET NEW.GeoRefDetDate=NULL;
        END IF;

    END IF;
  END $$

DELIMITER ;
