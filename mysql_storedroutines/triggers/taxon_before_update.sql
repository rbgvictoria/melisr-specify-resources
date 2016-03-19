/***************************************************************************************
taxon_before_update trigger

***************************************************************************************/
DROP TRIGGER IF EXISTS taxon_before_update;

DELIMITER $$

CREATE TRIGGER taxon_before_update BEFORE UPDATE ON taxon
FOR EACH ROW
  BEGIN
		DECLARE var_parentid INTEGER(11);
		DECLARE var_rankid INTEGER(11);
		DECLARE var_parentname VARCHAR(128);
		DECLARE var_parentnameauthor VARCHAR(128);
		DECLARE var_speciesepithet VARCHAR(64);
		DECLARE var_rank VARCHAR(8);
		DECLARE var_scientificname VARCHAR(255);
                DECLARE var_genus VARCHAR(128);

        DECLARE var_fullname VARCHAR(255);

		IF isnull(@DISABLE_TRIGGER) THEN
			-- First check if something has happened that affects the scientific name
			/*IF (NEW.Name IS NOT NULL AND NEW.Name!=OLD.Name) OR (NEW.ParentID IS NOT NULL AND NEW.ParentID!=OLD.ParentID)
				OR (NEW.Author IS NOT NULL AND NEW.Author!=OLD.Author) OR (OLD.Author IS NOT NULL AND NEW.Author!=OLD.Author) THEN*/


				-- Names of families or higher taxa, or names of genera
				IF NEW.RankID<=140 OR NEW.RankID=180 THEN
					IF NEW.Author IS NOT NULL THEN
						SET var_scientificname = CONCAT(NEW.Name, ' ', NEW.Author);
					ELSE
						SET var_scientificname = NEW.Name;
					END IF;

                    IF NEW.RankID=180 THEN
                        SET NEW.UnitName2=NEW.Name;
                    END IF;

				-- Names of infrafamilial taxa
				ELSEIF NEW.RankID IN (150, 160) THEN
					SET var_parentid=NEW.ParentID;
					parent: LOOP
						SELECT Name, Author, ParentID, RankID
						INTO var_parentname, var_parentnameauthor, var_parentid, var_rankid
						FROM taxon
						WHERE TaxonID=var_parentid;

						IF (var_rankid=140) THEN
							LEAVE parent;
						END IF;
					END LOOP parent;

					CASE NEW.RankID
						WHEN 150 THEN SET var_rank='subfam.';
						WHEN 160 THEN SET var_rank='tr.';
					END CASE;

					IF NEW.Author IS NOT NULL THEN
						SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name, NEW.Author);
					ELSE
						SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name);
					END IF;

				-- Names of infrageneric taxa
				ELSEIF NEW.RankID IN (190, 200) THEN
					SET var_parentid=NEW.ParentID;
					parent: LOOP
						SELECT Name, Author, ParentID, RankID
						INTO var_parentname, var_parentnameauthor, var_parentid, var_rankid
						FROM taxon
						WHERE TaxonID=var_parentid;

						IF (var_rankid=180) THEN
							LEAVE parent;
						END IF;
					END LOOP parent;

					CASE NEW.RankID
						WHEN 190 THEN SET var_rank='subgen.';
						WHEN 200 THEN SET var_rank='sect.';
					END CASE;

					IF NEW.Name=var_parentname THEN
						IF var_parentnameauthor IS NOT NULL THEN
							SET var_scientificname=CONCAT_WS(' ', var_parentname, var_parentnameauthor, var_rank, NEW.Name);
						ELSE
							SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name);
						END IF;
					ELSE
						IF NEW.Author IS NOT NULL THEN
							SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name, NEW.Author);
						ELSE
							SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name);
						END IF;
					END IF;

				-- Species names (in MELISR, infrageneric taxa are not allowed to have children)
				ELSEIF NEW.RankID=220 THEN
                                    SELECT Name
                                    INTO var_parentname
                                    FROM taxon
                                    WHERE TaxonID=NEW.ParentID;

                                            IF NEW.Author IS NOT NULL THEN
                                                    SET var_scientificname = CONCAT_WS(' ', var_parentname, NEW.Name, NEW.Author);
                                            ELSE
                                                    SET var_scientificname = CONCAT_WS(' ', var_parentname, NEW.Name);
                                            END IF;

                                            SET NEW.UnitName2 = var_parentname;
                                            SET NEW.UnitName3 = NEW.Name;

				-- Names of infraspecific taxa
				ELSEIF NEW.RankID>220 THEN
                                    SET var_parentid=NEW.ParentID;
                                    parent: LOOP
                                            SELECT FullName, Name, Author, ParentID, RankID
                                            INTO var_parentname, var_speciesepithet, var_parentnameauthor, var_parentid, var_rankid
                                            FROM taxon
                                            WHERE TaxonID=var_parentid;

                                            IF (var_rankid=220) THEN
                                                    LEAVE parent;
                                            END IF;
                                    END LOOP parent;

                                    CASE NEW.RankID
                                            WHEN 230 THEN SET var_rank='subsp.';
                                            WHEN 240 THEN SET var_rank='var.';
                                            WHEN 250 THEN SET var_rank='subvar.';
                                            WHEN 260 THEN SET var_rank='f.';
                                            WHEN 270 THEN SET var_rank='subf.';
                                    END CASE;

                                    IF NEW.Name=var_speciesepithet THEN
                                            IF var_parentnameauthor IS NOT NULL THEN
                                                    SET var_scientificname=CONCAT_WS(' ', var_parentname, var_parentnameauthor, var_rank, NEW.Name);
                                            ELSE
                                                    SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name);
                                            END IF;
                                    ELSE
                                            IF NEW.Author IS NOT NULL THEN
                                                    SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name, NEW.Author);
                                            ELSE
                                                    SET var_scientificname=CONCAT_WS(' ', var_parentname, var_rank, NEW.Name);
                                            END IF;
                                    END IF;

                                    SELECT SUBSTRING(var_parentname, 1, LOCATE(' ', var_parentname)-1)
                                    INTO var_genus;
                                    SET NEW.UnitName2 = var_genus;
                                    SET NEW.UnitName3 = var_speciesepithet;
                                    SET NEW.UnitName4 = NEW.Name;
				END IF;

                -- Add 'ms' suffix for manuscript names
                IF (NEW.NcbiTaxonNumber='ms') THEN
                    SET var_scientificname=CONCAT(var_scientificname,' ms');
                END IF;

				-- Write scientific name to UnitName1
				SET NEW.UnitName1=var_scientificname;
			/*END IF;*/

      -- Append nomenclatural status to full name
      IF !isnull(NEW.EsaStatus) AND NEW.EsaStatus!='' THEN
            SET var_fullname = IF(NEW.FullName LIKE '%[%', SUBSTRING(NEW.FullName, 1, LOCATE('[', NEW.FullName)-2), NEW.FullName);
            SET NEW.FullName = CONCAT(var_fullname, ' [', NEW.EsaStatus, ']');
      END IF;

		END IF;
  END $$

DELIMITER ;