-- Пример: Покупатель связался с менеджером чтобы оформить заказ.
-- Задача: Создать функцию триггера и триггер для оформления заказа и добавления его в таблицы
-- <your_lastname>.salesorderheader и <your_lastname>.salesorderdetail (триггер для этой таблицы с действиями(update,delete,insert)).
-- Менеджер добавляет товар в таблицу <your_lastname>.salesorderdetail 
-- после добавления каждого нового товара или удалении из таблицы из этой таблицы,
-- общая информация должна вставляться, удаляться или обновляться 
-- (обновляется только столбец totaldue = sum(totaline from <your_lastname>.salesorderdetail))
-- в таблице <your_lastname>.salesorderheader.
-- Если значение столбца totaline изменилось или строка была удалена нужно  добавить или отнять это значение в totaldue. 
-- При удаления всех данных для одного заказа <your_lastname>.salesorderdetail. 
-- нужно удалить все данные в таблице <your_lastname>.salesorderheader для этого заказа.
CREATE
OR REPLACE FUNCTION holubtsova.upd_totaldue() RETURNS TRIGGER AS $ upd_totaldue $ DECLARE res numeric;

cust_id integer;

BEGIN
SELECT
    customerid INTO cust_id
FROM
    holubtsova.salesorderheader
WHERE
    salesorderid = NEW.salesorderid;

SELECT
    totaldue INTO res
FROM
    holubtsova.salesorderheader
WHERE
    salesorderid = NEW.salesorderid;

IF (TG_OP = 'DELETE') THEN
UPDATE
    holubtsova.salesorderheader
SET
    totaldue = totaldue - OLD.linetotal
WHERE
    salesorderheader.salesorderid = OLD.salesorderid;

ELSIF (TG_OP = 'UPDATE') THEN
UPDATE
    holubtsova.salesorderheader
SET
    totaldue =(totaldue - OLD.linetotal) + NEW.linetotal
WHERE
    salesorderheader.salesorderid = NEW.salesorderid;

ELSIF (TG_OP = 'INSERT') THEN IF (
    NEW.customerid != cust_id
    OR NEW.customerid IS NULL
) THEN RAISE EXCEPTION 'Customer ids are not matched!' USING ERRCODE = '22023',
-- 22023 = "invalid_parameter_value'
DETAIL = 'Please check input.',
HINT = 'Your input should be  ' || cust_id || ' .';

ELSE IF (res IS NULL) THEN
UPDATE
    holubtsova.salesorderheader
SET
    totaldue = 0.0 + NEW.linetotal
WHERE
    salesorderheader.salesorderid = NEW.salesorderid;

ELSE
UPDATE
    holubtsova.salesorderheader
SET
    totaldue = totaldue + NEW.linetotal
WHERE
    salesorderheader.salesorderid = NEW.salesorderid;

END IF;

END IF;

END IF;

RETURN NULL;

END;

$ upd_totaldue $ LANGUAGE plpgsql;

CREATE TRIGGER upd_totaldue
AFTER
INSERT
    OR
UPDATE
    OR DELETE ON holubtsova.salesorderdetail FOR EACH ROW EXECUTE FUNCTION upd_totaldue();

-- test script
INSERT INTO
    holubtsova.salesorderheader
VALUES
    (
        75124,
        '2014-06-30 00:00:00',
        5,
        TRUE,
        18759,
        NULL,
        10084,
        0.0
    );

SELECT
    *
FROM
    holubtsova.salesorderheader
WHERE
    salesorderid = 75124;

-- error, because customer_id not equal to the one in the orderheader
INSERT INTO
    holubtsova.salesorderdetail(
        salesorderid,
        salesorderdetailid,
        carriertrackingnumber,
        orderqty,
        productid,
        specialofferid,
        unitprice,
        unitpricediscount,
        LINETOTAL,
        modifieddate,
        customerid
    )
VALUES
    (
        75124,
        121318,
        NULL,
        1,
        712,
        1,
        10.0,
        0,
        10.0,
        '2014-06-30 00:00:00',
        18756
    );

-- error, because customer_id is null
INSERT INTO
    holubtsova.salesorderdetail(
        salesorderid,
        salesorderdetailid,
        carriertrackingnumber,
        orderqty,
        productid,
        specialofferid,
        unitprice,
        unitpricediscount,
        LINETOTAL,
        modifieddate
    )
VALUES
    (
        75124,
        121318,
        NULL,
        1,
        712,
        1,
        10.0,
        0,
        10.0,
        '2014-06-30 00:00:00'
    );

-- this will work fine
INSERT INTO
    holubtsova.salesorderdetail(
        salesorderid,
        salesorderdetailid,
        carriertrackingnumber,
        orderqty,
        productid,
        specialofferid,
        unitprice,
        unitpricediscount,
        LINETOTAL,
        modifieddate,
        customerid
    )
VALUES
    (
        75124,
        121318,
        NULL,
        1,
        712,
        1,
        10.0,
        0,
        10.0,
        '2014-06-30 00:00:00',
        18759
    );

INSERT INTO
    holubtsova.salesorderdetail(
        salesorderid,
        salesorderdetailid,
        carriertrackingnumber,
        orderqty,
        productid,
        specialofferid,
        unitprice,
        unitpricediscount,
        linetotal,
        modifieddate,
        customerid
    )
VALUES
    (
        75124,
        121319,
        NULL,
        1,
        712,
        1,
        10.0,
        0,
        10.0,
        '2014-06-30 00:00:00',
        18759
    );

INSERT INTO
    holubtsova.salesorderdetail(
        salesorderid,
        salesorderdetailid,
        carriertrackingnumber,
        orderqty,
        productid,
        specialofferid,
        unitprice,
        unitpricediscount,
        linetotal,
        modifieddate,
        customerid
    )
VALUES
    (
        75124,
        121320,
        NULL,
        1,
        712,
        2,
        15.0,
        0,
        30.0,
        '2014-06-30 00:00:00',
        18759
    );

-- check whether totaldue is changed
SELECT
    *
FROM
    holubtsova.salesorderheader
WHERE
    salesorderid = 75124