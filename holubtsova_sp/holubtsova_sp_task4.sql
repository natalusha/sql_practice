-- Пример: В конце отчетного года руководство решило наградить трех лучших сотрудников.
-- Задача: Создать пользовательскую функцию для определения лучших сотрудников продавшего товаров на большую сумму за отчетный период.
-- Учитываются только оффлайн заказы.
-- Условие:
-- Создать скрипт:  <your_lastname>_sp_task4.sql
-- Имя процедуры - <your_lastname>.<procedure_name>_task4
-- Используйте таблицы sales.salesorderheader, person.person
-- Параметры:
-- <inp_1> – date;
-- <inp_2> – date;
-- Возврат функции:
-- employeeid(salespesonid, businessentityid) – int;
-- firstname – nvarchar(50);
-- lastname – nvarchar(50);
-- rank – int.
CREATE FUNCTION holubtsova.top_three_task4(start_date date, end_date date) RETURNS TABLE (
    employeeid int,
    firstname varchar(50),
    lastname varchar(50),
    rank int
) AS $ $ BEGIN --start
IF end_date < start_date THEN RAISE EXCEPTION 'End date should be bigger, then start date' USING ERRCODE = '22023',
DETAIL = 'Please check input.';

ELSE RETURN QUERY WITH t AS (
    SELECT
        p.businessentityid,
        p.firstname,
        p.lastname,
        SUM(soh.subtotal) sales,
        soh.orderdate
    FROM
        person.person p
        INNER JOIN sales.salesorderheader soh ON p.businessentityid = soh.salespersonid
    GROUP BY
        p.businessentityid,
        p.firstname,
        p.lastname,
        soh.onlineorderflag,
        soh.orderdate
    HAVING
        soh.onlineorderflag = 'false'
        AND soh.orderdate BETWEEN start_date
        AND end_date
)
SELECT
    t.businessentityid,
    t.firstname :: varchar(50),
    t.lastname :: varchar(50),
    RANK() OVER (
        ORDER BY
            SUM(sales) DESC
    ) :: int rate
FROM
    t
GROUP BY
    t.businessentityid,
    t.firstname,
    t.lastname
LIMIT
    3;

END IF;

END;

$ $ LANGUAGE plpgsql;

--test script
-- error
SELECT
    *
FROM
    top_three_task4('2012-06-10', '2012-05-31');

--right one
SELECT
    *
FROM
    top_three_task4('2011-05-31', '2012-05-31');