/***************************************************************************************

locality trigger

The trigger will look for a space in the  Institution field and then put the bit before
the first space in the Institution field  and the bit after in the Catalogue no. field.
This way curation officers can use the  barcode scanner to enter the Other identifier.
[NK, 2012-02-03]
***************************************************************************************/

DROP TRIGGER IF EXISTS locality_after_insert;

DELIMITER $$

CREATE TRIGGER locality_after_insert AFTER INSERT ON locality
FOR EACH ROW
  BEGIN
    DECLARE var_georeferencedby INTEGER;
    DECLARE var_georeferenceddate DATETIME;
    DECLARE var_geocoorddetailid INTEGER;

    IF isnull(@DISABLE_TRIGGER) THEN
        IF NEW.Latitude1 IS NOT NULL AND NEW.Longitude1 IS NOT NULL AND NEW.Text2 IN (1, 2) THEN
            
            IF NEW.Text2=2 THEN
              SET var_georeferencedby=NEW.CreatedByAgentID;
              SET var_georeferenceddate=NEW.TimestampCreated;
            ELSE
              SELECT StartDate
              INTO var_georeferenceddate
              FROM collectingevent
              WHERE LocalityID=NEW.LocalityID;

            END IF;

            IF var_georeferencedby IS NOT NULL OR var_georeferenceddate IS NOT NULL THEN
                SELECT GeoCoordDetailID
                INTO var_geocoorddetailid
                FROM geocoorddetail
                WHERE LocalityID=NEW.LocalityID;

                IF var_geocoorddetailid IS NOT NULL THEN
                    UPDATE geocoorddetail
                    SET TimestampModified=NOW(), ModifiedByAgentID=NEW.CreatedByAgentID,
                      Version=Version+1, AgentID=var_georeferencedby, GeoRefDetDate=var_georeferenceddate
                    WHERE GeoCoordDetailID=var_geocoorddetailid;
                ELSE
                    SELECT MAX(GeoCoordDetailID)+1
                    INTO var_geocoorddetailid
                    FROM geocoorddetail;

                    INSERT INTO geocoorddetail (GeoCoordDetailID, TimestampCreated, TimestampModified, Version, GeoRefDetDate, CreatedByAgentID, LocalityID, AgentID)
                    VALUES (var_geocoorddetailid, NOW(), NOW(), 0, var_georeferenceddate, NEW.CreatedByAgentID, NEW.LocalityID, var_georeferencedby);

                END IF;
            END IF;
        END IF;



    END IF;
  END $$

DELIMITER ;
