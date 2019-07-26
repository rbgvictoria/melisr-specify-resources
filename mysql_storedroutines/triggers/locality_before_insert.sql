/***************************************************************************************

locality trigger

The trigger will look for a space in the  Institution field and then put the bit before
the first space in the Institution field  and the bit after in the Catalogue no. field.
This way curation officers can use the  barcode scanner to enter the Other identifier.
[NK, 2012-02-03]
***************************************************************************************/

DROP TRIGGER IF EXISTS locality_before_insert;

DELIMITER $$

CREATE TRIGGER locality_before_insert BEFORE INSERT ON locality
FOR EACH ROW
  BEGIN

    DECLARE var_enteredbycollector INTEGER;

    IF isnull(@DISABLE_TRIGGER) THEN
      IF (NEW.Text2 IS NULL OR NEW.Text2='') AND NEW.Latitude1 IS NOT NULL AND NEW.Longitude1 IS NOT NULL THEN
        IF NEW.LatLongMethod IN ('GEOLocate', 'GA gazetteer', 'Google Earth', 'GeoNames') THEN
          SET NEW.Text2='Data entry person';
        ELSE
          IF NEW.LatLongMethod IN ('GPS') THEN
            SET NEW.Text2='Collector';
          END IF;
        END IF;

        SELECT count(*)
        INTO var_enteredbycollector
        FROM collectingevent ce
        JOIN collector c ON ce.CollectingEventID=c.CollectingEventID
        WHERE c.AgentID=NEW.CreatedByAgentID;

        IF var_enteredbycollector>0 THEN
            SET NEW.Text2='Collector';
        END IF;
      END IF;

      IF NEW.LatLongMethod IN ('GEOLocate', 'Google Earth', 'GeoNames') THEN
        SET NEW.Datum = 'WGS84';
      ELSE
        IF NEW.LatLongMethod = 'GA gazetteer' THEN
          SET NEW.Datum = 'GDA94';
        END IF;
      END IF;
    END IF;
  END $$

DELIMITER ;
