/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

set statistics time, io on

select i.InvoiceID, c.CustomerName, i.InvoiceDate, sum(il.Quantity*il.UnitPrice) as Sum_Sales, 
(
	  select	 sum(il.Quantity * il.UnitPrice) as Sum_Cumulative						
	from sales.Invoices as ii
	inner join sales.InvoiceLines as il on ii.InvoiceID = il.InvoiceID
	 where  ii.InvoiceDate>='2015-01-01' and month(ii.InvoiceDate)<=month(i.InvoiceDate) and year(ii.InvoiceDate)<=year(i.InvoiceDate)
)
from sales.Invoices i 
inner join sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
inner join sales.Customers c on i.CustomerID=c.CustomerID
where i.InvoiceDate>='2015-01-01'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate
order by i.InvoiceDate, Sum_Sales


set statistics time, io off

-- SQL Server Execution Times:
   --CPU time = 37625 ms,  elapsed time = 38377 ms.


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

set statistics time, io on;

with cte as (
select i.InvoiceID, sum(il.Quantity*il.UnitPrice) as Sum_Sales
from sales.Invoices i 
inner join sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
where i.InvoiceDate>='2015-01-01'
group by i.InvoiceID, i.InvoiceDate
)
select i.InvoiceID, c.CustomerName, i.InvoiceDate, Sum_Sales, sum(Sum_Sales) over (order by year(i.InvoiceDate), month(i.InvoiceDate)) as Sum_Cumulative
from sales.Invoices i 
inner join sales.Customers c on i.CustomerID=c.CustomerID
join cte on i.InvoiceID=cte.InvoiceID
where i.InvoiceDate>='2015-01-01'
order by i.InvoiceDate, Sum_Sales

set statistics time, io off


-- SQL Server Execution Times:
--   CPU time = 93 ms,  elapsed time = 141 ms.

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
;
with cte as(
select StockItemID, sum(Quantity) as Qty, month(i.InvoiceDate) as MonthID, DENSE_RANK() over (partition by month(i.InvoiceDate) order by sum(il.Quantity) desc) as rnk from sales.Invoices i 
inner join sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
where i.InvoiceDate >= '2016-01-01' and i.InvoiceDate <'2017-01-01'
group by StockItemID, month(i.InvoiceDate)
--order by month(i.InvoiceDate), Qty desc
)
select s.StockItemName, Qty, c.MonthID as [Month], '2016' as [Year] from cte c 
join Warehouse.StockItems s on c.StockItemID=s.StockItemID
where rnk<=2
order by MonthID, Qty desc
/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select row_number() over(partition by left(StockItemName,1) order by StockItemName) as NumerationFirst,
		 count(StockItemID) over() as QtySecond,
		 count(*) over(partition by left(StockItemName,1)) as QtyThird,
		 lead(StockItemID) over (order by StockItemName) as NextIDForth,
		 lag(StockItemID) over (order by StockItemName) as PrevIdFifth,
		 lag(StockItemName, 2, 'No Items') over (order by StockItemName) as NameItemSixth,
		 ntile(30) over(order by typicalweightperunit) as WeightSeventh ,
		 StockItemID, StockItemName, 
		 Brand,
		 UnitPrice
from Warehouse.StockItems
order by StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

;
with cte as(
select DISTINCT last_value(i.InvoiceID)   over (partition by i.SalespersonPersonID order by i.InvoiceDate, i.InvoiceID rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as LastInvoiceId
, i.SalespersonPersonID
from sales.Invoices i),
cte2 as
(select sum(Quantity*UnitPrice) as SumSales, c.SalespersonPersonID as SalesPersonId from sales.InvoiceLines  il
join cte c on il.InvoiceLineID=c.LastInvoiceId
group by c.SalespersonPersonID
)
select DISTINCT last_value(c.CustomerName) over (partition by i.SalespersonPersonID order by i.InvoiceDate, i.InvoiceID 
		  rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as CustomerName,
		  i.SalespersonPersonID, 
		  p.FullName,  
		  last_value(i.InvoiceDate) over (partition by i.SalespersonPersonID order by i.InvoiceDate, i.InvoiceID rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as LastSalesDate
		  ,
		 cte2.SumSales
from sales.Invoices i
inner join sales.Customers c  on i.CustomerID=c.CustomerID
inner join Application.People p on i.SalespersonPersonID=p.PersonID
inner join cte2 on i.SalespersonPersonID=cte2.SalesPersonId
order by i.SalespersonPersonID



/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;
with cte as (
select dense_rank() over (PARTITION by i.CustomerID order by il.UnitPrice desc) as rnk, i.CustomerID, il.StockItemID, i.InvoiceID from sales.Invoices i
inner join sales.InvoiceLines il on i.InvoiceID=il.InvoiceID)
select c.CustomerID, cu.CustomerName, c.StockItemID, s.StockItemName, s.UnitPrice, i.InvoiceDate from cte c 
join Warehouse.StockItems as s on c.StockItemID=s.StockItemID
join sales.Invoices i on c.InvoiceID=i.InvoiceID
join sales.Customers cu on c.CustomerID=cu.CustomerID
where rnk<=2
order by CustomerID, rnk




--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 