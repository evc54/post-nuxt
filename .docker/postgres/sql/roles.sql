-- -----------------------------------------------------------------------
-- database roles
-- -----------------------------------------------------------------------

DROP ROLE IF EXISTS authenticator;
DROP ROLE IF EXISTS administrator;
DROP ROLE IF EXISTS stduser;
DROP ROLE IF EXISTS anonymous;

CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'password';
CREATE ROLE administrator NOLOGIN;
CREATE ROLE stduser NOLOGIN;
CREATE ROLE anonymous NOLOGIN;
GRANT administrator TO authenticator;
GRANT stduser TO authenticator;
GRANT anonymous TO authenticator;
