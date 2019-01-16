/* KHELILI ADRIAN P1612177 
   MOULAY LAKHDAR SARAH p1511065
*/ 

/* Ecrire la fonction PL/pgSQL ´ PARENTOF(tag1,tag2) qui permet de v´erifier
si un tag (tag1) est un parent directe dans l’hi´erarchie des tags d’un autre
tag (tag2). */ 
CREATE OR REPLACE FUNCTION PARENTOF(tag_id1 tags.tag_id%TYPE, tag_id2 tags.tag_id%TYPE) 
RETURNS bool as $variable$
   DECLARE
      isAncetre bool;
   BEGIN
	RETURN (tag_id2 like tag_id1||'.__' );
END; 
$variable$ LANGUAGE plpgsql;

SELECT * FROM TAGS;
SELECT PARENTOF('1.10','1.10.20');


/* Ecrire la fonction PL/pgSQL ´ ANCESTOR(tag1,tag2) qui permet de v´erifier
si un tag (tag1) est un ancˆetre d’un autre tag (tag2).  */
CREATE OR REPLACE FUNCTION ANCESTOR(tag_id1 tags.tag_id%TYPE, tag_id2 tags.tag_id%TYPE) 
RETURNS bool as $$
   DECLARE
   BEGIN
	RETURN (tag_id2 like tag_id1||'%' );
END; 
$$ LANGUAGE plpgsql;

SELECT * FROM TAGS;
SELECT ANCESTOR('1','1.10.20');


/* Ecrire la fonction PL/pgSQL ´ TAGGED(ballot,tag) qui permet de v´erifier
si un Scrutin (ballot) est annot´ee par un tag (tag) en utilisant la fonction
(ANCESTOR). */

CREATE OR REPLACE FUNCTION TAGGED(ballotid ballots.ballot_id%TYPE, tag tags.tag_id%TYPE) 
RETURNS bool as $$
   DECLARE
      tuple ballots_to_tags%rowtype;
	  tab_ballot CURSOR FOR SELECT * FROM ballots_to_tags WHERE ballot_id = ballotid;
   BEGIN
   	  FOR tuple in tab_ballot LOOP
	      CASE ANCESTOR(tuple.tag_id,tag) 
			  WHEN TRUE THEN
				return true;
				ELSE NULL;
			END CASE;
	  END LOOP;
	  return false;
END; 
$$ LANGUAGE plpgsql;


/* Ecrire la fonction PL/pgSQL ´ MAJORITY VOTE PARTY(ballot,national party)
qui permet de calculer le vote majoritaire d’un parti national party pour
un scrutin ballot. La fonction retournera les valeurs enti`eres suivantes: */

CREATE OR REPLACE FUNCTION MAJORITY_VOTE_PARTY(ballot ballots.ballot_id%TYPE, n_p meps.national_party%TYPE)
RETURNS INTEGER AS $$
DECLARE
	outcomes_vote CURSOR FOR 
		SELECT outcome, COUNT(*) as nb_vote FROM MEPS mp NATURAL JOIN OUTCOMES 
			WHERE mp.national_party = n_p AND ballot_id = ballot GROUP BY outcome;
			
	nb_vote_for INTEGER := 0;
	nb_vote_against INTEGER := 0;
	nb_vote_abstain INTEGER := 0;
BEGIN

	FOR outc IN outcomes_vote LOOP
		CASE outc.outcome 
			WHEN 'For' THEN
				nb_vote_for :=  outc.nb_vote;
			WHEN 'Against' THEN
				nb_vote_against :=  outc.nb_vote;
			WHEN 'Abstain' THEN
				nb_vote_abstain :=  outc.nb_vote;
			ELSE NULL;
		END CASE;
	END LOOP;
	
	CASE
		WHEN (nb_vote_for + nb_vote_against + nb_vote_abstain) = 0 THEN
			RETURN 0;
		WHEN nb_vote_for > nb_vote_against AND nb_vote_for > nb_vote_abstain THEN
			RETURN 1;
		WHEN nb_vote_against > nb_vote_for AND nb_vote_against > nb_vote_abstain THEN
			RETURN 2;
		WHEN nb_vote_abstain > nb_vote_for AND nb_vote_abstain > nb_vote_against THEN
			RETURN 3;
		WHEN nb_vote_abstain = nb_vote_for AND nb_vote_abstain = nb_vote_against THEN
			RETURN 7;
		WHEN nb_vote_for = nb_vote_against AND nb_vote_for > nb_vote_abstain THEN
			RETURN 4;
		WHEN nb_vote_abstain = nb_vote_for AND nb_vote_for > nb_vote_against THEN
			RETURN 5;
		WHEN nb_vote_abstain = nb_vote_against AND nb_vote_abstain > nb_vote_for THEN
			RETURN 6;
		WHEN nb_vote_abstain = nb_vote_against AND nb_vote_abstain = nb_vote_against THEN
			RETURN 7;
		ELSE NULL;
	END CASE;
	
