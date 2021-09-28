DELIMITER $$

DROP FUNCTION IF EXISTS `ipt_iso_date` $$
CREATE FUNCTION `ipt_iso_date`(in_date varchar(16)) RETURNS varchar(16) CHARSET utf8
BEGIN
  RETURN replace(in_date, '-00', '');
END $$

DELIMITER ;