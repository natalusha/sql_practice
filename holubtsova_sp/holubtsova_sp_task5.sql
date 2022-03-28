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
CREATE OR REPLACE FUNCTION holubtsova.upd_totaldue() RETURNS TRIGGER AS $upd_totaldue$
DECLARE
orderheader_id integer;
del_due numeric;
BEGIN
        IF (TG_OP = 'DELETE') THEN

            UPDATE holubtsova.salesorderheader SET totaldue=totaldue-OLD.linetotal
			WHERE salesorderheader.salesorderid=OLD.salesorderid;
			SELECT totaldue  INTO del_due FROM holubtsova.salesorderheader
         	WHERE salesorderid = OLD.salesorderid;
			IF (del_due=0.0) THEN
			DELETE FROM holubtsova.salesorderheader WHERE salesorderheader.salesorderid=OLD.salesorderid;
			END IF;
        ELSIF (TG_OP = 'UPDATE') THEN
             UPDATE holubtsova.salesorderheader SET totaldue=(totaldue-OLD.linetotal)+NEW.linetotal
			WHERE salesorderheader.salesorderid=NEW.salesorderid;
   ELSIF (TG_OP = 'INSERT') THEN 
SELECT
 salesorderid  INTO orderheader_id
FROM
    holubtsova.salesorderheader
WHERE
    salesorderid = NEW.salesorderid;
IF NOT FOUND THEN
INSERT INTO holubtsova.salesorderheader(salesorderid, orderdate, customerid, salespersonid, creditcardid, totaldue)
        VALUES (NEW.salesorderid, NEW.modifieddate, NEW.customerid, NEW.salespersonid, NEW.creditcardid, NEW.linetotal);
ELSE
UPDATE
    holubtsova.salesorderheader
SET
    totaldue = totaldue + NEW.linetotal
WHERE
    salesorderheader.salesorderid = NEW.salesorderid;
        END IF;
		END IF;
        RETURN NULL; 
    END;
$upd_totaldue$ LANGUAGE plpgsql;

CREATE TRIGGER upd_totaldue
AFTER
INSERT
    OR
UPDATE
    OR DELETE ON holubtsova.salesorderdetail FOR EACH ROW EXECUTE FUNCTION upd_totaldue();