END $$ LANGUAGE plpgsql;


/*Ecrire la fonction PL/pgSQL ´ MAJORITY VOTE GROUPE(ballot,EU group)
qui calcule de la mˆeme mani`ere que la fonction pr´ec´edente, le vote majoritaire
d’un groupe politique EU group pour un scrutin ballot. */ 

CREATE OR REPLACE FUNCTION MAJORITY_VOTE_GROUPE(ballot ballots.ballot_id%TYPE,Gp meps.groupe_id%TYPE)
RETURNS INTEGER AS $$
DECLARE
	outcomes_vote CURSOR FOR 
		SELECT outcome, COUNT(*) as nb_vote FROM MEPS mp NATURAL JOIN OUTCOMES 
			WHERE mp.groupe_id = Gp AND ballot_id = ballot GROUP BY outcome;
			
	nb_vote_for INTEGER := 0;
	nb_vote_against INTEGER := 0;
	nb_vote_abstain INTEGER := 0;
BEGIN

	FOR outc IN outcomes_vote LOOP
		CASE outc.outcome 
			WHEN 'For' THEN
				nb_vote_for :=   outc.nb_vote;
			WHEN 'Against' THEN
				nb_vote_against :=  outc.nb_vote;
			WHEN 'Abstain' THEN
				nb_vote_abstain :=  outc.nb_vote;
			ELSE NULL;
		END CASE;
	END LOOP;
	
	CASE
		WHEN (nb_vote_for + nb_vote_against + nb_vote_abstain) = 0 THEN
			RETURN 0;
		WHEN nb_vote_for > nb_vote_against AND nb_vote_for > nb_vote_abstain THEN
			RETURN 1;
		WHEN nb_vote_against > nb_vote_for AND nb_vote_against > nb_vote_abstain THEN
			RETURN 2;
		WHEN nb_vote_abstain > nb_vote_for AND nb_vote_abstain > nb_vote_against THEN
			RETURN 3;
		WHEN nb_vote_abstain = nb_vote_for AND nb_vote_abstain = nb_vote_against THEN
			RETURN 7;
		WHEN nb_vote_for = nb_vote_against AND nb_vote_for > nb_vote_abstain THEN
			RETURN 4;
		WHEN nb_vote_abstain = nb_vote_for AND nb_vote_for > nb_vote_against THEN
			RETURN 5;
		WHEN nb_vote_abstain = nb_vote_against AND nb_vote_abstain > nb_vote_for THEN
			RETURN 6;
		WHEN nb_vote_abstain = nb_vote_against AND nb_vote_abstain > nb_vote_against THEN
			RETURN 7;
		ELSE NULL;
	END CASE;
	
END $$ LANGUAGE plpgsql;


/* 7. Ecrire la fonction ´ SIMILARITY NATIONAL PARTY(ballot,party1,party2)
qui permet de calculer la similarit´e entre deux partis nationaux sur la
base d’un scrutin donn´ee. La fonction retournera 1, si les deux groupes
compar´es ont vot´e exactement de la mˆeme mani`ere, 0 sinon.  */ 

CREATE OR REPLACE FUNCTION MAJORITY_VOTE_COUNTRY(ballot ballots.ballot_id%TYPE,coun meps.country%TYPE)
RETURNS INTEGER AS $$
DECLARE
	outcomes_vote CURSOR FOR 
		SELECT outcome, COUNT(*) as nb_vote FROM MEPS  NATURAL JOIN OUTCOMES 
			WHERE country = coun AND ballot_id = ballot GROUP BY outcome;
			
	nb_vote_for INTEGER := 0;
	nb_vote_against INTEGER := 0;
	nb_vote_abstain INTEGER := 0;
