-- Процедура добавления студента
CREATE OR REPLACE PROCEDURE add_student(
    p_student_id INTEGER,
    p_name VARCHAR(200),
    p_phone VARCHAR(20),
    p_email VARCHAR(200))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Student (student_id, name, phone, email) 
    VALUES (p_student_id, p_name, p_phone, p_email);
    COMMIT;
END;
$$;

-- Функция подсчета студентов в группе
CREATE OR REPLACE FUNCTION count_students_in_group(p_group_name VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    student_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO student_count
    FROM "Group"
    WHERE name = p_group_name;
    
    RETURN student_count;
END;
$$;

-- Функция проверки существования студента
CREATE OR REPLACE FUNCTION student_exists(p_student_id INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM Student WHERE student_id = p_student_id);
END;
$$;