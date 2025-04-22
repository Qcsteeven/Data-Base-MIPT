CREATE TABLE AcademicPerformance (
    academic_id INTEGER PRIMARY KEY,
    is_absent BOOLEAN,
    mark INTEGER CHECK (mark >= 1 AND mark <= 5),
    student_id INTEGER,
    subject_id INTEGER
);

CREATE TABLE AcademicHistory (
    history_id INTEGER PRIMARY KEY,
    authored_by VARCHAR(200),
    authored_date TIMESTAMP,
    academic_id INTEGER
);

CREATE TABLE Teacher (
    teacher_id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    phone VARCHAR(20) CHECK (phone ~ '^[0-9]{3,15}$'),
    email VARCHAR(200) NOT NULL UNIQUE CHECK (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    history_id INTEGER
);

CREATE TABLE Department (
    department_id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    teacher_id INTEGER
);

CREATE TABLE Schedule (
    shedule_id INTEGER PRIMARY KEY,
    date TIMESTAMP,
    teacher_id INTEGER
);

CREATE TABLE Student (
    student_id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    phone VARCHAR(20) CHECK (phone ~ '^[0-9]{3,15}$'),
    email VARCHAR(200) NOT NULL UNIQUE CHECK (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
);

CREATE TABLE "Group" (
    group_id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    student_id INTEGER,
    department_id INTEGER,
    shedule_id INTEGER
);

CREATE TABLE Faculty (
    faculty_id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    department_id INTEGER,
    group_id INTEGER
);

CREATE TABLE Subject (
    subject_id INTEGER PRIMARY KEY,
    name VARCHAR(200),
    department_id INTEGER,
    shedule_id INTEGER
);


ALTER TABLE AcademicPerformance
    ADD FOREIGN KEY (student_id) REFERENCES Student(student_id),
    ADD FOREIGN KEY (subject_id) REFERENCES Subject(subject_id);

ALTER TABLE AcademicHistory
    ADD FOREIGN KEY (academic_id) REFERENCES AcademicPerformance(academic_id);

ALTER TABLE Teacher
    ADD FOREIGN KEY (history_id) REFERENCES AcademicHistory(history_id);

ALTER TABLE Department
    ADD FOREIGN KEY (teacher_id) REFERENCES Teacher(teacher_id);

ALTER TABLE Schedule
    ADD FOREIGN KEY (teacher_id) REFERENCES Teacher(teacher_id);

ALTER TABLE "Group"
    ADD FOREIGN KEY (department_id) REFERENCES Department(department_id),
    ADD FOREIGN KEY (shedule_id) REFERENCES Schedule(shedule_id);

ALTER TABLE Faculty
    ADD FOREIGN KEY (department_id) REFERENCES Department(department_id),
    ADD FOREIGN KEY (group_id) REFERENCES "Group"(group_id);

ALTER TABLE Subject
    ADD FOREIGN KEY (department_id) REFERENCES Department(department_id),
    ADD FOREIGN KEY (shedule_id) REFERENCES Schedule(shedule_id);
