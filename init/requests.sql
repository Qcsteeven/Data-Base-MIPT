-- 1. Запрос с WHERE и ORDER BY (Список студентов с оценками выше 4 по предмету "Базы данных")
SELECT s.name AS student_name, ap.mark
FROM Student s
JOIN AcademicPerformance ap ON s.student_id = ap.student_id
JOIN Subject sub ON ap.subject_id = sub.subject_id
WHERE sub.name = 'Базы данных' AND ap.mark > 4
ORDER BY ap.mark DESC, s.name;

-- 2. Запрос с GROUP BY ( сколько студентов получили каждую конкретную оценку (от 1 до 5))
SELECT mark, COUNT(*) AS student_count
FROM AcademicPerformance
GROUP BY mark
ORDER BY mark;

-- 3. Запрос с HAVING (Сколько студентов получили каждую конкретную оценку (от 1 до 5), но только те оценки, которые получили более 5 студентов)
SELECT mark, COUNT(*) AS student_count
FROM AcademicPerformance
GROUP BY mark
HAVING COUNT(*) > 5
ORDER BY mark;

-- 4. Запрос с JOIN и подзапросом (Преподаватели, которые выставляли оценки выше среднего)
SELECT DISTINCT t.name AS teacher_name
FROM Teacher t
JOIN AcademicHistory ah ON t.history_id = ah.history_id
JOIN AcademicPerformance ap ON ah.academic_id = ap.academic_id
WHERE ap.mark > (SELECT AVG(mark) FROM AcademicPerformance WHERE mark IS NOT NULL);

-- 5. Запрос с оконной функцией (Рейтинг студентов по среднему баллу)
SELECT 
    s.name AS student_name,
    AVG(ap.mark) AS avg_mark,
    RANK() OVER (ORDER BY AVG(ap.mark) DESC) AS student_rank
FROM Student s
JOIN AcademicPerformance ap ON s.student_id = ap.student_id
WHERE ap.mark IS NOT NULL
GROUP BY s.student_id, s.name
ORDER BY avg_mark DESC
LIMIT 10;

-- 6. Запрос с EXISTS (Студенты, не имеющие пропусков)
SELECT s.name AS student_name
FROM Student s
WHERE NOT EXISTS (
    SELECT 1 
    FROM AcademicPerformance ap 
    WHERE ap.student_id = s.student_id AND ap.is_absent = TRUE
);

-- 7. Запрос с самосоединением и INNER JOIN (Пары предметов, которые ведут преподаватели с одной кафедры)
SELECT 
    s1.name AS subject1, 
    s2.name AS subject2, 
    d.name AS department_name
FROM Subject s1
INNER JOIN Subject s2 ON s1.department_id = s2.department_id AND s1.subject_id < s2.subject_id
INNER JOIN Department d ON s1.department_id = d.department_id
ORDER BY d.name, s1.name, s2.name;

-- 8. Запрос с агрегирующей оконной функцией (Сравнение оценки студента со средней по группе)
SELECT 
    g.name AS group_name,
    s.name AS student_name,
    sub.name AS subject_name,
    ap.mark,
    AVG(ap.mark) OVER (PARTITION BY g.group_id, sub.subject_id) AS group_avg_mark,
    ap.mark - AVG(ap.mark) OVER (PARTITION BY g.group_id, sub.subject_id) AS diff_from_avg
FROM Student s
JOIN AcademicPerformance ap ON s.student_id = ap.student_id
JOIN Subject sub ON ap.subject_id = sub.subject_id
JOIN "Group" g ON s.student_id = g.student_id
WHERE ap.mark IS NOT NULL
ORDER BY g.name, s.name;

-- 9. Запрос с подзапросом и IN (Студенты групп ИСИб)
SELECT s.name AS student_name, g.name AS group_name
FROM Student s
JOIN "Group" g ON s.student_id = g.student_id
WHERE g.name IN (
    SELECT name 
    FROM "Group" 
    WHERE name LIKE 'ИСИб%'
)
ORDER BY g.name, s.name;

-- 10. Запрос с LIMIT/OFFSET (Вывести имена студентов, которые получили оценку выше 3, и ограничить результат 5 строками)
SELECT s.name
FROM Student s
WHERE s.student_id IN (
    SELECT ap.student_id
    FROM AcademicPerformance ap
    WHERE ap.mark > 3
)
LIMIT 5 OFFSET 5;


-- 11. Сложный запрос с несколькими JOIN, GROUP BY и HAVING (Факультеты с успеваемостью выше среднего)
SELECT 
    f.name AS faculty_name,
    AVG(ap.mark) AS avg_mark,
    COUNT(DISTINCT s.student_id) AS student_count
FROM Faculty f
JOIN "Group" g ON f.group_id = g.group_id
JOIN Student s ON g.student_id = s.student_id
JOIN AcademicPerformance ap ON s.student_id = ap.student_id
WHERE ap.mark IS NOT NULL
GROUP BY f.faculty_id, f.name
HAVING AVG(ap.mark) > (
    SELECT AVG(mark) 
    FROM AcademicPerformance 
    WHERE mark IS NOT NULL
)
ORDER BY avg_mark DESC;