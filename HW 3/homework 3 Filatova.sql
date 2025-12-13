/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


select year(o.OrderDate) as 'OrderYear', month(o.OrderDate) as 'OrderMonth', AVG(OL.UnitPrice) as 'AVGPrice',format( SUM(OL.Quantity*oL.UnitPrice), '### ### ###.00')  as 'SumSales For Month' from Sales.orders o 
inner join sales.OrderLines ol on o.OrderID=ol.OrderID
group by format(o.OrderDate, 'MMyyyy'), year(o.OrderDate), month(o.OrderDate)
order by year(o.OrderDate), month(o.OrderDate)

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(o.OrderDate) as 'OrderYear', month(o.OrderDate) as 'OrderMonth', format( SUM(OL.Quantity*oL.UnitPrice), '### ### ###.00')  as 'SumSales For Month' from Sales.orders o 
inner join sales.OrderLines ol on o.OrderID=ol.OrderID
group by format(o.OrderDate, 'MMyyyy'), year(o.OrderDate), month(o.OrderDate)
having SUM(OL.Quantity*oL.UnitPrice) > 4600000
order by year(o.OrderDate), month(o.OrderDate)

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


select  year(o.OrderDate) as 'OrderYear', 
		  month(o.OrderDate) as 'OrderMonth', 
		  max(i.StockItemName), 
		  format(SUM(OL.Quantity*oL.UnitPrice), '### ### ###.00')  as 'SumSales For Month and StockItem', 
		  min(o.OrderDate) as 'FirstSalesDate', 
		  sum(ol.Quantity)  as 'Quantity'
from Sales.orders o 
inner join sales.OrderLines ol on o.OrderID=ol.OrderID
inner join Warehouse.StockItems i on ol.StockItemID=i.StockItemID
group by format(o.OrderDate, 'MMyyyy'), year(o.OrderDate), month(o.OrderDate), ol.StockItemID
having sum(ol.Quantity)>50
order by year(o.OrderDate), month(o.OrderDate), max(i.StockItemName) 
-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж (НЕ совсем поняла задание, продажи есть во всех месяцах),
то этот месяц также отображался бы в результатах, но там были нули.
*/

--запрос 2
select year(o.OrderDate) as 'OrderYear', month(o.OrderDate) as 'OrderMonth', 
	
	case when  SUM(OL.Quantity*oL.UnitPrice) > 4600000 
		  then format( SUM(OL.Quantity*oL.UnitPrice), '### ### ###.00') 
		  else '0' end	
	as 'SumSales For Month' from Sales.orders o 
inner join sales.OrderLines ol on o.OrderID=ol.OrderID
group by format(o.OrderDate, 'MMyyyy'), year(o.OrderDate), month(o.OrderDate)
--having SUM(OL.Quantity*oL.UnitPrice) > 4600000
order by year(o.OrderDate), month(o.OrderDate)

--запрос 3

select  year(o.OrderDate) as 'OrderYear', 
		  month(o.OrderDate) as 'OrderMonth', 
		  max(i.StockItemName), 
		  case when sum(ol.Quantity)>50 
				 then  format(SUM(OL.Quantity*oL.UnitPrice), '### ### ###.00') 
		       else '0' end
				 as 'SumSales For Month and StockItem', 
		  min(o.OrderDate) as 'FirstSalesDate', 
		  sum(ol.Quantity)  as 'Quantity'
from Sales.orders o 
inner join sales.OrderLines ol on o.OrderID=ol.OrderID
inner join Warehouse.StockItems i on ol.StockItemID=i.StockItemID
group by format(o.OrderDate, 'MMyyyy'), year(o.OrderDate), month(o.OrderDate), ol.StockItemID
--having sum(ol.Quantity)>50
order by year(o.OrderDate), month(o.OrderDate), max(i.StockItemName) 