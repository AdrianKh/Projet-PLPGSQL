SELECT * FROM pg_catalog.pg_tables;

CREATE TABLE BALLOTS(

	ballot_id INTEGER PRIMARY KEY,
	vote_date timestamp,
	comittee VARCHAR(30)

);

CREATE TABLE TAGS(
	
	tag_id varchar(20) PRIMARY KEY,
	tag_label varchar(255)

);

CREATE TABLE BALLOTS_TO_TAGS(

	ballot_id INTEGER REFERENCES BALLOTS(ballot_id),
	tag_id varchar(30) REFERENCES TAGS(tag_id)
	
);


CREATE TABLE MEPS(

	mepid INTEGER PRIMARY KEY,
	name_full VARCHAR(100),
	country VARCHAR(30),
	national_party VARCHAR(255),
	groupe_id VARCHAR(10),
	gender VARCHAR(2)

);

CREATE TABLE OUTCOMES(

	ballot_id INTEGER REFERENCES BALLOTS(ballot_id),
	mepid INTEGER REFERENCES MEPS(mepid),
	outcome VARCHAR(20),
	UNIQUE (ballot_id, mepid)
);




