-- Индекс 1. Для ускорения поиска оценок по студенту и предмету
CREATE INDEX idx_academic_performance_student_subject ON AcademicPerformance(student_id, subject_id)
WHERE mark IS NOT NULL;

-- Индекс 2. Для ускорения поиска по дате в расписании
CREATE INDEX idx_schedule_date ON Schedule(date);

-- Индекс 3. Для ускорения поиска по имени учителя
CREATE INDEX idx_teacher_name ON teacher(name);

