/***************************************************************************************
morhbank view before insert trigger

Setes the MorphBank External View ID to the MorphBank ID [NK 2014-11-14]

***************************************************************************************/

DROP TRIGGER IF EXISTS morphbankview_before_insert;

DELIMITER $$

CREATE TRIGGER morphbankview_before_insert BEFORE INSERT ON morphbankview
FOR EACH ROW
  BEGIN
    SET NEW.MorphbankExternalViewID=NEW.MorphbankViewID;
  END $$

DELIMITER ;
