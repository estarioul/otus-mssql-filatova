/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/


select * from Application.People
where IsSalesperson=1 and PersonID not in (
select o.SalespersonPersonID from sales.Orders o
where o.OrderDate='2015-07-04');

with cte as(
		  select o.SalespersonPersonID as PersonId from sales.Orders o
		  where o.OrderDate='2015-07-04')
select p.* from Application.People p
left join cte c on p.PersonID=c.PersonId
where IsSalesperson=1 and c.PersonId is null

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select StockItemID, StockItemName, UnitPrice from Warehouse.StockItems
where UnitPrice in (select min (UnitPrice) from Warehouse.StockItems)

select StockItemID, StockItemName, UnitPrice from Warehouse.StockItems
where UnitPrice = (select min (UnitPrice) from Warehouse.StockItems);

with cte as(
	 select min (UnitPrice) as Price from Warehouse.StockItems)
select StockItemID, StockItemName, UnitPrice from Warehouse.StockItems, cte
where UnitPrice=Price

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select top 5 ct.CustomerID, c.CustomerName, TransactionAmount from Sales.CustomerTransactions ct
left join sales.Customers c on ct.CustomerID=c.CustomerID
order by TransactionAmount desc


select top 5 ct.CustomerID, c.CustomerName from Sales.CustomerTransactions ct
left join sales.Customers c on ct.CustomerID=c.CustomerID
where  TransactionAmount >= ANY (select top 5  TransactionAmount from Sales.CustomerTransactions
order by TransactionAmount desc)

select top 5 ct.CustomerID, c.CustomerName from Sales.CustomerTransactions ct
left join sales.Customers c on ct.CustomerID=c.CustomerID
where  TransactionAmount in (select top 5  TransactionAmount from Sales.CustomerTransactions
order by TransactionAmount desc);

with cte as
	 (select top 5  TransactionAmount as Amount from Sales.CustomerTransactions
				order by TransactionAmount desc
	 )
select ct.CustomerID, c.CustomerName from Sales.CustomerTransactions ct
left join sales.Customers c on ct.CustomerID=c.CustomerID
inner join cte on ct.TransactionAmount=cte.Amount




/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

 ;
 with cte as(
 select top 3 StockItemID from Warehouse.StockItems
 order by UnitPrice DESC 
 )
 select distinct ci.CityID, ci.CityName, p.FullName from sales.Invoices i
 inner join sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
 join cte c on il.StockItemID=c.StockItemID
 join sales.Customers cu on i.CustomerID=cu.CustomerID
 join Application.Cities ci on cu.DeliveryCityID=ci.CityID
 left join Application.People p on i.PackedByPersonID=p.PersonID
 order by ci.CityName

  select distinct ci.CityID, ci.CityName, p.FullName from sales.Invoices i
 inner join sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
 join sales.Customers cu on i.CustomerID=cu.CustomerID
 join Application.Cities ci on cu.DeliveryCityID=ci.CityID
 left join Application.People p on i.PackedByPersonID=p.PersonID
 where il.StockItemID in ( select top 3 StockItemID from Warehouse.StockItems
 order by UnitPrice DESC)
 order by ci.CityName


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
--Выводим инвойсы (доставки), где сумма продажи по инвойсу больше 27000,
--выводим id, дату и ФИО продажника, кто продал и суммы
-- выводим сравнение суммы продаж по invoices и по orders, где дата PickingCompletedWhen не пустая

;
with cte as 
(select il.InvoiceId,  SUM(Quantity*UnitPrice) as TotalSumm, i.orderid
	from Sales.InvoiceLines il
	join Sales.Invoices i on il.InvoiceID=i.InvoiceID
	group by il.InvoiceId, i.orderid
	having sum(Quantity*UnitPrice) > 27000
),
cte2
as (
	 SELECT SUM(ol.PickedQuantity*ol.UnitPrice) AS TotalSummForPickedItems, o.OrderID
		FROM Sales.OrderLines ol
		join Sales.Orders o on ol.OrderID=o.OrderID	
		join cte on cte.OrderID=o.OrderID --чтобы уменьшить количество записей берем те, что отобраны уже
		where o.PickingCompletedWhen IS NOT NULL	
		group by  o.OrderID
)	
SELECT 
	i.InvoiceID, 
	i.InvoiceDate,
	p.FullName  AS SalesPersonName,
	 TotalSumm,
	 cte2.TotalSummForPickedItems
FROM Sales.Invoices i
join  Application.People  p on i.SalespersonPersonID=p.PersonID
join cte on i.InvoiceID=cte.InvoiceID
join cte2 on i.OrderID=cte2.OrderID 
ORDER BY TotalSumm DESC
