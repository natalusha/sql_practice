--  Создайте таблицу Customer со следующими колонками:
-- CustomerID int,
-- FirstName varchar(50),
-- LastName varchar(50),
-- Email varchar(100),
-- ModifiedDate date,
-- Age int,
-- active boolean
-- На колонке CustomerID создайте ограничение первичного ключа и индекс типа B-tree
-- Заполните ее тестовыми данными, например:
-- INSERT INTO holubtsova.customer
-- SELECT
-- businessentityid AS customerid,
-- concat('firstname', businessentityid) AS firstname,
-- concat('lastname', businessentityid) AS lastname,
-- concat('firstname', businessentityid, 'lastname', businessentityid, '@email.com') AS email,
-- modifieddate,
-- DATE_PART('year', now()::date) - DATE_PART('year', birthdate::date) AS age,
-- CASE WHEN businessentityid % 7 = 0 THEN False ELSE True END AS active
-- FROM humanresources.employee
CREATE TABLE holubtsova.customer (
    CustomerID integer CONSTRAINT pk_customer PRIMARY KEY,
    FirstName varchar(50),
    LastName varchar(50),
    Email varchar(100),
    ModifiedDate date,
    Age integer,
    active boolean
);

CREATE UNIQUE INDEX pk_ind ON holubtsova.customer(CustomerID);

-- Удостоверьтесь, что ваш индекс появился в системном каталоге pg_indexes
SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'holubtsova'
    AND indexname = 'pk_ind';

-- **Для индекса, который создался констрейнтом
SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'holubtsova'
    AND indexname = 'customer_pkey';

-- Создайте составной индекс типа B-tree на таблице Customer на колонках FirstName и LastName
CREATE INDEX customer_frst_lst_nm_idx ON holubtsova.customer USING btree(FirstName, LastName);

EXPLAIN (ANALYZE)
SELECT
    *
FROM
    holubtsova.customer
WHERE
    FIRSTNAME = 'firstname20';

-- Создайте такой индекс на таблице Customer, чтобы результат выполнения запроса
-- explain (analyze)
-- select *
-- from student.customer
-- where age between 30 and 60
-- был:
-- "Index Scan using ix_customer_age on customer (...)"
-- " Index Cond: ((age >= 30) AND (age >= 60))"
CREATE INDEX ix_customer_age ON holubtsova.customer (age);

-- индекс с возрастом не работает из-за плохой селективности, так как на 290 записей уникального возраста - 38
EXPLAIN (ANALYZE)
SELECT
    *
FROM
    holubtsova.customer
WHERE
    age BETWEEN 30
    AND 60;

-- Создайте покрывающий индекс IX_Customer_ModifiedDate для быстрого выполнения запроса
-- и проверьте, что он используется в плане запроса:
-- SELECT
-- FirstName,
-- LastName
-- FROM Customer
-- WHERE ModifiedDate = '2020-10-20'
CREATE INDEX IX_Customer_ModifiedDate ON holubtsova.customer (ModifiedDate) INCLUDE (FirstName, LastName);

EXPLAIN (ANALYZE)
SELECT
    FirstName,
    LastName
FROM
    Customer
WHERE
    ModifiedDate = '2020-10-20';

-- Удалите индекс PK_CustomerID из таблицы Customer
DROP INDEX pk_ind;

-- **Удаление индекса, созданного при создании констрейнта ПК pk_customer
ALTER TABLE
    holubtsova.customer DROP CONSTRAINT customer_pkey;

-- **Добавить его обратно
-- ALTER TABLE holubtsova.customer ADD PRIMARY KEY (CustomerID);
-- Создайте индекс типа Hash с названием PK_Modified_Date в таблице Customer на колонке
-- ModifiedDate
CREATE INDEX PK_Modified_Date ON holubtsova.customer USING HASH(ModifiedDate);

-- Переименуйте индекс PK_ Modified_Date на PK_ ModifiedDate
ALTER INDEX PK_Modified_Date RENAME TO PK_ModifiedDate;

--Создайте частичный индекс на колонке email только для тех записей, у которых active = true. И
-- напишите запрос к таблице, в котором этот индекс будет использоваться.
CREATE INDEX IX_Customer_email ON holubtsova.customer (email)
WHERE
    active = 'true';

EXPLAIN (ANALYZE)
SELECT
    email
FROM
    Customer
WHERE
    email LIKE 'firstname1lastname1@email.com'
    AND active = 'true';

-- 10. Создайте функциональный индекс в таблице Customer для быстрого поиска записей по такому
-- правилу: если firstname = 'firstname1' и lastname = 'lastname1', то мы ищем 'f, lastname1'.
-- Проверьте план запроса, что этот индекс используется.
CREATE INDEX ix_customer_names ON holubtsova.customer((substring(firstname, 1, 1) || ', ' || lastname));

EXPLAIN (ANALYZE)
SELECT
    firstname,
    lastname
FROM
    holubtsova.customer
WHERE
    ((substring(firstname, 1, 1) || ', ' || lastname)) = 'f,lastname1';