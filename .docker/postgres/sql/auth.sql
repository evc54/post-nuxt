-- -----------------------------------------------------------------------
-- authentication and authorization schema
-- -----------------------------------------------------------------------
CREATE SCHEMA auth;


--
-- schema access rules
--
GRANT USAGE ON SCHEMA auth TO anonymous;
GRANT USAGE ON SCHEMA auth TO stduser;
GRANT USAGE ON SCHEMA auth TO administrator;


--
-- user's table
--
CREATE TABLE auth.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(32) NOT NULL CHECK (username ~* '^[A-Za-z0-9]{4,10}$'),
  password VARCHAR(64) NOT NULL CHECK (length(password) > 6),
  role VARCHAR(32) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX auth_users_username_uniq_idx ON auth.users (username);
CREATE INDEX auth_users_create_idx ON auth.users (created_at DESC);


--
-- user's table access rules
--
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT ON TABLE auth.users TO anonymous;
GRANT SELECT, UPDATE ON TABLE auth.users TO stduser;
GRANT ALL PRIVILEGES ON TABLE auth.users TO administrator;

CREATE POLICY administrator_auth_users_all
  ON auth.users
  AS PERMISSIVE FOR ALL
  TO administrator
  USING (true);

CREATE POLICY stduser_auth_users_select_self
  ON auth.users
  AS PERMISSIVE FOR SELECT
  TO stduser
  USING (id = public.current_user_id());

CREATE POLICY anonymous_auth_users_select_login
  ON auth.users
  AS PERMISSIVE FOR SELECT
  TO anonymous
  USING (true);

CREATE POLICY anonymous_auth_users_insert_signup
  ON auth.users
  AS PERMISSIVE FOR INSERT
  TO anonymous
  WITH CHECK (role = 'stduser');


--
-- user's table constraints
--
CREATE OR REPLACE FUNCTION auth.users_validate_and_encrypt_password()
RETURNS TRIGGER AS $$
DECLARE
  username_length INTEGER;
  password_length INTEGER;
  exist_user_id TEXT DEFAULT NULL;
BEGIN
  IF TG_OP = 'INSERT' OR NEW.username <> OLD.username THEN
    SELECT LENGTH(NEW.username)
      INTO username_length;

    -- min. username length check
    IF username_length < 4 THEN
      RAISE foreign_key_violation USING
        message = 'username is too short',
        hint = 'username min. length is 4 symbols';
      RETURN NULL;
    END IF;

    -- max. username length check
    IF username_length > 10 THEN
      RAISE foreign_key_violation USING
        message = 'username is too long',
        hint = 'username max. length is 10 symbols';
      RETURN NULL;
    END IF;

    SELECT id
      FROM auth.users
      WHERE auth.users.username = NEW.username
      INTO exist_user_id;

    -- username uniqueness check
    IF exist_user_id IS NOT NULL THEN
      RAISE foreign_key_violation USING
        message = 'username is already taken',
        hint = 'choose another username';
      RETURN NULL;
    END IF;
  END IF;

  IF TG_OP = 'INSERT' OR NEW.password <> OLD.password THEN
    SELECT LENGTH(NEW.password)
      INTO password_length;

    -- min. password length check
    IF password_length < 6 THEN
      RAISE foreign_key_violation USING
        message = 'password is too short',
        hint = 'password min. length is 6 symbols';
      RETURN NULL;
    END IF;

    -- max. password length check
    IF password_length > 16 THEN
      RAISE foreign_key_violation USING
        message = 'password is too long',
        hint = 'password max. length is 16 symbols';
      RETURN NULL;
    END IF;

    -- encrypt plain text password
    NEW.password = crypt(NEW.password, gen_salt('bf'));
  END IF;

  -- role exist check
  IF NOT EXISTS (SELECT 1 FROM pg_roles AS r WHERE r.rolname = NEW.role) THEN
    RAISE foreign_key_violation USING
      message = 'unknown role ' || NEW.role;
    RETURN NULL;
  END IF;

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER auth_users_validation
  BEFORE INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE auth.users_validate_and_encrypt_password();


--
-- find user id by username and password
--
CREATE OR REPLACE FUNCTION auth.find_user_id(
  username TEXT,
  password TEXT
)
RETURNS UUID AS $$
BEGIN
  IF find_user_id.username IS NULL OR find_user_id.username = '' THEN
    RAISE EXCEPTION USING message = 'username can not be empty';
  END IF;

  IF find_user_id.password IS NULL OR find_user_id.password = '' THEN
    RAISE EXCEPTION USING message = 'password can not be empty';
  END IF;

  RETURN (
    SELECT id FROM auth.users
    WHERE
      users.username = find_user_id.username
    AND
      users.password = crypt(find_user_id.password::text, users.password::text)
    LIMIT 1
  );
END
$$ LANGUAGE plpgsql STABLE;


--
-- jwt related functions
--
CREATE OR REPLACE FUNCTION auth.url_encode(data bytea)
RETURNS TEXT AS $$
  SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION auth.url_decode(data text)
RETURNS BYTEA AS $$
  WITH t AS (SELECT translate(data, '-_', '+/') AS trans),
  rem AS (SELECT length(t.trans) % 4 AS remainder FROM t) -- compute padding size
  SELECT decode(
    t.trans ||
    CASE WHEN rem.remainder > 0
    THEN repeat('=', (4 - rem.remainder))
    ELSE '' END,
  'base64') FROM t, rem;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION auth.algorithm_sign(
  signables text,
  secret text,
  algorithm text
)
RETURNS TEXT AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END AS id
  )  -- hmac throws error
  SELECT auth.url_encode(hmac(signables, secret, alg.id)) FROM alg;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION auth.sign(
  payload json,
  secret text,
  algorithm text DEFAULT 'HS256'
)
RETURNS TEXT AS $$
  WITH
    header AS (
      SELECT auth.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) AS data
    ),
    payload AS (
      SELECT auth.url_encode(convert_to(payload::text, 'utf8')) AS data
    ),
    signables AS (
      SELECT header.data || '.' || payload.data AS data FROM header, payload
    )
  SELECT
    signables.data || '.' ||
    auth.algorithm_sign(signables.data, secret, algorithm) FROM signables;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION auth.verify(
  token text,
  secret text,
  algorithm text DEFAULT 'HS256'
)
RETURNS TABLE(header json, payload json, valid boolean) AS $$
  SELECT
    convert_from(auth.url_decode(r[1]), 'utf8')::json AS header,
    convert_from(auth.url_decode(r[2]), 'utf8')::json AS payload,
    r[3] = auth.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
  FROM regexp_split_to_array(token, '\.') r;
$$ LANGUAGE sql;
