/*111
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/



with cte as(
select top 5 SupplierName  as  SupplierName , 1 as BillToCustomerID, 1 as CustomerCategoryID, PrimaryContactPersonID, 1 as DeliveryMethodID, 
DeliveryCityID, PostalCityID,1000 as CreditLimit, '2026-01-01' as AccountOpenedDate, 0 as StandardDiscountPercentage, 0 as IsStatementSent, 0 as IsOnCreditHold, 7 as PaymentDays,
phoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1,
PostalAddressLine2, PostalPostalCode, 1 as LastEditedBy
from Purchasing.Suppliers p 
order by SupplierID DESC
)

insert into sales.Customers(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID,
DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, 
PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1,
PostalAddressLine2, PostalPostalCode, LastEditedBy)
select (next value for [Sequences].[CustomerID]), * from cte


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

with del as(
		  select top 1 *  
		  from sales.Customers 
		  where ValidFrom > '2025-01-19 20:00'
		  order by customerid desc)
delete from del 
output deleted.*

select * from sales.Customers
where ValidFrom >  '2025-01-19 20:00'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update sales.Customers
set DeliveryMethodID=2
where CustomerID=1092


/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

merge  sales.Customers  as target
using  Purchasing.Suppliers as source on source.SupplierName=target.customername
when matched then update set creditlimit=creditlimit*2
when not matched by target then insert (
					  CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, 
					  PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays,
					  PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1,
					 PostalAddressLine2, PostalPostalCode, LastEditedBy
)
values (source.SupplierName, 1, 2, 1, 1,
 source.DeliveryCityID, source.PostalCityID, 4100, '2026-01-01', 0, 0, 0, 7,
 source.PhoneNumber, source.FaxNumber, source.WebsiteURL, source.DeliveryAddressLine1, source.DeliveryAddressLine2, source.DeliveryPostalCode, source.DeliveryLocation, source.PostalAddressLine1,
 source.PostalAddressLine2, source.PostalPostalCode, 1)
output $action, deleted.*, inserted.*
;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/


select @@servername

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Purchasing.Suppliers" out  "D:\Suppliers_new_new.txt" -T -w -t"@eu&$1&" -S ELENA-MINI-PC'

drop table if exists Purchasing.Suppliers_New
-- копируем структуру таблицы
select * into Purchasing.Suppliers_New from Purchasing.Suppliers where 1=0

select * from Purchasing.Suppliers_New

BULK INSERT  Purchasing.Suppliers_New
FROM 'D:\Suppliers_new_new.txt'
WITH (
		BATCHSIZE = 1000,       -- commit every 1000 rows
		DATAFILETYPE = 'widechar', -- file uses Unicode widechar format (BCP -w)
		FIELDTERMINATOR = '@eu&$1&', -- custom delimiter used in the BCP command above
		ROWTERMINATOR ='\n',   -- newline row terminator (may need '\r\n' for Windows files)
		KEEPNULLS,
		TABLOCK         
		);