BEGIN

	FOR outc IN outcomes_vote LOOP
		CASE outc.outcome 
			WHEN 'For' THEN
				nb_vote_for :=  outc.nb_vote;
			WHEN 'Against' THEN
				nb_vote_against :=  outc.nb_vote;
			WHEN 'Abstain' THEN
				nb_vote_abstain := outc.nb_vote;
			ELSE NULL;
		END CASE;
	END LOOP;
	
		CASE
		WHEN (nb_vote_for + nb_vote_against + nb_vote_abstain) = 0 THEN
			RETURN 0;
		WHEN nb_vote_for > nb_vote_against AND nb_vote_for > nb_vote_abstain THEN
			RETURN 1;
		WHEN nb_vote_against > nb_vote_for AND nb_vote_against > nb_vote_abstain THEN
			RETURN 2;
		WHEN nb_vote_abstain > nb_vote_for AND nb_vote_abstain > nb_vote_against THEN
			RETURN 3;
		WHEN nb_vote_abstain = nb_vote_for AND nb_vote_abstain = nb_vote_against THEN
			RETURN 7;
		WHEN nb_vote_for = nb_vote_against AND nb_vote_for > nb_vote_abstain THEN
			RETURN 4;
		WHEN nb_vote_abstain = nb_vote_for AND nb_vote_for > nb_vote_against THEN
			RETURN 5;
		WHEN nb_vote_abstain = nb_vote_against AND nb_vote_abstain > nb_vote_for THEN
			RETURN 6;
		WHEN nb_vote_abstain = nb_vote_against AND nb_vote_abstain = nb_vote_against THEN
			RETURN 7;
		ELSE NULL;
	END CASE;
	
END $$ LANGUAGE plpgsql;

select groupe_id , ballot_id from meps natural join ballots;


/*Ecrire la fonction ´ SIMILARITY NATIONAL PARTY(ballot,party1,party2)
qui permet de calculer la similarit´e entre deux partis nationaux sur la
base d’un scrutin donn´ee. La fonction retournera 1, si les deux groupes
compar´es ont vot´e exactement de la mˆeme mani`ere, 0 sinon. */ 

CREATE OR REPLACE FUNCTION SIMILARITY_NATIONAL_PARTY(ballot ballots.ballot_id%TYPE,coun meps.country%TYPE, coun2 meps.country%TYPE)
RETURNS INTEGER AS $$
DECLARE
	c1 CURSOR FOR 
		SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE country=coun GROUP BY outcome;
	c2 CURSOS FOR 
		SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE country=coun2 GROUP BY outcome;
	enregistrement c1%TYPE;
	Taille1 INTEGER:= count(*) FROM (SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE country='Germany' GROUP BY outcome) as f;;
	Taille2 INTEGER:= count(*) FROM (SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE country='Germany' GROUP BY outcome) as f;
BEGIN

CASE WHEN Taille1 != Taille2
	RETURN 0;
ELSE NULL;

FOR outc in c2 LOOP
	fetch c1 into enregistrement;
	CASE c2.outcome != c1.outcome
		RETURN 0;
	END CASE;
END LOOP;

RETURN 1;

END; $$ LANGUAGE plpgsql;


/* Ecrire la fonction ´ SIMILARITY NATIONAL PARTY(ballot,party1,party2)
qui permet de calculer la similarit´e entre deux partis nationaux sur la
base d’un scrutin donn´ee. La fonction retournera 1, si les deux groupes
compar´es ont vot´e exactement de la mˆeme mani`ere, 0 sinon */ 

CREATE OR REPLACE FUNCTION SIMILARITY_NATIONAL_PARTY(ballot ballots.ballot_id%TYPE,coun meps.national_party%TYPE, coun2 meps.national_party%TYPE)
RETURNS INTEGER AS $$
DECLARE
	c1 CURSOR FOR 
		SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE country=coun GROUP BY outcome;
	c2 CURSOR FOR 
		SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE country=coun2 GROUP BY outcome;
	enregis1 OUTCOMES.outcome%TYPE;
	enregis2 bigint;
	Taille1 INTEGER:= count(*) FROM (SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE national_party=coun GROUP BY outcome) as f;
	Taille2 INTEGER:= count(*) FROM (SELECT outcome, count(*) FROM MEPS NATURAL JOIN OUTCOMES WHERE national_party=coun2 GROUP BY outcome) as f2;
BEGIN

CASE WHEN Taille1 != Taille2
	THEN RETURN 0;
	ELSE NULL;
END CASE;

open c1;
FOR outc in c2 LOOP
	fetch c1 into enregis2,enregis1;
	CASE WHEN c2.outcome != enregis1
		THEN RETURN 0;
	END CASE;
	
