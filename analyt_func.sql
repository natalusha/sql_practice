-- Найти сумму продаж за месяц по каждому продукту, проданному в январе-2013 года.
-- Вывести итоговый список продуктов без первых и последних 10% списка, используя следующие таблицы:
-- 	Sales.SalesOrderHeader
-- 	Sales.SalesOrderDetail
-- 	Production.Product
WITH prod_jan AS (
    SELECT
        oh.salesorderid,
        od.salesorderdetailid,
        od.linetotal,
        od.productid,
        oh.orderdate
    FROM
        sales.salesorderheader oh
        INNER JOIN sales.salesorderdetail od 
        ON od.salesorderid = oh.salesorderid
    WHERE
        oh.orderdate BETWEEN '2013-01-01' AND '2013-01-31'
),
t AS (
    SELECT
        DISTINCT p.productid dp,
        p.name,
        SUM(prod_jan.linetotal) OVER (PARTITION BY prod_jan.productid) AS total_prod_sum
    FROM
        Production.Product p
        INNER JOIN prod_jan ON p.productid = prod_jan.productid
),
Percentile AS (
    SELECT
        t.name,
        t.total_prod_sum,
        1E0 * ROW_NUMBER() OVER ( ORDER BY t.total_prod_sum) / COUNT(*) OVER() AS p
    FROM
        t
)
SELECT
    name,
    total_prod_sum
FROM
    Percentile
WHERE
    p >= 0.11
    AND p < 0.9 

--Найти самые дешевые продукты в каждой субкатегории продуктов.
-- Использовать таблицу Production.Product.
SELECT
    name,
    MIN(listprice) OVER (PARTITION BY productsubcategoryid) min_subcat_price
FROM
    Production.Product 

-- Найти вторую по величине 
-- цену для горных велосипедов, используя таблицу Production.Product
WITH rank_price AS(
        SELECT
            productid,
            listprice,
            productsubcategoryid,
            DENSE_RANK () OVER (PARTITION BY productsubcategoryid ORDER BY listprice DESC) rp
        FROM
            Production.Product
    )
SELECT
    DISTINCT listprice
FROM
    rank_price
WHERE
    rp = 2
    AND productsubcategoryid = 1 
    
    
-- Посчитать продажи за 2013 год в разрезе категорий(“YoY метрика”):  
--   (продажи - продажи за прошлый год/продажи
-- используя таблицы:
-- 	Sales.SalesOrderHeader
-- 	Sales.SalesOrderDetail
-- 	Production.Product
-- 	Production.ProductSubcategory
-- 	Production.ProductCategory
WITH prod_2013 AS (
        SELECT
            od.productid,
            oh.orderdate,
            p.name,
            pc.name AS catname,
            SUM(od.linetotal) OVER (PARTITION BY od.productid) AS total_sum_2013
        FROM
            sales.salesorderheader oh
            INNER JOIN sales.salesorderdetail od ON oh.salesorderid = od.salesorderid
            INNER JOIN Production.Product p ON od.productid = p.productid
            INNER JOIN production.productsubcategory ps ON p.productsubcategoryid = ps.productsubcategoryid
            INNER JOIN production.productcategory pc ON ps.productcategoryid = pc.productcategoryid
        WHERE
            oh.orderdate >= '2013-01-01'
            AND oh.orderdate < '2014-01-01'
        ORDER BY
            od.salesorderdetailid
    ),
    dist2013 AS (
        SELECT
            DISTINCT productid,
            catname,
            total_sum_2013
        FROM
            prod_2013
        ORDER BY
            2
    ),
    total2013 AS (
        SELECT
            catname,
            SUM(total_sum_2013) OVER (PARTITION BY catname) AS cat_sum
        FROM
            dist2013
    ),
    prod_2012 AS (
        SELECT
            od.productid,
            oh.orderdate,
            p.name,
            pc.name AS catname,
            SUM(od.linetotal) OVER (PARTITION BY od.productid) AS total_sum_2012
        FROM
            sales.salesorderheader oh
            INNER JOIN sales.salesorderdetail od ON oh.salesorderid = od.salesorderid
            INNER JOIN Production.Product p ON od.productid = p.productid
            INNER JOIN production.productsubcategory ps ON p.productsubcategoryid = ps.productsubcategoryid
            INNER JOIN production.productcategory pc ON ps.productcategoryid = pc.productcategoryid
        WHERE
            oh.orderdate >= '2012-01-01'
            AND oh.orderdate < '2013-01-01'
        ORDER BY
            od.salesorderdetailid
    ),
    dist2012 AS (
        SELECT
            DISTINCT productid,
            catname,
            total_sum_2012
        FROM
            prod_2012
        ORDER BY 2
    ),
    total2012 AS(
        SELECT
            catname,
            SUM(total_sum_2012) OVER (PARTITION BY catname) AS cat_sum
        FROM
            dist2012
    ),
    result AS (
        SELECT
            total2013.catname,
            total2013.cat_sum,
            (
                (total2013.cat_sum - total2012.cat_sum) / total2013.cat_sum
            ) AS YoY
        FROM
            total2013
            INNER JOIN total2012 ON total2013.catname = total2012.catname
    )
SELECT
    DISTINCT *
FROM
    result
ORDER BY 1


-- Найти  максимальную сумму заказа за каждый день января 2013, используя таблицы:
-- 	Sales.SalesOrderHeader
-- 	Sales.SalesOrderDetail
WITH date_sum AS (
        SELECT
            oh.salesorderid,
            oh.orderdate,
            MAX(od.linetotal) OVER (PARTITION BY oh.orderdate) AS maxorder
        FROM
            Sales.SalesOrderHeader oh
            INNER JOIN sales.salesorderdetail od 
	        ON od.salesorderid = oh.salesorderid
        WHERE
            oh.orderdate BETWEEN '2013-01-01' AND '2013-01-31'
    )
SELECT
    DISTINCT date_sum.orderdate,
    date_sum.maxorder
FROM
    date_sum
ORDER BY
    orderdate 
    
-- 	Найти товар, который чаще всего продавался в каждой из субкатегорий в январе 2013, используя таблицы:
-- Sales.SalesOrderHeader
-- 	Sales.SalesOrderDetail
-- 	Production.Product
-- 	Production.ProductSubcategory
WITH count_prod AS (
        SELECT
            oh.salesorderid,
            oh.orderdate,
            od.productid,
            pr.name prod_name,
            COUNT(pr.productid) OVER (PARTITION BY od.productid) cnt_sales,
            ps.name sub_name
        FROM
            Sales.SalesOrderHeader oh
            INNER JOIN sales.salesorderdetail od ON oh.salesorderid = od.salesorderid
            INNER JOIN production.product pr ON od.productid = pr.productid
            INNER JOIN production.productsubcategory ps ON pr.productsubcategoryid = ps.productsubcategoryid
        WHERE
            oh.orderdate BETWEEN '2013-01-01' AND '2013-01-31'
    ),
    max_count_prod AS (
        SELECT
            sub_name,
            prod_name,
            cnt_sales,
            MAX(cnt_sales) OVER (PARTITION BY sub_name) maxcount
        FROM
            count_prod
        ORDER BY
            maxcount DESC
    )
SELECT
    DISTINCT sub_name,
    prod_name mostfreq
FROM
    max_count_prod
WHERE
    cnt_sales = maxcount