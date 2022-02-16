-- Выбрать все колонки из таблицы HumanResources.Department, 
-- где в колонке GroupName значение содержит слово “Research” в любом месте,
-- отсортированные по DepartmentId в обратном порядке

SELECT 
	*
FROM 
	humanresources.department 
WHERE 
	groupname LIKE  '%Research%' 
	ORDER BY departmentid DESC

-- Выбрать из таблицы HumanResources.Employee колонки BusinessEntityId, JobTitle, BirthDate, Gender,
-- для которых BusinessEntityId имеет значение больше 50 и меньше 100 включительно

SELECT
   businessentityid,
   jobtitle,
   birthdate,
   gender
FROM
   humanresources.employee
WHERE
   businessentityid BETWEEN 50
   AND 100

-- Выбрать из таблицы HumanResources.Employee колонки BusinessEntityId, JobTitle, BirthDate, Gender,
-- у которых год рождения (из BirthDate) 
-- равен 1980 или 1990. 
-- Для того, чтобы получить год из даты рождения, используйте функцию DATE_PART()
SELECT
   businessentityid,
   jobtitle,
   birthdate,
   gender
FROM
   humanresources.employee
WHERE
   DATE_PART('year',birthdate) IN ('1980','1990')


-- Выбрать из таблицы HumanResources.EmployeeDepartmentHistory
-- колонки BusinessEntityId, ShiftId, сгрупированные по BusinessEntityId, ShiftId

SELECT
  BusinessEntityId, 
  ShiftId
FROM
   humanresources.EmployeeDepartmentHistory
GROUP BY
	BusinessEntityId, ShiftId

-- Дополните предыдущий запрос, чтобы в выдаче остались только те группы, 
-- в которых количество записей больше или равно двум (используйте функцию COUNT())

SELECT
  BusinessEntityId, 
  ShiftId
FROM
   humanresources.EmployeeDepartmentHistory
GROUP BY
	BusinessEntityId, ShiftId
HAVING
	COUNT(*)>=2
