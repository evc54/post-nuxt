-- -----------------------------------------------------------------------
-- primary public schema
-- -----------------------------------------------------------------------
CREATE SCHEMA api;

GRANT USAGE ON SCHEMA api TO anonymous;
GRANT USAGE ON SCHEMA api TO stduser;
GRANT ALL PRIVILEGES ON SCHEMA api TO administrator;



-- -----------------------------------------------------------------------
-- functions
-- -----------------------------------------------------------------------


--
-- new user sign up rpc call
--
CREATE OR REPLACE FUNCTION api.signup(
  username TEXT,
  password TEXT
)
RETURNS UUID AS $$
  INSERT INTO auth.users(username, password, role)
    VALUES (signup.username, signup.password, 'stduser')
    RETURNING id;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.signup(TEXT, TEXT) TO authenticator;


--
-- user log in rpc call
--
CREATE OR REPLACE FUNCTION api.login(
  username TEXT,
  password TEXT
)
RETURNS auth_jwt AS $$
DECLARE
  auth_user_id UUID;
  auth_user_role NAME;
  jwt auth_jwt;
BEGIN
  SELECT auth.find_user_id(login.username, login.password)
  INTO auth_user_id;

  IF auth_user_id IS NULL THEN
    RAISE invalid_password USING message = 'incorrect username or password';
  END IF;

  SELECT role FROM auth.users WHERE id = auth_user_id
  INTO auth_user_role;

  SELECT
    auth.sign(row_to_json(r), current_setting('sys.jwt_secret')) AS token
  FROM (
    SELECT
      auth_user_id AS id,
      auth_user_role AS role,
      EXTRACT(epoch FROM now())::int + 3600 AS exp
  ) r
  INTO jwt;

  RETURN jwt;
END
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION api.login(TEXT, TEXT) TO authenticator;


--
-- current user info rpc call
--
CREATE OR REPLACE FUNCTION api.user_info()
RETURNS user_info AS $$
DECLARE
  user_info user_info;
BEGIN
  SELECT id, username, role FROM auth.users
  WHERE id = public.current_user_id()
  INTO user_info;

  IF (user_info IS NULL) THEN
    RAISE EXCEPTION USING errcode = 42501, message = 'non-authenticated user';
  END IF;

  RETURN user_info;
END
$$ LANGUAGE plpgsql IMMUTABLE;

GRANT EXECUTE ON FUNCTION api.user_info() TO stduser;


--
-- create new user for administrator rpc call
--
CREATE OR REPLACE FUNCTION api.new_user(
  username TEXT,
  password TEXT,
  role TEXT
)
RETURNS auth.users AS $$
  INSERT INTO auth.users (username, password, role)
    VALUES (new_user.username, new_user.password, new_user.role)
    RETURNING *;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.new_user(TEXT, TEXT, TEXT) TO administrator;


--
-- change password for current user rpc call
--
CREATE OR REPLACE FUNCTION api.change_password(
  password TEXT
)
RETURNS VOID AS $$
  UPDATE auth.users
    SET password = change_password.password
    WHERE id = public.current_user_id();
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.change_password(TEXT) TO stduser;


--
-- change password for any user for administrator rpc call
--
CREATE OR REPLACE FUNCTION api.change_password(
  id TEXT,
  password TEXT
)
RETURNS VOID AS $$
  UPDATE auth.users
    SET password = change_password.password
    WHERE id = change_password.id::uuid;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.change_password(TEXT, TEXT) TO administrator;


--
-- change user role for administrator rpc call
--
CREATE OR REPLACE FUNCTION api.switch_role(
  id TEXT,
  role TEXT
)
RETURNS VOID AS $$
  UPDATE auth.users
    SET role = switch_role.role
    WHERE id = switch_role.id::uuid;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.switch_role(TEXT, TEXT) TO administrator;


--
-- delete user for administrator rpc call
--
CREATE OR REPLACE FUNCTION api.delete_user(id TEXT)
RETURNS VOID AS $$
  DELETE FROM auth.users
    WHERE id = delete_user.id::uuid;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.delete_user(TEXT) TO administrator;



-- -----------------------------------------------------------------------
-- views
-- -----------------------------------------------------------------------
CREATE VIEW api.users AS
SELECT id, username, role, created_at FROM auth.users;

-- that's because anonymous user can do full table scan
ALTER VIEW api.users OWNER TO anonymous;
GRANT SELECT ON TABLE api.users TO stduser;
GRANT SELECT ON TABLE api.users TO administrator;



-- -----------------------------------------------------------------------
-- tables
-- -----------------------------------------------------------------------


