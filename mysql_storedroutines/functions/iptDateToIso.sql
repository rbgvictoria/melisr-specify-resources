DELIMITER $$

DROP FUNCTION IF EXISTS `iptDateToIso` $$
CREATE FUNCTION `iptDateToIso`(in_date date) RETURNS varchar(16) CHARSET utf8
BEGIN
  RETURN replace(in_date, '-00', '');
END $$

DELIMITER ;