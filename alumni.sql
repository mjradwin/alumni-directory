-- $Id: alumni.sql,v 1.2 2006/02/07 17:05:27 mradwin Exp mradwin $

DROP TABLE IF EXISTS aid_alumnus;
DROP TABLE IF EXISTS aid_alumnus_s;
DROP TABLE IF EXISTS aid_note;
DROP TABLE IF EXISTS aid_note_s;
DROP TABLE IF EXISTS aid_reunion;
DROP TABLE IF EXISTS aid_verify;
DROP TABLE IF EXISTS aid_bounce;
DROP TABLE IF EXISTS aid_limit;

CREATE TABLE aid_alumnus (
al_id INT NOT NULL auto_increment,
al_status TINYINT(4) NOT NULL, -- valid bit describing status
al_name_surname VARCHAR(100) NOT NULL,	-- Last Name/Maiden Name
al_name_married VARCHAR(100),	-- Married Last Name
al_name_given VARCHAR(100) NOT NULL,	-- First Name
al_name_mi VARCHAR(1),	-- Middle Initial
al_email VARCHAR(200) NOT NULL,	-- E-mail Address
al_gradclass YEAR(4),	-- Graduation Year or NULL for Other
al_affil_other VARCHAR(40), -- "Teacher" or some non-gradyear affiliation
al_web_page VARCHAR(1024),	-- Personal Web Page
al_location VARCHAR(100),	-- Location
al_email_old VARCHAR(200),	-- Previous E-mail Address
al_host VARCHAR(200),	-- REMOTE_HOST of last update
al_quarterly TINYINT(4) NOT NULL,	-- type of quarterly emailing
al_reunion TINYINT(1) NOT NULL,	-- bit for reunion email request
al_alias VARCHAR(8),	-- alias (a.k.a. nickname)
al_ts_bounce DATETIME,	-- unix time - first bounce (0 if none)
al_ts_create DATETIME NOT NULL,	-- unix time - record creation
al_ts_update TIMESTAMP NOT NULL,	-- unix time - last update
al_ts_fresh DATETIME,	-- unix time - last successful verification
al_ts_emailupd DATETIME,	-- unix time - last update to email
PRIMARY KEY (al_id),
KEY al_email (al_email),
KEY al_status (al_status),
KEY al_gradclass (al_gradclass),
FULLTEXT (al_name_surname,al_name_married,al_name_given)
);

CREATE TABLE aid_note (
note_id INT NOT NULL,
note_text TEXT NOT NULL,
PRIMARY KEY (note_id)
);

CREATE TABLE aid_reunion (
reunion_gradclass VARCHAR(100) NOT NULL,
reunion_date DATE,
reunion_text TEXT NOT NULL,
PRIMARY KEY (reunion_gradclass)
);

CREATE TABLE aid_verify (
verify_code VARCHAR(24) NOT NULL,
verify_time TIMESTAMP NOT NULL,
verify_staging_id INT NOT NULL,
verify_id INT,
PRIMARY KEY verify_code (verify_code)
);

CREATE TABLE aid_bounce (
bounce_email VARCHAR(200) NOT NULL,
bounce_time TIMESTAMP NOT NULL,
bounce_reason TEXT,
bounce_std_reason VARCHAR(16),
KEY bounce_email (bounce_email)
);

CREATE TABLE aid_limit (
limit_name VARCHAR(30),
limit_count TINYINT,
PRIMARY KEY (limit_name)
);

CREATE TABLE aid_alumnus_s LIKE aid_alumnus;
CREATE TABLE aid_note_s LIKE aid_note;

/*
CREATE TABLE aid_timestamps (
ts_name varchar(20),
ts_time TIMESTAMP NOT NULL,
PRIMARY KEY (ts_name)
);
*/
