-- создать таблицу testtable
CREATE TABLE holubtsova.testtable (
             id INT NOT NULL,
             name TEXT,
             issold BIT,
             invoicedate DATE,
             PRIMARY KEY(id)
)

-- скрипт, который вставляет значения в таблицу
INSERT INTO
            holubtsova.testtable
VALUES
           (1, 'Boat', B'1', '2021-11-08'),
           (2, 'Auto', B'0', '2021-11-09'),
           (3, 'Plane', NULL, '2021-12-09');

-- переименовать колонку Name на Vehicle
ALTER TABLE    holubtsova.testtable
RENAME COLUMN  name TO vehicle
-- SELECT *
-- FROM testtable

-- удалить данные в таблице одной командой
TRUNCATE holubtsova.testtable
-- SELECT *
-- FROM testtable

-- удалить саму таблицу
DROP TABLE holubtsova.testtable

-- проверка на существование таблицы
/*SELECT EXISTS (
   SELECT FROM pg_tables
   WHERE       schemaname = 'holubtsova'
   AND         tablename  = 'testtable'
   );*/