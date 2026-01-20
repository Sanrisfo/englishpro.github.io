--  File: delete_user_function.sql
--  Description: Creates a security-definer function to allow teachers to securely delete students.

-- Drop the function if it already exists to ensure a clean setup
DROP FUNCTION IF EXISTS delete_student;

-- Create the function
CREATE OR REPLACE FUNCTION delete_student(student_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  caller_id uuid;
  caller_role text;
BEGIN
  -- Get the UID of the user calling this function
  caller_id := auth.uid();

  -- Check if the caller is a teacher
  SELECT rol INTO caller_role
  FROM public.usuarios
  WHERE supabase_uid = caller_id;

  IF caller_role = 'Docente' THEN
    -- If the caller is a teacher, proceed to delete the student from the auth schema.
    -- The corresponding row in public.usuarios will be deleted automatically by a trigger.
    DELETE FROM auth.users WHERE id = student_id;
    RETURN 'Student deleted successfully.';
  ELSE
    -- If the caller is not a teacher, raise an exception
    RAISE EXCEPTION 'Insufficient permissions. You must be a teacher to delete a student.';
  END IF;
END;
$$;
