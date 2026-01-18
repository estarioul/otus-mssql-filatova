/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
select convert(varchar, datefromparts(YY, MM, 1),104) as InvoiceMonth, 
		 [Peeples Valley, AZ], 
		 [Medicine Lodge, KS], 
		 [Gasport, NY], 
		 [Jessie, ND], 
		 [Sylvanite, MT] from 
(
select month(i.InvoiceDate)  as MM, year(i.InvoiceDate) as YY, SUBSTRING(cu.CustomerName, 16, CHARINDEX(')',cu.CustomerName)  -16) as customername, InvoiceID  from sales.Invoices i
inner join sales.Customers cu on i.CustomerID=cu.CustomerID
where cu.CustomerID >=2 and cu.CustomerID<=6
) as t
pivot (
count(invoiceid)  
for customername in ([Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])
) as pvt
order by InvoiceMonth

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
select CustomerName, AddressLine from (
select CustomerName, DeliveryAddressLine1, DeliveryAddressLine2 from Sales.Customers
where CustomerName like '%Tailspin Toys%') as t
unpivot
(
AddressLine for Address in (DeliveryAddressLine1, DeliveryAddressLine2)
) as unpt


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/


select  CountryID, CountryName, Code from (
select  CountryID, CountryName, IsoAlpha3Code, convert(nvarchar(3), IsoNumericCode) AS IsoNumericCode1 from Application.Countries
) as t
unpivot
(
Code for Code1 in (IsoAlpha3Code, isoNumericCode1)
) as unpt



/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select s.CustomerID, s.CustomerName, i.StockItemID, i.UnitPrice, i.InvoiceDate from Sales.Customers s
cross apply (
		  select top 2 with ties il.UnitPrice, i.InvoiceID, il.StockItemID, i.InvoiceDate from sales.Invoices i 
		  inner join sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
		  where i.CustomerID=s.CustomerID
		  order by il.UnitPrice DESC
		  ) as i
order by s.CustomerName, i.UnitPrice desc, i.InvoiceDate desc