END LOOP;
RETURN 1;
END $$ LANGUAGE plpgsql;
SELECT * FROM OUTCOMES;
SELECT SIMILARITY_NATIONAL_PARTY(48361,'France','France');


CREATE OR REPLACE FUNCTION SIMILARITY_NATIONAL_PARTY(ballot ballots.ballot_id%TYPE,np1 meps.national_party%TYPE, np2 meps.national_party%TYPE)
RETURNS INTEGER AS $$
DECLARE
BEGIN

	IF MAJORITY_VOTE_PARTY(ballot, np1) = MAJORITY_VOTE_PARTY(ballot, np2) THEN
		RETURN 1;
	ELSE RETURN 0;
	END IF;

END $$ LANGUAGE plpgsql;


/* Ecrire les deux fonctions ´ SIMILARITY GROUP (resp. SIMILARITY COUNTRY)
qui calcule la similarit´e de votes majoritaires entre deux groupes politiques
(resp. deux pays).*/

CREATE OR REPLACE FUNCTION SIMILARITY_GROUP(ballot ballots.ballot_id%TYPE,gp1 meps.groupe_id%TYPE, gp2 meps.country%TYPE)
RETURNS BOOL AS $$
DECLARE
BEGIN
	RETURN MAJORITY_VOTE_GROUPE(ballot, gp1) = MAJORITY_VOTE_GROUPE(ballot, gp2);
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION SIMILARITY_COUNTRY(ballot ballots.ballot_id%TYPE,np1 meps.national_party%TYPE, np2 meps.national_party%TYPE)
RETURNS BOOL AS $$
DECLARE
BEGIN
	RETURN MAJORITY_VOTE_COUTRY(ballot, np1) = MAJORITY_VOTE_COUNTRY(ballot, np2);
END $$ LANGUAGE plpgsql;


/* Ecrire une fonction PL/pgSQL ´ USUAL SIMILARITY PARTY(party1,party2)
qui permet de calculer le pourcentage de scrutins sur lesquels deux parties
politiques sont d’accord. Ecrire ´egalement les deux fonctions ´ USUAL SIMILARITY GROUP
et USUAL SIMILARITY COUNTRY qui calculent respectivement l’accord usuel
entre deux groupes politique et l’accord usuel entre deux pays.*/ 

CREATE OR REPLACE FUNCTION USUAL_SIMILARITY_PARTY(np1 meps.national_party%TYPE, np2 meps.national_party%TYPE)
RETURNS DECIMAL AS $$
DECLARE
	curs CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE national_party = np1 or national_party = np2 ;
	total INTEGER := count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE national_party = np1 or national_party = np2 ) as f;
	coun INTEGER :=0; 
BEGIN
	FOR outc in curs LOOP
		IF(SIMILARITY_NATIONAL_PARTY(outc.ballot_id ,np1, np2)) THEN coun := coun +1;
		END IF;
	END LOOP;
	RETURN (coun*100)/total;

END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION USUAL_SIMILARITY_COUNTRY(coun1 meps.national_party%TYPE, coun2 meps.national_party%TYPE)
RETURNS DECIMAL AS $$
DECLARE
	curs CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE country = coun1 or country = coun2 ;
	total INTEGER :=count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE country = gp1 or coutry =gp2 ) as f;;
	coun INTEGER :=0; 
BEGIN
	FOR outc in curs LOOP
		IF(SIMILARITY_COUNTRY(outc.ballot_id ,coun1, coun2)) THEN coun := coun +1;
		END IF;
	END LOOP;
	RETURN (coun*100)/total;

END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION USUAL_SIMILARITY_GROUP(gp1 meps.groupe_id%TYPE, gp2 meps.groupe_id%TYPE)
RETURNS DECIMAL AS $$
DECLARE
	curs CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE groupe_id = gp1 or groupe_id = gp2 ;
	total INTEGER :=count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE groupe_id = gp1 or groupe_id = gp2 ) as f;;
	coun INTEGER :=0; 
BEGIN
	FOR outc in curs LOOP
		IF(SIMILARITY_GROUP(outc.ballot_id ,np1, np2)) THEN coun := coun +1;
		END IF;
	END LOOP;
	RETURN (coun*100)/total;
MEPS
END $$ LANGUAGE plpgsql;

