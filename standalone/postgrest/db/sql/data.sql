-- -----------------------------------------------------------------------
-- default data
-- -----------------------------------------------------------------------

INSERT INTO auth.users (username, password, role) VALUES
('admin', 'password', 'administrator');

DO $$
DECLARE
  counter INTEGER := 0;
BEGIN
  WHILE counter < 100 LOOP
    counter := counter + 1;
    INSERT INTO auth.users (username, password, role)
      VALUES ('user' || counter, 'password', 'stduser');
  END LOOP;
END
$$ LANGUAGE plpgsql;


DO $$
DECLARE
  user_cursor CURSOR
   FOR SELECT * FROM auth.users ORDER BY created_at ASC;
  todo_counter INTEGER;
  user_rec RECORD;
BEGIN
  FOR user_rec IN user_cursor LOOP
    todo_counter := 0;
    WHILE todo_counter < 10 LOOP
      todo_counter := todo_counter + 1;
      INSERT INTO api.todos (author_id, text)
        VALUES (user_rec.id, 'todo #' || todo_counter);
    END LOOP;
  END LOOP;
END
$$ LANGUAGE plpgsql;


DO $$
DECLARE
  todo_cursor CURSOR
   FOR SELECT * FROM api.todos ORDER BY created_at ASC;
  user_cursor CURSOR
   FOR SELECT * FROM auth.users ORDER BY created_at ASC;
  todo_rec RECORD;
  user_rec RECORD;
BEGIN
  FOR todo_rec IN todo_cursor LOOP
    FOR user_rec IN user_cursor LOOP
      INSERT INTO api.todo_comments(todo_id, author_id, text)
        VALUES (todo_rec.id, user_rec.id, 'comment');
    END LOOP;
  END LOOP;
END
$$ LANGUAGE plpgsql;
