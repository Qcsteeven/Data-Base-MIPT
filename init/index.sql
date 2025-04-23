-- Индекс 1. Для ускорения поиска оценок по студенту и предмету
CREATE INDEX idx_academic_performance_student_subject ON AcademicPerformance(student_id, subject_id);

-- Индекс 2. Для ускорения поиска по дате в расписании
CREATE INDEX idx_schedule_date ON Schedule(date);

-- Индекс 3. Ускоряет поиск преподавателей по кафедрам
CREATE INDEX idx_teacher_department ON Teacher(teacher_id, (SELECT department_id FROM Department WHERE teacher_id = Teacher.teacher_id));

-- Индекс 4. Оптимизирует запросы к будущим занятиям
CREATE INDEX idx_future_schedule ON Schedule(date) 
WHERE date > CURRENT_TIMESTAMP;