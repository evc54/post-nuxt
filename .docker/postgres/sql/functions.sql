-- -----------------------------------------------------------------------
-- public functions
-- -----------------------------------------------------------------------

--
-- current user id
--
CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS UUID AS $$
  SELECT current_setting('request.jwt.claim.id', true)::uuid;
$$ LANGUAGE sql IMMUTABLE;

GRANT EXECUTE ON FUNCTION public.current_user_id() TO stduser;