/* Ecrire une fonction PL/pgSQL ´ CONTEXTUAL SIMILARITY PARTY(tag,party1,party2)
qui calcule la similarit´e entre les votes majoritaires des deux parties confront´es
sur la base des scrutins affili´es `a un tag donn´e. Ecrire ´egalement les ´
deux fonctions CONTEXTUAL SIMILARITY GROUP et CONTEXTUAL SIMILARITY COUNTRY.*/ 

CREATE OR REPLACE FUNCTION CONTEXTUAL_SIMILARITY_GROUP(tag ballots_to_tags.tag_id%TYPE ,gp1 meps.groupe_id%TYPE, gp2 meps.groupe_id%TYPE)
RETURNS DECIMAL AS $$
DECLARE
	curs CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE (groupe_id = gp1 or groupe_id = gp2) and tag_id = tag ;
	total INTEGER := count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE (groupe_id = gp1 or groupe_id = gp2) AND tag_id = tag ) as f;
	coun INTEGER :=0; 
BEGIN
	FOR outc in curs LOOP
		IF(SIMILARITY_GROUP(outc.ballot_id ,gp1, gp2)) THEN coun := coun +1;
		END IF;
	END LOOP;
	if (total != 0) THEN 
	RETURN (coun*100)/total; 
	ELSE RETURN 100;
	END IF;

END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CONTEXTUAL_SIMILARITY_NATIONAL_PARTY(tag ballots_to_tags.tag_id%TYPE ,coun1 meps.national_party%TYPE, coun2 meps.national_party%TYPE)
RETURNS DECIMAL AS $$
DECLARE
	curs CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE (national_party = coun1 or national_party = coun2) AND tag_id = tag ;
	total INTEGER :=count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE (national_party = coun1 or national_party =coun2) AND tag_id = tag) as f;
	coun INTEGER :=0; 
BEGIN
	FOR outc in curs LOOP
		IF(SIMILARITY_NATIONAL_PARTY(outc.ballot_id ,coun1, coun2)) THEN coun := coun +1;
		END IF;
	END LOOP;
	if (total != 0) THEN 
	RETURN (coun*100)/total; 
	ELSE RETURN 100;
	END IF;


END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CONTEXUTUAL_SIMILARITY_COUNTRY(tag ballots_to_tags.tag_id%TYPE, np1 meps.country%TYPE, np2 meps.country%TYPE)
RETURNS DECIMAL AS $$
DECLARE
	curs CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE (country = np1 or country = np2) AND tag_id=tag ;
	total INTEGER := count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE (country = np1 or country = np2) AND tag_id=tag ) as f;
	coun INTEGER :=0; 
BEGIN
	FOR outc in curs LOOP
		IF(SIMILARITY_NATIONAL_COUNTRY(outc.ballot_id ,np1, np2)) THEN coun := coun +1;
		END IF;
	END LOOP;
	if (total != 0) THEN 
	RETURN (coun*100)/total; 
	ELSE RETURN 100;
	END IF;

END $$ LANGUAGE plpgsql;

/* Dit si une un élu est en accord avec son groupe */
CREATE OR REPLACE FUNCTION daccord_group(mep meps.mepid%TYPE, ballot ballots.ballot_id%type)
RETURNS INTEGER AS $$
DECLARE
grp meps.groupe_id%type := groupe_id FROM MEPS WHERE mepid=mep;
vote character varying(20) := outcome FROM OUTCOMES NATURAL JOIN MEPS WHERE mepid=mep and ballot_id = ballot;
ret INTEGER;
BEGIN
	vote:=MAJORITY_VOTE_GROUPE(ballot, grp);
	IF (vote = 'For' AND ret IN  (1,4,5,7)) THEN RETURN 1; END IF;
	IF (vote ='Against' AND ret IN (2,4,6,7)) THEN RETURN 1; END IF;
	IF (vote ='Abstain' AND ret IN (3,5,6,7)) THEN RETURN 1; END IF;
	RETURN 0;
END $$ LANGUAGE PLPGSQL;

/* Dit si une un élu est en accord avec son pays */

CREATE OR REPLACE FUNCTION daccord_country(mep meps.mepid%TYPE, ballot ballots.ballot_id%type)
RETURNS INTEGER AS $$
DECLARE
partip meps.country%type := country FROM MEPS WHERE mepid=mep;
vote meps.national_party%type := outcome FROM OUTCOMES NATURAL JOIN MEPS WHERE mepid=mep and ballot_id = ballot;
ret INTEGER;
BEGIN
	ret:=MAJORITY_VOTE_COUNTRY(ballot, partip);
	IF (vote = 'For' AND ret IN  (1,4,5,7)) THEN RETURN 1; END IF;
	IF (vote ='Against' AND ret IN (2,4,6,7)) THEN RETURN 1; END IF;
	IF (vote ='Abstain' AND ret IN (3,5,6,7)) THEN RETURN 1; END IF;
	RETURN 0;
