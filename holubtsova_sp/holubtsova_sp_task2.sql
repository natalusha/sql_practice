-- Задание 2 (20 балов)
-- Пример: Есть торговая точка которая сотрудничает с поставщиками и имеет собственные цеха.
-- В некоторых случаях руководство может как отказаться от собственного производства и заказывать 
-- у поставщиков так и начать свое производство -  отказаться от поставщиков.
-- Задача: Создать хранимую процедуру для обновления столбца make_flag в таблице <your_lastname>.product,
-- по столбцу name. Замечание: Если для заданного продукта значение флага совпадает вывести на экран  
-- замечание “<YOUR_COMMENT_1>” и если такого продукта нет в таблице вывести “<YOUR_COMMENT_2>”.
-- Условие:
-- Создать скрипт:  <your_lastname>_sp_task2.sql
-- Имя процедуры - <your_lastname>.<procedure_name>_task2
-- Параметры:
-- <inp_1> - character varying;
-- <inp_2> - boolean (true or false).
CREATE
OR REPLACE PROCEDURE holubtsova.change_flag_task2(pr_name varchar, make_flag boolean) AS $ $ DECLARE prod varchar;

flag boolean;

cnt_prod int;

BEGIN
SELECT
    INTO prod,
    flag,
    cnt_prod p.name,
    p.makeflag,
    COUNT(p.name) over()
FROM
    holubtsova.product p
WHERE
    p.name = pr_name;

IF prod = pr_name
AND flag = make_flag THEN raise notice 'ITEM EXITS, FLAG IS ALREADY IN THIS POSITION';

ELSEIF NOT FOUND THEN raise notice 'ITEM NOT FOUND';

ELSEIF prod = pr_name
AND flag != make_flag THEN
UPDATE
    holubtsova.product
SET
    makeflag = make_flag
WHERE
    name = pr_name;

END IF;

END;

$ $ language plpgsql call holubtsova.change_flag_task2('Bearing Ball', false);

SELECT
    *
FROM
    holubtsova.product p
WHERE
    p.name = 'Bearing Ball';