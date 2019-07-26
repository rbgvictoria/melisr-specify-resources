/***************************************************************************************

locality trigger

***************************************************************************************/

DROP TRIGGER IF EXISTS locality_before_update;

DELIMITER $$

CREATE TRIGGER locality_before_update BEFORE UPDATE ON locality
FOR EACH ROW
  BEGIN
    DECLARE var_who VARCHAR(64);
    DECLARE var_georeferencedby INTEGER;
    DECLARE var_georeferenceddate DATETIME;
    DECLARE var_geocoorddetailid INTEGER;

    DECLARE var_island VARCHAR(64);
    DECLARE var_island_group VARCHAR(64);
    DECLARE var_water_body VARCHAR(64);
    DECLARE var_island_id INTEGER;


    IF isnull(@DISABLE_TRIGGER) THEN
      SET var_who = NEW.Text2;
      IF (NEW.Text2 IS NULL OR NEW.Text2='') AND NEW.Latitude1 IS NOT NULL AND NEW.Longitude1 IS NOT NULL AND (OLD.Latitude1 IS NULL OR OLD.Longitude1 IS NULL) THEN
        IF NEW.LatLongMethod IN ('GEOLocate', 'GA gazetteer', 'Google Earth', 'GeoNames') THEN
          SET NEW.Text2='Data entry person';
          SET var_who='Data entry person';
        ELSE
          IF NEW.LatLongMethod IN ('GPS') THEN
            SET NEW.Text2='Collector';
            SET var_who='Collector';
          END IF;
        END IF;
      END IF;

      IF NEW.LatLongMethod IN ('GEOLocate', 'Google Earth', 'GeoNames') THEN
        SET NEW.Datum = 'WGS84';
      ELSE
        IF NEW.LatLongMethod = 'GA gazetteer' THEN
          SET NEW.Datum = 'GDA94';
        END IF;
      END IF;

      IF (NEW.Latitude1 IS NOT NULL AND NEW.Longitude1 IS NOT NULL) AND (NEW.Latitude1!=OLD.Latitude1 OR NEW.Longitude1!=OLD.Longitude1) AND var_who IN ('Collector', 'Data entry person') THEN
            
        IF var_who='Data entry person' THEN
          SET var_georeferencedby=24365;
          SET var_georeferenceddate=NEW.TimestampModified;
        ELSE
          SELECT StartDate
          INTO var_georeferenceddate
          FROM collectingevent
          WHERE LocalityID=NEW.LocalityID
          LIMIT 1;

        END IF;

        IF var_georeferencedby IS NOT NULL OR var_georeferenceddate IS NOT NULL THEN
            SELECT GeoCoordDetailID
            INTO var_geocoorddetailid
            FROM geocoorddetail
            WHERE LocalityID=NEW.LocalityID;

            IF var_geocoorddetailid IS NOT NULL THEN
                UPDATE geocoorddetail
                SET TimestampModified=NOW(), ModifiedByAgentID=NEW.ModifiedByAgentID,
                  Version=Version+1, AgentID=var_georeferencedby, GeoRefDetDate=var_georeferenceddate
                WHERE GeoCoordDetailID=var_geocoorddetailid;
            ELSE
                SELECT MAX(GeoCoordDetailID)+1
                INTO var_geocoorddetailid
                FROM geocoorddetail;

                INSERT INTO geocoorddetail (GeoCoordDetailID, TimestampCreated, TimestampModified, Version, GeoRefDetDate, CreatedByAgentID, LocalityID, AgentID)
                VALUES (var_geocoorddetailid, NOW(), NOW(), 0, var_georeferenceddate, NEW.ModifiedByAgentID, NEW.LocalityID, var_georeferencedby);

            END IF;
        END IF;
      END IF;

    END IF;
  END $$

DELIMITER ;
