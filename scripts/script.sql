/* KHELILI ADRIAN P1612177 
   MOULAY LAKHDAR SARAH p1511065
*/ 

CREATE TABLE BALLOTS_TMP(

	ballot_id INTEGER,
	vote_date timestamp,
	comittee VARCHAR(30)

);

/*
	Charger les données csv dans le table temporaire
*/
COPY BALLOTS_TMP(ballot_id, vote_date, comittee)
	FROM '/home/adrian-i5/Documents/BDW/PROJET/EP_DATA/EP_DATA/BALLOTS.csv' DELIMITER '	' CSV HEADER;

SELECT * FROM ballots_tmp;

/* Teste l'existance de doublons */

SELECT * from ballots_tmp WHERE ballot_id in (
SELECT ballot_id FROM ballots_tmp GROUP BY ballot_id HAVING(count(*) > 1));

/* Ajoute une colonne qu'on vas remplir par des clés générées automatiquement */ 

ALTER TABLE ballots_tmp ADD COLUMN COLUID uuid;
/* Inclu la lib pour acceder a la fonction uuid_generate_v4() */
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

/* Rempli la colonne de valeurs */
UPDATE ballots_tmp SET COLUID = uuid_generate_v4();
														
/* Surcharge l'operateur sur les uuuid*/
CREATE OR REPLACE FUNCTION min(uuid, uuid)
RETURNS uuid AS $$
BEGIN
    IF $2 IS NULL OR $1 > $2 THEN
        RETURN $2;
    END IF;

    RETURN $1;
END;
$$ LANGUAGE plpgsql;


CREATE AGGREGATE min(uuid)
(
    sfunc = min,
    stype = uuid
);		

/* Ce gros bout de code défini la fonction min sur des uuid */ 													
															
delete  FROM ballots_tmp b WHERE b.coluid > ANY(
	SELECT coluid FROM ballots_tmp WHERE b.coluid <> coluid AND b.ballot_id = ballot_id
);
/* Supprime les tuples redondants */

											
ALTER TABLE ballots_tmp
      DROP COLUMN COLUID
/* Supprime la colonne dont nous n'avons plus besoin */

SELECT * FROM ballots;

/* J'insère les tuples de la table ballot_tmp dans la table ballots */
insert into ballots(ballot_id, vote_date, comittee) SELECT * FROM ballots_tmp;

/* Suppression de la table temporaire;*/
DROP Table ballots_tmp;

/* Insertion des autres tables */
/* Insertion de la table tags */
COPY TAGS(tag_id, tag_label)
	FROM '/home/adrian-i5/Documents/BDW/PROJET/EP_DATA/EP_DATA/TAGS.csv' DELIMITER '	' CSV HEADER;


/*Insertion de BALLOTS_TO_TAGS*/
COPY BALLOTS_TO_TAGS(ballot_id, tag_id)
	FROM '/home/adrian-i5/Documents/BDW/PROJET/EP_DATA/EP_DATA/BALLOTS_TO_TAGS.csv' DELIMITER '	' CSV HEADER;
	

/*Insertion des MEPS*/
COPY MEPS(mepid, name_full, country, national_party, groupe_id, gender)
	FROM '/home/adrian-i5/Documents/BDW/EP_DATA/EP_DATA/MEPS.csv' DELIMITER '	' CSV HEADER;


CREATE TABLE OUTCOMES_TMP_SC(
	ballot_id INTEGER,
	mepid INTEGER ,
	outcome VARCHAR(20)
);
  
COPY outcomes_tmp_sc(ballot_id, mepid, outcome)
FROM '/home/adrian-i5/Documents/BDW/PROJET/EP_DATA/EP_DATA/OUTCOMES.csv' DELIMITER '	' CSV HEADER;

ALTER TABLE outcomes_tmp_sc ADD COLUMN COLUID uuid;
UPDATE outcomes_tmp_sc SET COLUID = uuid_generate_v4();

SELECT * FROM OUTCOMES WHERE outcome NOT IN ( 'Abstain', 'For', 'Against');
/*SUPPRESSION DES LIGNES INUTILES*/
SELECT  FROM OUTCOMES_TMP_SC T1
  USING       OUTCOMES_TMP_SC T2
 WHERE  T1.coluid    < T2.coluid      
  AND  T1.ballot_id    = T2.ballot_id      
  AND  T1.mepid = T2.mepid;

SELECT ballot_id, mepid FROM OUTCOMES_TMP_SC GROUP BY ballot_id, mepid HAVING count(*) > 1;

/*SUPRESSION DE LA COLONNE Créer */
ALTER TABLE OUTCOMES_TMP_SC DROP COLUMN coluid;

/*Suppression des tuples lorsque la référence n'existe pas */
DELETE FROM OUTCOMES_TMP_SC osc WHERE osc.ballot_id NOT IN(
	SELECT ballot_id FROM BALLOTS	
);

/* Suppression des tuples lorsque la réference n'eexiste pas*/
DELETE FROM OUTCOMES_TMP_SC osc WHERE osc.mepid NOT IN(
	SELECT mepid FROM MEPS
);

SELECT * FROM OUTcOMES_TMP_SC where outcome= 'oFr';

/*Remplace les oFr par For*/
UPDATE outcomes_tmp_sc SET outcome='For' WHERE coluid in (SELECT coluid FROM outcomes_tmp_sc WHERE outcome='oFr');
SELECT * FROM OUTCOMES_TMP_SC WHERE outcome='oFr';

/*Remplace les gAinst par Against*/
UPDATE outcomes_tmp_sc SET outcome='Against' WHERE coluid in (SELECT coluid FROM outcomes_tmp_sc WHERE outcome='gAainst');
SELECT * FROM OUTCOMES_TMP_SC WHERE outcome='gAainst';

/* Remplace les bAstain par Abstain*/
UPDATE outcomes_tmp_sc SET outcome='Abstain' WHERE coluid in (SELECT coluid FROM outcomes_tmp_sc WHERE outcome='bAstain');
SELECT * FROM OUTCOMES_TMP_SC WHERE outcome='bAstain';
  
/* Verification que les doublons ont bien été supprimés*/
SELECT ballot_id, mepid FROM OUTCOMES_TMP_SC GROUP BY ballot_id, mepid HAVING count(*) > 1;

INSERT INTO outcomes(ballot_id, mepid, outcome) (SELECT ballot_id, mepid, outcome FROM outcomes_tmp_sc );
SELECT * FROM outcomes;

/* Supression de la table temporaire */
DROP TABLE outcomes_tmp_sc;