--
-- to do items table
--
CREATE TABLE api.todos(
  id UUID DEFAULT uuid_generate_v4(),
  author_id UUID NOT NULL DEFAULT public.current_user_id(),
  text TEXT,
  done BOOLEAN DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  PRIMARY KEY (id),
  FOREIGN KEY (author_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE INDEX api_todos_author_idx ON api.todos (author_id);
CREATE INDEX api_todos_create_idx ON api.todos (created_at DESC);


--
-- to do items table access rules
--
ALTER TABLE api.todos ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE ON TABLE api.todos TO stduser;
GRANT ALL PRIVILEGES ON TABLE api.todos TO administrator;

CREATE POLICY stduser_api_todo_select
  ON api.todos
  AS PERMISSIVE FOR SELECT
  TO stduser
  USING (true);

CREATE POLICY stduser_api_todo_insert
  ON api.todos
  AS PERMISSIVE FOR INSERT
  TO stduser
  WITH CHECK (author_id = public.current_user_id());

CREATE POLICY stduser_api_todo_update
  ON api.todos
  AS PERMISSIVE FOR UPDATE
  TO stduser
  USING (author_id = public.current_user_id());

CREATE POLICY administrator_api_todo_all
  ON api.todos
  AS PERMISSIVE FOR ALL
  TO administrator
  USING (true);


--
-- to do item comments table
--
CREATE TABLE api.todo_comments(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  todo_id UUID NOT NULL,
  author_id UUID NOT NULL DEFAULT public.current_user_id(),
  text TEXT,
  created_at TIMESTAMP DEFAULT now(),
  FOREIGN KEY (todo_id) REFERENCES api.todos(id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE INDEX api_todo_comments_todo_idx ON api.todo_comments (todo_id);
CREATE INDEX api_todo_comments_author_idx ON api.todo_comments (author_id);
CREATE INDEX api_todo_comments_create_idx ON api.todo_comments (created_at DESC);


--
-- to do item comments table access rules
--
ALTER TABLE api.todo_comments ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE api.todo_comments TO stduser;
GRANT ALL PRIVILEGES ON TABLE api.todo_comments TO administrator;

CREATE POLICY stduser_api_todo_comment_select
  ON api.todo_comments
  AS PERMISSIVE FOR SELECT
  TO stduser
  USING (true);

CREATE POLICY stduser_api_todo_comment_insert
  ON api.todo_comments
  AS PERMISSIVE FOR INSERT
  TO stduser
  WITH CHECK (author_id = public.current_user_id());

CREATE POLICY stduser_api_todo_comment_update
  ON api.todo_comments
  AS PERMISSIVE FOR UPDATE
  TO stduser
  USING (author_id = public.current_user_id());

CREATE POLICY stduser_api_todo_comment_delete
  ON api.todo_comments
  AS PERMISSIVE FOR DELETE
  TO stduser
  USING (author_id = public.current_user_id());

CREATE POLICY administrator_api_todo_comment_all
  ON api.todo_comments
  AS PERMISSIVE FOR ALL
  TO administrator
  USING (true);



-- -----------------------------------------------------------------------
-- computed columns
-- -----------------------------------------------------------------------


---
--- author incomplete to do count
---
CREATE OR REPLACE FUNCTION api.author_todo_count(api.users)
RETURNS BIGINT AS $$
  SELECT COUNT(*)
    FROM api.todos
    WHERE author_id = $1.id AND api.todos.done = FALSE;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.author_todo_count(api.users) TO stduser;


---
--- author completed to do count
---
CREATE OR REPLACE FUNCTION api.author_done_count(api.users)
RETURNS BIGINT AS $$
  SELECT COUNT(*)
    FROM api.todos
    WHERE author_id = $1.id AND api.todos.done = TRUE;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.author_done_count(api.users) TO stduser;


---
--- author to do comments count
---
CREATE OR REPLACE FUNCTION api.author_todo_comment_count(api.users)
RETURNS BIGINT AS $$
  SELECT COUNT(*) FROM api.todo_comments WHERE author_id = $1.id;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.author_todo_comment_count(api.users) TO stduser;


---
--- to do item author
---
CREATE OR REPLACE FUNCTION api.todo_author(api.todos)
RETURNS api.users AS $$
  SELECT * FROM api.users WHERE id = $1.author_id LIMIT 1;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.todo_author(api.todos) TO stduser;


---
--- to do item comments count
---
CREATE OR REPLACE FUNCTION api.todo_comment_count(api.todos)
RETURNS BIGINT AS $$
  SELECT COUNT(*) FROM api.todo_comments WHERE todo_id = $1.id;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.todo_comment_count(api.todos) TO stduser;


---
--- to do comment author
---
CREATE OR REPLACE FUNCTION api.todo_comment_author(api.todo_comments)
RETURNS api.users AS $$
  SELECT * FROM api.users WHERE id = $1.author_id LIMIT 1;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION api.todo_comment_author(api.todo_comments) TO stduser;
