/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Niels.Klazenga <Niels.Klazenga at rbg.vic.gov.au>
 * Created: 10/08/2020
 */

DROP function IF EXISTS `ipt_startDayOfYear`;

DELIMITER $$
CREATE DEFINER=`admin`@`%` FUNCTION `ipt_startDayOfYear`(in_date varchar(16)) RETURNS int(11)
BEGIN
	DECLARE var_iso_date varchar(16);
    SET var_iso_date=ipt_iso_date(in_date);
    IF LENGTH(var_iso_date)=10 THEN
        RETURN DAYOFYEAR(var_iso_date);
	ELSE
        RETURN NULL;
    END IF;  
END$$

DELIMITER ;



