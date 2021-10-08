CREATE TYPE auth_jwt AS (
  token TEXT
);

CREATE TYPE user_info AS (
  id UUID,
  username TEXT,
  role NAME
);
