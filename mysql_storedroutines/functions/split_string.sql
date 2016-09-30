DELIMITER $$

/*
* Function splits the input string (str) on a delimiter (del) and returns the
* bit indicated by the third parameter (i).
* http://stackoverflow.com/questions/14950466/how-to-split-the-name-string-in-mysql#answer-26491403
*/
DROP FUNCTION IF EXISTS `split_string` $$
CREATE FUNCTION `split_string`(str VARCHAR(1024) , del VARCHAR(1) , i INT) 
    RETURNS VARCHAR(1024) CHARSET utf8
BEGIN
    DECLARE n INT ;
    SET n = LENGTH(s) - LENGTH(REPLACE(str, del, '')) + 1;
    IF i > n THEN
        RETURN NULL;
    ELSE
        RETURN SUBSTRING_INDEX(SUBSTRING_INDEX(str, del, i) , del , -1 );
    END IF;
END $$

DELIMITER ;
