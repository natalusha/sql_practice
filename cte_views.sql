-- Создать представление Person.vPerson, которое базируется на таблицах Person.Person и Person.EmailAddress, и содержит следующие колонки:
-- - Title
-- - FirstName
-- - LastName
-- - EmailAddress
CREATE VIEW holubtsova.vPerson AS
SELECT
    p.title,
    p.firstname,
    p.lastname,
    em.emailaddress
FROM
    Person.Person p
    INNER JOIN Person.EmailAddress em ON p.businessentityid = em.businessentityid;

-- Напишите запрос, который вернет колонки:
-- - HumanResources.Employee.BusinessEntityId
-- - HumanResources.Employee.NationalIdNumber
-- - HumanResources.Employee.JobTitle
-- - Person.Person.FirstName
-- - Person.Person.LastName
-- - Person.PersonPhone.PhoneNumber
-- Основная таблица - HumanResources.Employee, Person.Person и Person.PersonPhone оформить как CTE
WITH person_data AS (
    SELECT
        p.businessentityid,
        p.firstname,
        p.lastname,
        ph.phonenumber
    FROM
        person.person p
        INNER JOIN Person.PersonPhone ph ON p.businessentityid = ph.businessentityid
)
SELECT
    e.businessentityid,
    e.nationalidnumber,
    e.jobtitle,
    person_data.firstname,
    person_data.lastname,
    person_data.phonenumber
FROM
    humanresources.employee e
    INNER JOIN person_data ON e.businessentityid = person_data.businessentityid