-- Задание 3 (20 балов)
-- Пример: Нужно получить ежедневные, месячные и годовые отчеты о сумме продаж, 
-- средней сумме продаж, количестве заказов, как был оформлен заказ(онлайн или офлайн)
-- например, за последние 10 лет.
-- Задача: Создать хранимую процедуру для получения отчетов, которые записываются в таблицы.
-- ежедневные -  <your_lastname>.sales_report_total_daily 
-- месячные -  <your_lastname>.sales_report_total_monthly 
-- годовые -  <your_lastname>.sales_report_total_yearly
-- Условие:
-- Создать скрипт:  <your_lastname>_sp_task3.sql
-- Имя процедуры - <your_lastname>.<procedure_name>_task3
-- Используйте таблицу sales.salesorderheader
-- Параметры:
-- <inp> – int.
CREATE
OR REPLACE PROCEDURE holubtsova.reports_task3(years int) AS $ $ DECLARE str_year INTERVAL := years || ' year';

max_year timestamp;

daily_report record;

BEGIN TRUNCATE TABLE holubtsova.sales_report_total_daily;

TRUNCATE TABLE holubtsova.sales_report_total_monthly;

TRUNCATE TABLE holubtsova.sales_report_total_yearly;

SELECT
    date_trunc('year',(MIN(orderdate) + str_year)) INTO max_year
FROM
    sales.salesorderheader;

INSERT INTO
    holubtsova.sales_report_total_daily(
        date_report,
        onlineorderflag,
        sum_total,
        avg_total,
        qty_orders
    )
SELECT
    date_trunc('day', orderdate) day_year,
    onlineorderflag,
    SUM(subtotal),
    AVG(subtotal),
    COUNT(onlineorderflag)
FROM
    sales.salesorderheader
GROUP BY
    day_year,
    onlineorderflag
HAVING
    date_trunc('day', orderdate) < max_year
ORDER BY
    day_year;

INSERT INTO
    holubtsova.sales_report_total_monthly(
        date_report,
        onlineorderflag,
        sum_total,
        avg_total,
        qty_orders
    )
SELECT
    date_trunc('month', orderdate) month_period,
    onlineorderflag,
    SUM(subtotal),
    AVG(subtotal),
    COUNT(onlineorderflag)
FROM
    sales.salesorderheader
GROUP BY
    month_period,
    onlineorderflag
HAVING
    date_trunc('month', orderdate) < max_year
ORDER BY
    month_period;

INSERT INTO
    holubtsova.sales_report_total_yearly(
        date_report,
        onlineorderflag,
        sum_total,
        avg_total,
        qty_orders
    )
SELECT
    date_trunc('year', orderdate) year_period,
    onlineorderflag,
    SUM(subtotal),
    AVG(subtotal),
    COUNT(onlineorderflag)
FROM
    sales.salesorderheader
GROUP BY
    year_period,
    onlineorderflag
HAVING
    date_trunc('year', orderdate) < max_year
ORDER BY
    year_period;

END;

$ $ language plpgsql DROP PROCEDURE holubtsova.reports_task3 call holubtsova.reports_task3(2);

SELECT
    *
FROM
    holubtsova.sales_report_total_monthly
SELECT
    *
FROM
    holubtsova.sales_report_total_daily
SELECT
    *
FROM
    holubtsova.sales_report_total_yearly