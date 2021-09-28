/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 11/10/2020
 */

DROP procedure IF EXISTS `update_coordinate_uncertainty_in_meters`;

DELIMITER $$
USE `melisr`$$
CREATE PROCEDURE `update_coordinate_uncertainty_in_meters` ()
BEGIN
	START TRANSACTION; 

	UPDATE locality l
	JOIN geocoorddetail gc ON l.LocalityID=gc.LocalityID
	SET gc.GeoRefAccuracy=if(gc.MaxUncertaintyEst IS NOT NULL, ROUND(gc.MaxUncertaintyEst), coordinate_uncertainty_in_meters(l.OriginalElevationUnit))
	WHERE (l.OriginalElevationUnit IS NOT NULL OR gc.MaxUncertaintyEst IS NOT NULL) AND (l.Latitude1 IS NOT NULL AND l.Longitude1 IS NOT NULL);

	INSERT INTO geocoorddetail (TimestampCreated, TimestampModified, Version, CreatedByAgentID, GeoRefAccuracy)
	SELECT now(), now(), 0, 1, 
	  coordinate_uncertainty_in_meters(l.OriginalElevationUnit) as geoRefAccuracy
	FROM locality l
	LEFT JOIN geocoorddetail gc ON l.LocalityID=gc.LocalityID
	WHERE (l.OriginalElevationUnit IS NOT NULL AND l.Latitude1 IS NOT NULL AND l.Longitude1 IS NOT NULL) AND gc.GeoCoordDetailID IS NULL;

	COMMIT;
END$$

DELIMITER ;

