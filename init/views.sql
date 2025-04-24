-- Представление 1. Студенты с их средним баллом
CREATE VIEW student_avg_marks AS
SELECT 
    s.student_id,
    s.name AS student_name,
    g.name AS group_name,
    ROUND(AVG(ap.mark), 2) AS avg_mark,
    COUNT(ap.academic_id) AS subjects_count
FROM Student s
JOIN "Group" g ON s.student_id = g.student_id
LEFT JOIN AcademicPerformance ap ON s.student_id = ap.student_id
GROUP BY s.student_id, s.name, g.name;

-- Представление 2. Преподаватели и количество проведенных занятий
CREATE VIEW teacher_schedule_stats AS
SELECT 
    t.teacher_id,
    t.name AS teacher_name,
    d.name AS department,
    COUNT(sch.shedule_id) AS classes_count,
    MIN(sch.date) AS first_class,
    MAX(sch.date) AS last_class
FROM Teacher t
JOIN Department d ON t.teacher_id = d.teacher_id
LEFT JOIN Schedule sch ON t.teacher_id = sch.teacher_id
GROUP BY t.teacher_id, t.name, d.name;

-- Представление 3. Сводка по факультетам
CREATE OR REPLACE VIEW faculty_analytics_dashboard AS
WITH faculty_stats AS (
    SELECT 
        f.faculty_id,
        f.name AS faculty_name,
        COUNT(DISTINCT g.group_id) AS groups_count,
        COUNT(DISTINCT s.student_id) AS students_count,
        COUNT(DISTINCT d.department_id) AS departments_count,
        COUNT(DISTINCT t.teacher_id) AS teachers_count,
        COUNT(DISTINCT sub.subject_id) AS subjects_count
    FROM Faculty f
    LEFT JOIN "Group" g ON f.group_id = g.group_id
    LEFT JOIN Student s ON g.student_id = s.student_id
    LEFT JOIN Department d ON f.department_id = d.department_id
    LEFT JOIN Teacher t ON d.teacher_id = t.teacher_id
    LEFT JOIN Subject sub ON d.department_id = sub.department_id
    GROUP BY f.faculty_id, f.name
),
performance_stats AS (
    SELECT 
        f.faculty_id,
        ROUND(AVG(ap.mark), 2) AS avg_mark,
        ROUND(STDDEV(ap.mark), 2) AS mark_stddev,
        COUNT(CASE WHEN ap.mark = 5 THEN 1 END) AS excellent_count,
        COUNT(CASE WHEN ap.mark = 2 THEN 1 END) AS fail_count,
        COUNT(CASE WHEN ap.is_absent THEN 1 END) AS absences_count,
        COUNT(ap.academic_id) AS total_records
    FROM Faculty f
    LEFT JOIN "Group" g ON f.group_id = g.group_id
    LEFT JOIN Student s ON g.student_id = s.student_id
    LEFT JOIN AcademicPerformance ap ON s.student_id = ap.student_id
    GROUP BY f.faculty_id
),
schedule_stats AS (
    SELECT 
        f.faculty_id,
        COUNT(DISTINCT sch.shedule_id) AS classes_count,
        MIN(sch.date) AS first_class_date,
        MAX(sch.date) AS last_class_date
    FROM Faculty f
    LEFT JOIN Department d ON f.department_id = d.department_id
    LEFT JOIN Subject sub ON d.department_id = sub.department_id
    LEFT JOIN Schedule sch ON sub.shedule_id = sch.shedule_id
    GROUP BY f.faculty_id
)
SELECT 
    fs.faculty_id,
    fs.faculty_name,
    fs.groups_count,
    fs.students_count,
    fs.departments_count,
    fs.teachers_count,
    fs.subjects_count,
    ps.avg_mark,
    ps.mark_stddev,
    ps.excellent_count,
    ps.fail_count,
    ps.absences_count,
    ROUND(ps.fail_count::NUMERIC / NULLIF(ps.total_records, 0) * 100, 2) AS fail_percentage,
    ROUND(ps.excellent_count::NUMERIC / NULLIF(ps.total_records, 0) * 100, 2) AS excellent_percentage,
    ROUND(ps.absences_count::NUMERIC / NULLIF(ps.total_records, 0) * 100, 2) AS absence_percentage,
    ss.classes_count,
    ss.first_class_date,
    ss.last_class_date,
    CASE 
        WHEN ps.avg_mark >= 4.5 THEN 'Отличная'
        WHEN ps.avg_mark >= 4.0 THEN 'Хорошая'
        WHEN ps.avg_mark >= 3.5 THEN 'Удовлетворительная'
        ELSE 'Низкая'
    END AS performance_level
FROM faculty_stats fs
JOIN performance_stats ps ON fs.faculty_id = ps.faculty_id
JOIN schedule_stats ss ON fs.faculty_id = ss.faculty_id;