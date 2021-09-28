DELIMITER $$

DROP PROCEDURE IF EXISTS `update_dwc_depth_terms`$$
CREATE PROCEDURE `update_dwc_depth_terms`()
BEGIN
    START TRANSACTION;

    UPDATE localitydetail
    SET 
      Number3 = CASE StartDepthUnit WHEN '1' THEN StartDepth WHEN '2' THEN ROUND(StartDepth * 0.3048) WHEN '3' THEN ROUND(StartDepth * 1.8288) END,
      Number4 = CASE 
        WHEN EndDepth IS NULL THEN
          CASE StartDepthUnit WHEN '1' THEN StartDepth WHEN '2' THEN ROUND(StartDepth * 0.3048) WHEN '3' THEN ROUND(StartDepth * 1.8288) END
            ELSE
              CASE StartDepthUnit WHEN '1' THEN EndDepth WHEN '2' THEN ROUND(EndDepth * 0.3048) WHEN '3' THEN ROUND(EndDepth * 1.8288) END
      END,
      Text4 = CASE 
        WHEN EndDepth IS NULL THEN
          CASE StartDepthUnit
            WHEN '2' THEN CONCAT(StartDepth, ' ft')
            WHEN '3' THEN CONCAT(StartDepth, ' fathoms')
                ELSE NULL
              END
            ELSE
          CASE StartDepthUnit
            WHEN '2' THEN CONCAT(StartDepth, '–', EndDepth, ' ft')
            WHEN '3' THEN CONCAT(StartDepth, '–', ENDDepth, ' fathoms')
                ELSE NULL
              END
      END
    WHERE StartDepth IS NOT NULL;

    UPDATE localitydetail
    SET Number3=NULL, Number4=NULL, Text4=null
    WHERE StartDepth IS NULL AND Number3 IS NOT NULL;

    COMMIT;
END$$
DELIMITER ;
