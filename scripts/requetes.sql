/* KHELILI ADRIAN P1612177 
   MOULAY LAKHDAR SARAH p1511065
*/ 


/* Ecrire une requˆete qui permet de retourner l’ensemble des d´eput´es appar- ´
tenant `a un parti politique. */
SELECT * FROM Meps WHERE national_party != '-' ;

/* Ecrire une requˆete qui permet d’ordonner les parlementaires selon leur ´
assiduit´e (pourcentage de scrutins dans lequels le parlementaire a ´et´e
pr´esent). */
SELECT mepid, count(*) FROM outcomes GROUP BY mepid ORDER BY  count(*) desc;

/* Quelle est l’assiduit´e moyenne des membres du parlement?*/
SELECT count(*)/(SELECT count(*) FROM meps) FROM outcomes;

/*Ecrire une requˆete qui retourne pour chaque groupe, le nombre de mem- ´
bres.*/
SELECT groupe_id, count(*) FROM MEPS  GROUP BY groupe_id;

/*Ecrire une requˆete qui retourne pour chaque groupe, l’assiduit´e moyenne.*/

SELECT b.groupe_id, count(*)/(SELECT count(*) FROM MEPS WHERE groupe_id = b.groupe_id ) FROM MEPS b NATURAL JOIN outcomes GROUP BY b.groupe_id;

/* Ecrire une requˆete qui retourne pour chaque groupe politique, le d´eput´e ´
qui est le plus en accord avec le groupe (sur un scrutin, un d´eput´e est 
consid´er´e en accord avec son groupe si son vote est ´egal au vote majoritaire
du groupe), afficher aussi le % d’accord du d´eput´e*/
SELECT mepid, name_full, gid, outc, max FROM MEPS NATURAL JOIN OUTCOMES JOIN (

	SELECT k.gid,m.outc, k.max FROM 
		(	SELECT gid, MAX(nb_vote) FROM (
				SELECT groupe_id as gid, outcome as outc, COUNT(mepid) as nb_vote FROM MEPS mp NATURAL JOIN OUTCOMES ot GROUP BY groupe_id, outc
			) t GROUP BY gid
		) k, (
				SELECT groupe_id as gid, outcome as outc, COUNT(mepid) as nb_vote FROM MEPS mp NATURAL JOIN OUTCOMES ot GROUP BY groupe_id, outc
				
		) m WHERE k.max = nb_vote AND k.gid = m.gid
	) j ON j.gid = groupe_id AND j.outc = outcome GROUP BY mepid, name_full, gid, outc, max;

