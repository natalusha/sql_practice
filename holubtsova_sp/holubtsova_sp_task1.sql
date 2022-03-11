-- Задание 1 (10 балов)
-- Задача: Зная электронную почту сотрудника нужно получить его и имя и фамилию, а также его возраст.
-- Условие:
-- Создать скрипт:  <your_lastname>_sp_task1.sql
-- Имя процедуры - <your_lastname>.<procedure_name>_task1
-- Используйте таблицы person.emailaddress, person.person, person.employee
-- Параметры:
-- <inp> – character varying(100).
-- Возврат функции:
-- <return> – varchar.
-- Пример вывода: “<firstname> <lastname> - <age>”
CREATE FUNCTION holubtsova.find_by_email_task1(email varchar(100)) RETURNS varchar AS $ $ DECLARE res varchar;

BEGIN
SELECT
    CONCAT (
        p.firstname,
        ' ',
        p.lastname,
        '-',
        date_part('year', AGE(CURRENT_DATE, emp.birthdate)),
        ' y.o.'
    ) :: varchar INTO res
FROM
    person.person p
    INNER JOIN person.emailaddress e ON p.businessentityid = e.businessentityid
    INNER JOIN humanresources.employee emp ON emp.businessentityid = p.businessentityid
WHERE
    e.emailaddress = email;

RETURN res;

END;

$ $ LANGUAGE plpgsql;

--test script
SELECT
    find_by_email_task1('gail0@adventure-works.com');