-- Триггер для проверки уникальности студента при добавлении
CREATE OR REPLACE FUNCTION check_student_before_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF student_exists(NEW.student_id) THEN
        RAISE EXCEPTION 'Студент с ID % уже существует', NEW.student_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER prevent_duplicate_student
BEFORE INSERT ON Student
FOR EACH ROW
EXECUTE FUNCTION check_student_before_insert();

-- Триггер для проверки почты студентов
CREATE OR REPLACE FUNCTION check_student_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email NOT LIKE '%@istu.edu' THEN
        RAISE EXCEPTION 'Email студента должен быть в домене @istu.edu';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_student_email
BEFORE INSERT OR UPDATE ON Student
FOR EACH ROW
EXECUTE FUNCTION check_student_email();

-- Триггер для проверки корректности оценки при добавлении оценки
CREATE OR REPLACE FUNCTION check_absence_and_mark()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_absent = TRUE AND NEW.mark IS NOT NULL THEN
        RAISE EXCEPTION 'Студент отсутствовал, оценка не должна быть выставлена';
    END IF;

    IF NEW.is_absent = FALSE AND NEW.mark IS NULL THEN
        RAISE EXCEPTION 'Студент присутствовал, необходимо указать оценку';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_absence_and_mark
BEFORE INSERT OR UPDATE ON AcademicPerformance
FOR EACH ROW
EXECUTE FUNCTION check_absence_and_mark();

