/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

declare @str nvarchar(max), @query_str nvarchar(max);

with cte as(
	 select distinct cu.CustomerName CName
	 from sales.Invoices i
	 inner join sales.Customers cu on i.CustomerID=cu.CustomerID
) select @str = string_agg(cast (quotename(cte.CName) as nvarchar(max)),',')  within group(order by cte.CName) from cte


select @query_str = '

select  convert(varchar,  datefromparts(YY, MM, 1), 104)  as InvoiceMonth, 
		 ' + @str + '  from 
(
select month(i.InvoiceDate)  as MM, year(i.InvoiceDate) as YY, InvoiceID, cu.CustomerName from sales.Invoices i
inner join sales.Customers cu on i.CustomerID=cu.CustomerID
) as t
pivot (
count(invoiceid)  
for CustomerName in (' +  @str  + ')
) as pvt
order by InvoiceMonth'

exec sp_executesql @query_str