END $$ LANGUAGE PLPGSQL;

/* Dit si une un élu est en accord avec son parti */
CREATE OR REPLACE FUNCTION daccord_party(mep meps.mepid%TYPE, ballot ballots.ballot_id%type)
RETURNS INTEGER AS $$
DECLARE
partip meps.national_party%type := national_party FROM MEPS WHERE mepid=mep;
vote meps.national_party%type := outcome FROM OUTCOMES NATURAL JOIN MEPS WHERE mepid=mep and ballot_id = ballot;
ret INTEGER;
BEGIN
	ret:=MAJORITY_VOTE_PARTY(ballot, partip);
	IF (vote = 'For' AND ret IN  (1,4,5,7)) THEN RETURN 1; END IF;
	IF (vote ='Against' AND ret IN (2,4,6,7)) THEN RETURN 1; END IF;
	IF (vote ='Abstain' AND ret IN (3,5,6,7)) THEN RETURN 1; END IF;
	RETURN 0;
END $$ LANGUAGE PLPGSQL;

/* Pourcentage d'accord d'un élu a son groupe*/
CREATE OR REPLACE FUNCTION perc_group(mep meps.mepid%TYPE)
RETURNS INTEGER AS $$
DECLARE
	CURS CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE mepid=mep;
	total INTEGER := count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE mepid=mep) as f;
	compteur INTEGER := 0;
BEGIN

	For outc in CURS LOOP 
		IF (daccord_group(mep, outc.ballot_id) ) THEN compteur := compteur +1 ; END IF;
	END LOOP;
	IF (total != 0) 
	THEN RETURN compteur*100/ total;
	END IF;
	
END $$ LANGUAGE PLPGSQL;

/* Pourcentage d'accord d'un élu a son parti*/

CREATE OR REPLACE FUNCTION perc_party(mep meps.mepid%TYPE)
RETURNS INTEGER AS $$
DECLARE
	CURS CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE mepid=mep;
	total INTEGER := count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE mepid=mep) as f;
	compteur INTEGER := 0;
BEGIN

	For outc in CURS LOOP 
		IF ( daccord_party(mep, outc.ballot_id) ) THEN compteur := compteur +1 ; END IF;
	END LOOP;
	IF (total != 0) 
	THEN RETURN compteur*100/ total;
	END IF;
	
END $$ LANGUAGE PLPGSQL;


SELECT daccord_country(124710,52447);

/* Pourcentage d'accord d'un élu a son pays*/

CREATE OR REPLACE FUNCTION perc_country(mep meps.mepid%TYPE)
RETURNS INTEGER AS $$
DECLARE
	CURS CURSOR FOR SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN OUTCOMES WHERE mepid=mep;
	total INTEGER := count(*) FROM( SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE mepid=mep) as f;
	compteur INTEGER := 0;
BEGIN

	For outc in CURS LOOP 
		IF (daccord_country(mep, outc.ballot_id) ) THEN compteur := compteur +1 ; END IF;
	END LOOP;
	IF (total != 0) 
	THEN RETURN compteur*100/ total;
	END IF;
	
END $$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION STATISTICS_MEPS()
RETURNS void as $$
DECLARE
	cu CURSOR FOR SELECT mepid FROM MEPS; 
	total INTEGER;
BEGIN
CREATE TABLE IF NOT EXISTS STATISTICS_MEPS(
	mpid INTEGER REFERENCES MEPS(mepid),
	nb_ballots INTEGER,
	per_parti DECIMAL,
	per_groupe DECIMAL,
	per_pays DECIMAL
);
FOR outc in cu LOOP
	total := count(*) FROM(SELECT DISTINCT ballot_id FROM MEPS NATURAL JOIN ballots_to_tags WHERE mepid=outc.mepid) as f;
	INSERT into STATISTICS_MEPS VALUES (outc.mepid,total,perc_party(outc.mepid),perc_group(outc.mepid),perc_country(outc.mepid) );
END LOOP;
END $$ LANGUAGE plpgsql;



