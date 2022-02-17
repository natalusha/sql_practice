-- Выберите имя и фамилию, должность (Job Title), дату рождения, 
-- используя таблицы [Person].[Person] и [HumanResources].[Employee]. 
-- Записи должны иметь соответствие в правой и левой таблице
SELECT
    p.firstname,
    p.lastname,
    e.jobtitle,
    e.birthdate
FROM
    Person.PERSON p
    INNER JOIN HumanResources.Employee e ON p.businessentityid = e.businessentityid 

-- Выберите имя и фамилию, используя таблицы [Person].[Person],
-- и должность (Job Title) подзапросом, используя таблицу [HumanResources].[Employee]. 
SELECT
    p.firstname,
    p.lastname,
    (
        SELECT
            e.jobtitle
        FROM
            HumanResources.Employee e
        WHERE
            p.businessentityid = e.businessentityid
    ) AS job
FROM
    Person.Person p 

-- Используя запрос из пункта 1.2 удалите из выборки все записи, 
-- для которых JobTitle является NULL (используя вложенные подзапросы)
SELECT
    p.firstname,
    p.lastname,
    (
        SELECT
            e.jobtitle
        FROM
            HumanResources.Employee e
        WHERE
            p.businessentityid = e.businessentityid
    ) AS job
FROM
    Person.Person p
    RIGHT JOIN (
        SELECT
            e.jobtitle,
            e.businessentityid
        FROM
            HumanResources.Employee e
            RIGHT JOIN Person.Person p ON p.businessentityid = e.businessentityid
        WHERE
            e.businessentityid IS NOT NULL
    ) AS job ON p.businessentityid = job.businessentityid 
    
-- Еще один вариант задания 1.3, но без джоинов 
    WITH emp_info AS (
        SELECT
            p.firstname,
            p.lastname,
            (
                SELECT
                    e.jobtitle
                FROM
                    HumanResources.Employee e
                WHERE
                    p.businessentityid = e.businessentityid
            ) AS job
        FROM
            Person.Person p
    )
SELECT
    *
FROM
    emp_info
WHERE
    job IS NOT NULL 

-- Напишите запрос, который вернет все возможные сочетания имени, фамилии из таблицы [Person].[Person]
-- с должностями из таблицы [HumanResources].[Employee]
SELECT
    p.firstname,
    p.lastname,
    e.jobtitle
FROM
    Person.PERSON p
    CROSS JOIN HumanResources.Employee e 

-- Используя функцию COUNT() напишите запрос, который выведет количество записей из запроса 1.4
SELECT
    COUNT(*)
FROM
    (
        SELECT
            p.firstname,
            p.lastname,
            e.jobtitle
        FROM
            Person.PERSON p
            CROSS JOIN HumanResources.Employee e
    ) AS total_pips
    
 -- Если нужно посчитать уникальные записи
SELECT
    COUNT(*)
FROM
    (
        SELECT
            DISTINCT p.firstname,
            p.lastname,
            e.jobtitle
        FROM
            Person.PERSON p
            CROSS JOIN HumanResources.Employee e
    ) AS total_pips