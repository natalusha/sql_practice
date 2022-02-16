-- В скрипте необходимо прописать команду, 
-- которая добавит значения ниже в нашу таблицу TestTable
INSERT INTO
    holubtsova.testtable
VALUES
    (1, 'Boat', B '1', '2021-11-08'),
    (2, 'Auto', B '0', '2021-11-09'),
    (3, 'Plane', NULL, '2021-12-09'),
    (4, 'Bicycle', B '0', '2020-08-23'),
    (5, 'Rocket', B '1', '2020-01-01'),
    (6, 'Motorcycle', NULL, '2020-08-26'),
    (7, 'Submarine', B '0', '1999-05-16') 

    -- Дополнить скрипт, добавив команды,
    -- которая вставят значения ниже
INSERT INTO
    holubtsova.testtable(id, invoicedate)
VALUES
    (8, '2020-08-25');
INSERT INTO
    holubtsova.testtable(id, name)
VALUES
    (9, 'Scooter') 

    -- Дополнить скрипт, написав команду,
    -- которая в колонке IsSold поменяет все NULL на 0.Д
UPDATE
    holubtsova.testtable
SET
    IsSold = B '0'
WHERE
    IsSold IS NULL 

    -- Дополнить скрипт, написав команду, которая удалит все строки, 
    -- в которых значение колонки Name или InvoiceDate - NULL
DELETE FROM
    holubtsova.testtable
WHERE
    name IS NULL
    OR invoicedate IS NULL 

    -- Используя INSERT, выполнить UPSERT, что означает UPDATE или INSERT.
    -- Это позволит вставить строку если ее нет, или обновить существующую. 
    -- Необходимо этим способом заменить Name Bicycle на Train. 
    -- Добавить результат в скрипт.
INSERT INTO
    holubtsova.testtable (id, name)
VALUES
(4, 'Train') ON CONFLICT (id)
DO
UPDATE
SET
    name = EXCLUDED.name