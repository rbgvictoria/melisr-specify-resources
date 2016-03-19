DELIMITER $$

DROP FUNCTION IF EXISTS scientificname$$
CREATE FUNCTION  scientificname(p_taxonid int, p_rankid int) RETURNS varchar(255)
    READS SQL DATA
BEGIN

DECLARE out_sciname VARCHAR(255);
DECLARE var_speciesname VARCHAR(128);
DECLARE var_familyname VARCHAR(64);
DECLARE var_genusname VARCHAR(64);

IF p_rankid>=220 THEN
  SELECT highertaxon(p_taxonid, 'Species')
  INTO var_speciesname;
END IF;

CASE
  WHEN p_rankid<=140 OR p_rankid=180 THEN
    SELECT IF(!isnull(Author), CONCAT(Name, ' ', Author), Name)
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=150 THEN
    SELECT highertaxon(p_taxonid, 'Family') INTO var_familyname;
    SELECT IF(!isnull(Author),
      IF(Name=var_familyname,
        CONCAT_WS(' ', var_familyname, Author, 'subfam.', Name),
        CONCAT_WS(' ', var_familyname, 'subfam.', Name, Author)
      ), CONCAT_WS(' ', var_familyname, 'subfam.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=160 THEN
    SELECT highertaxon(p_taxonid, 'Family') INTO var_familyname;
    SELECT IF(!isnull(Author),
      IF(Name=var_familyname,
        CONCAT_WS(' ', var_familyname, Author, 'tr.', Name),
        CONCAT_WS(' ', var_familyname, 'tr.', Name, Author)
      ), CONCAT_WS(' ', var_familyname, 'tr.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=190 THEN
    SELECT highertaxon(p_taxonid, 'Genus') INTO var_genusname;
    SELECT IF(!isnull(Author),
      IF(Name=var_genusname,
        CONCAT_WS(' ', var_genusname, Author, 'subgen.', Name),
        CONCAT_WS(' ', var_genusname, 'subgen.', Name, Author)
      ), CONCAT_WS(' ', var_genusname, 'subgen.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=200 THEN
    SELECT highertaxon(p_taxonid, 'Genus') INTO var_genusname;
    SELECT IF(!isnull(Author),
      IF(Name=var_genusname,
        CONCAT_WS(' ', var_genusname, Author, 'sect.', Name),
        CONCAT_WS(' ', var_genusname, 'sect.', Name, Author)
      ), CONCAT_WS(' ', var_genusname, 'sect.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=220 THEN
    SELECT IF(!isnull(Author), CONCAT(FullName, ' ', Author), FullName)
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=230 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'subsp.', Name),
        CONCAT_WS(' ', var_speciesname, 'subsp.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'subsp.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=240 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'var.', Name),
        CONCAT_WS(' ', var_speciesname, 'var.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'var.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=250 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'subvar.', Name),
        CONCAT_WS(' ', var_speciesname, 'subvar.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'subvar.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=260 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'f.', Name),
        CONCAT_WS(' ', var_speciesname, 'f.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'f.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
  WHEN p_rankid=270 THEN
    SELECT IF(!isnull(Author),
      IF(Name=SUBSTRING(var_speciesname, LOCATE(' ', var_speciesname)+1),
        CONCAT_WS(' ', var_speciesname, Author, 'subf.', Name),
        CONCAT_WS(' ', var_speciesname, 'subf.', Name, Author)
      ), CONCAT_WS(' ', var_speciesname, 'subf.', Name)
    )
    INTO out_sciname
    FROM taxon
    WHERE TaxonID=p_taxonid;
END CASE;

RETURN out_sciname;

END;

 $$

DELIMITER ;