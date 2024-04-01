
--------TABLE CREATION
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    hire_date DATE,
    position_id INT,
    FOREIGN KEY (position_id) REFERENCES Positions(position_id)
);

CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE Positions (
    position_id INT PRIMARY KEY,
    position_name VARCHAR(100)
);

CREATE TABLE Salaries (
    employee_id INT,
    salary INT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Employee_Department_Binding (
    employee_id INT,
    department_id INT,
    PRIMARY KEY (employee_id, department_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-------------DATA INSERT

INSERT INTO Departments (department_id, department_name) VALUES
(1, 'HR Department'),
(2, 'Security Department'),
(3, 'Finance Department'),
(4, 'Marketing Department'),
(5, 'Legal Affairs Department');

INSERT INTO Positions (position_id, position_name) VALUES
(1, 'HR Manager'),
(2, 'Security Engineer'),
(3, 'Auditor'),
(4, 'Content Manager'),
(5, 'Lawyer');

INSERT INTO Employees (employee_id, first_name, last_name, date_of_birth, hire_date, position_id) VALUES
(1, 'Yerdauit', 'Torekhan', '2004-08-12', '2021-05-15', 1),
(2, 'Zhanel', 'Zhakhaeva', '2000-01-01', '2023-02-10', 2),
(3, 'Salamat', 'Muldashov', '2003-07-15', '2024-08-20', 3),
(4, 'David', 'Davidovich', '2000-01-01', '2021-02-10', 4),
(5, 'David', 'Eisenhower', '1890-10-14', '2019-02-10', 5);

INSERT INTO Employees (employee_id, first_name, last_name, date_of_birth, hire_date, position_id) VALUES
(6, 'Miras', 'Kaisagaliyev', '2004-05-05', '2021-10-10', 2);

INSERT INTO Salaries (employee_id, salary) VALUES
(1, 500000.00),
(2, 1500000.00),
(3, 550000.00),
(4, 450000.00),
(5, 1000000.00),
(6, 350000);

INSERT INTO Salaries (employee_id, salary) VALUES
(6, 350000);

INSERT INTO Employee_Department_Binding (employee_id, department_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 2);

---------------------Zadaniya

----1) Сделать выборку всех работников с именем “Давид” из отдела “Снабжение” с полями ФИО, заработная плата, должность

SELECT emp.first_name, emp.last_name, d.department_name, p.position_name, S.salary
FROM Employees as emp
JOIN Employee_Department_Binding edb ON emp.employee_id = edb.employee_id
JOIN Departments D on D.department_id = edb.department_id
JOIN Positions p ON emp.position_id = p.position_id
JOIN Salaries S on emp.employee_id = S.employee_id
WHERE department_name = 'Marketing Department' and emp.first_name = 'David';

-----2)	Посчитать среднюю заработную плату работников по отделам
SELECT d.department_name, AVG(s.salary) AS average_salary
FROM Departments d
JOIN Employee_Department_Binding edb ON d.department_id = edb.department_id
JOIN Employees emp ON edb.employee_id = emp.employee_id
JOIN Salaries s ON emp.employee_id = s.employee_id
GROUP BY d.department_name;

------3) Сделать выборку по должностям, в результате которой отобразятся данные, больше ли средняя ЗП по должности, чем средняя ЗП по всем работникам.

SELECT AVG(salary) FROM Salaries;

SELECT p.position_name, AVG(s.salary) AS average_salary_per_position,
    CASE
        WHEN AVG(s.salary) > (SELECT AVG(salary) FROM Salaries) THEN 'Yes'
        ELSE 'No'
    END AS higher_than_average
FROM Positions p
JOIN Employees emp ON p.position_id = emp.position_id
JOIN Salaries s ON emp.employee_id = s.employee_id
GROUP BY p.position_name;

-----4)	Сделать представление, в котором собраны данные по должностям (Должность, в каких отделах встречается эта должность (в виде массива), список сотрудников, начавших работать в этом отделе не раньше 2021 года (Сгруппировать по отделам) (в формате JSON), средняя заработная плата по должности)

CREATE OR REPLACE VIEW Position_Info_View AS
SELECT
    p.position_name AS Position,
    ARRAY_AGG(d.department_name) AS Departments,
    json_agg(
        json_build_object(
            'employee_id', e.employee_id,
            'first_name', e.first_name,
            'last_name', e.last_name,
            'hire_date', e.hire_date
        )
    ) FILTER (WHERE e.hire_date >= '2021-01-01') AS Employees,
    ROUND(AVG(s.salary), 2) AS Average_Salary
FROM Positions p
JOIN Employees e ON p.position_id = e.position_id
JOIN Salaries s ON e.employee_id = s.employee_id
JOIN Employee_Department_Binding edb ON e.employee_id = edb.employee_id
JOIN Departments d ON edb.department_id = d.department_id
GROUP BY p.position_id;


SELECT * FROM Position_Info_View;


