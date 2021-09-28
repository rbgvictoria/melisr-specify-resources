DELIMITER $$

DROP PROCEDURE IF EXISTS `update_dwc_elevation_terms`$$
CREATE PROCEDURE `update_dwc_elevation_terms`()
BEGIN
    START TRANSACTION;

    UPDATE locality l
    JOIN localitydetail ld ON l.LocalityID=ld.LocalityID
    SET 
      ld.Number1 = CASE l.Text1 WHEN 'ft' THEN round(l.MinElevation * 0.3048) ELSE l.MinElevation END,
      ld.Number2 = CASE 
        WHEN l.MaxElevation Is Null THEN
              CASE l.Text1 WHEN 'ft' THEN round(l.MinElevation * 0.3048) ELSE l.MinElevation END
            ELSE 
              CASE l.Text1 WHEN 'ft' THEN round(l.MaxElevation * 0.3048) ELSE l.MaxElevation END
      END,
      ld.Text3 = CASE 
        WHEN l.VerbatimElevation IS NOT NULL THEN l.VerbatimElevation
        ELSE
              CASE l.Text1
            WHEN 'ft' THEN CASE WHEN l.MaxElevation IS NULL THEN CONCAT_WS(' ', l.MinElevation, l.Text1) ELSE CONCAT(l.MinElevation, '–', l.MaxElevation, ' ', l.Text1) END
                ELSE NULL
              END
      END
    WHERE l.MinElevation IS NOT NULL;

    INSERT INTO localitydetail (TimestampCreated, TimestampModified, Version, CreatedByAgentID, LocalityID, Number1, Number2, Text3)
    SELECT now(), now(), 0, 1, l.LocalityID,
    CASE l.Text1 WHEN 'ft' THEN round(l.MinElevation * 0.3048) ELSE l.MinElevation END as minimumElevationInMeters,
    CASE 
      WHEN l.MaxElevation Is Null THEN
        CASE l.Text1 WHEN 'ft' THEN round(l.MinElevation * 0.3048) ELSE l.MinElevation END
      ELSE 
        CASE l.Text1 WHEN 'ft' THEN round(l.MaxElevation * 0.3048) ELSE l.MaxElevation END
      END AS maximumElevationInMeters,
    CASE 
      WHEN l.VerbatimElevation IS NOT NULL THEN l.VerbatimElevation
      ELSE
            CASE l.Text1
          WHEN 'ft' THEN CASE WHEN l.MaxElevation IS NULL THEN CONCAT_WS(' ', l.MinElevation, l.Text1) ELSE CONCAT(l.MinElevation, '–', l.MaxElevation, ' ', l.Text1) END
              ELSE NULL
            END
    END AS VerbatimElevation
    FROM locality l
    LEFT JOIN localitydetail ld ON l.LocalityID=ld.LocalityID
    WHERE l.MinElevation IS NOT NULL AND ld.LocalityDetailID IS NULL;

    UPDATE locality l
    JOIN localitydetail ld ON l.LocalityID=ld.LocalityID
    SET ld.Number1=NULL, ld.Number2=NULL, ld.Text3=NULL
    WHERE l.MinElevation IS NULL AND ld.Number1 IS NOT NULL;

    COMMIT;
END$$
DELIMITER ;
