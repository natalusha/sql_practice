-- Выбрать названия и количество групп из таблицы HumanResources.Department
SELECT
    d.groupname,
    count(d.groupname)
FROM
    humanresources.department d
GROUP BY
    d.groupname 


-- Найти максимальную ставку для каждого сотрудника из таблиц HumanResources.EmployeePayHistory, 
-- HumanResources.Employee
SELECT
    emp.businessentityid,
    emp.jobtitle,
    MAX(emp_h.rate) AS max_rate
FROM
    humanresources.employee emp
    INNER JOIN HumanResources.EmployeePayHistory emp_h ON emp.businessentityid = emp_h.businessentityid
GROUP BY
    emp.businessentityid,
    emp.jobtitle
ORDER BY
    max_rate DESC 
    
    
-- Выбрать минимальную цену единицы товара по подкатегориям (названия из таблицы PRODUCTION.PRODUCTSUBCATEGORY, 
--минимальная цена из таблицы SALES.SALESORDERDETAIL) используя таблицы
-- Sales.SalesOrderDetail, 
-- Production.Product, 
-- Production.ProductSubcategory
    WITH psub_name AS(
        SELECT
            pr.productid,
            ps.name
        FROM
            production.productsubcategory ps
            INNER JOIN production.product pr ON pr.productsubcategoryid = ps.productsubcategoryid
    )
SELECT
    psub_name.name,
    MIN(sd.unitprice) :: numeric(6, 2) AS min_price
FROM
    sales.salesorderdetail sd
    INNER JOIN psub_name ON psub_name.productid = sd.productid
GROUP BY
    psub_name.name
ORDER BY
    min_price 
    
    
-- Вычислить название и количество подкатегорий товара в каждой категории, используя таблицы 
-- Production.ProductCategory, 
-- Production.ProductSubcategory
SELECT
    pc.name,
    COUNT(ps.productsubcategoryid)
FROM
    production.productcategory pc
    INNER JOIN production.productsubcategory ps ON pc.productcategoryid = ps.productcategoryid
GROUP BY
    pc.name 
-- Для вывода только уникальных названий и кол-ва подкатегорий 
SELECT
    pc.name,
    COUNT(DISTINCT ps.productsubcategoryid)
FROM
    production.productcategory pc
    INNER JOIN production.productsubcategory ps ON pc.productcategoryid = ps.productcategoryid
GROUP BY
    pc.name 
    
    
-- Вывести среднюю сумму заказа по подкатегориям товаров, используя таблицы  
-- Sales.SalesOrderDetail, 
-- Production.Product, 
-- Production.ProductSubcategory
    WITH psub_name AS(
        SELECT
            pr.productid,
            ps.name
        FROM
            production.productsubcategory ps
            INNER JOIN production.product pr ON pr.productsubcategoryid = ps.productsubcategoryid
    )
SELECT
    psub_name.name,
    AVG(sd.linetotal) :: numeric(6, 2) AS avg_price
FROM
    sales.salesorderdetail sd
    INNER JOIN psub_name ON psub_name.productid = sd.productid
GROUP BY
    psub_name.name
ORDER BY
    avg_price 
    
    
-- Найти ID сотрудника с максимальным рейтом и дату назначения рейта, 
-- используя таблицы HumanResources.EmployeePayHistory
SELECT
    businessentityid,
    ratechangedate
FROM
    humanresources.employeepayhistory
WHERE
    rate =(
        SELECT
            MAX(rate)
        FROM
            humanresources.employeepayhistory
    )