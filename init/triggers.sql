-- Триггер для автоматического логирования изменений оценок
CREATE OR REPLACE FUNCTION log_mark_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.mark IS DISTINCT FROM OLD.mark THEN
        INSERT INTO AcademicHistory(authored_by, authored_date, academic_id)
        VALUES (current_user, now(), NEW.academic_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_mark_change
AFTER UPDATE ON AcademicPerformance
FOR EACH ROW
EXECUTE FUNCTION log_mark_change();

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


-- Триггер для обновления средней оценки студента при изменении оценки
CREATE OR REPLACE FUNCTION update_student_avg_mark()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Student
    SET avg_mark = (
        SELECT AVG(mark) 
        FROM AcademicPerformance 
        WHERE student_id = NEW.student_id AND mark IS NOT NULL
    )
    WHERE student_id = NEW.student_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_student_avg_mark
AFTER INSERT OR UPDATE OR DELETE ON AcademicPerformance
FOR EACH ROW
EXECUTE FUNCTION update_student_avg_mark();