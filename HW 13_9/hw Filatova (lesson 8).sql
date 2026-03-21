/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/



/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--OPENXML:

declare @xmlDocument xml;

select @xmlDocument = BulkColumn
from openrowset(bulk 'D:\StockItems.xml', SINGLE_BLOB) as t

declare @docHandle int;
exec sp_xml_preparedocument @docHandle output, @xmlDocument;

create table #Data(
	[StockItemName]  NVARCHAR(100) COLLATE database_default,
	[SupplierId] INT ,
	[UnitPackageID] INT,
	[OuterPackageID] Int,
	[QuantityPerOuter] Int ,
	[TypicalWeightPerUnit] decimal(18,3),
	[LeadTimeDays] int,
	[IsChillerStock] int,
	[TaxRate]  decimal(18,3),
	[UnitPrice] decimal(18,6)	
)
insert into #data
select *
from openxml(@docHandle, N'/StockItems/Item') --путь к строкам
WITH ( 
	[StockItemName]  NVARCHAR(100)  '@Name', -- атрибут
	[SupplierId] INT 'SupplierID', -- элемент 
	[UnitPackageID] INT 'Package/UnitPackageID',
	[OuterPackageID] Int 'Package/OuterPackageID',
	[QuantityPerOuter] Int 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] int 'LeadTimeDays',
	[IsChillerStock] int 'IsChillerStock',
	[TaxRate]  decimal(18,3)  'TaxRate',
	[UnitPrice] decimal(18,6) 'UnitPrice'	
	)
select * from #data

EXEC sp_xml_removedocument @docHandle;

merge  [Warehouse].[StockItems] as target
using  [#data]  as source on source.StockItemName=target.StockItemName
when matched then update set SupplierId=source.SupplierId,
										UnitPackageID=source.UnitPackageID,
										OuterPackageID=source.OuterPackageID,
										QuantityPerOuter=source.QuantityPerOuter,
										TypicalWeightPerUnit=source.TypicalWeightPerUnit,
										LeadTimeDays=source.LeadTimeDays,
										IsChillerStock=source.IsChillerStock,
										TaxRate=source.TaxRate,
										UnitPrice=source.UnitPrice	
when not matched by target then insert (StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, 
LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy					 
)
values (source.StockItemName, 
 source.SupplierId, source.UnitPackageID,
 source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, 
 source.TaxRate, source.UnitPrice, 1
)
output $action, deleted.*, inserted.*;

drop table #data

--SELECT @docHandle AS docHandle, @xmlDocument AS [@xmlDocument];


--	ВАРИАНТ 2 XQuery

declare @xDoc xml;

select @xDoc = BulkColumn
from openrowset(bulk 'D:\StockItems.xml', SINGLE_BLOB) as t

select @xDoc

create table #Data2(
	[StockItemName]  NVARCHAR(100) COLLATE database_default,
	[SupplierId] INT ,
	[UnitPackageID] INT,
	[OuterPackageID] Int,
	[QuantityPerOuter] Int ,
	[TypicalWeightPerUnit] decimal(18,3),
	[LeadTimeDays] int,
	[IsChillerStock] int,
	[TaxRate]  decimal(18,3),
	[UnitPrice] decimal(18,6)	
)
insert into #data2
SELECT 
   [StockItemName] = t.Item.value('(@Name)[1]','varchar(100)')
	,SupplierId = t.Item.value('(SupplierID)[1]','int')
   ,UnitPackageID = t.Item.value('(Package/UnitPackageID)[1]','int')
	,OuterPackageID = t.Item.value('(Package/OuterPackageID)[1]','int')
	,QuantityPerOuter = t.Item.value('(Package/QuantityPerOuter)[1]','int')
	,TypicalWeightPerUnit = t.Item.value('(Package/TypicalWeightPerUnit)[1]','decimal(18,3)')
	,LeadTimeDays = t.Item.value('(LeadTimeDays)[1]','int')
	,IsChillerStock = t.Item.value('(IsChillerStock)[1]','int')
	,TaxRate = t.Item.value('(TaxRate)[1]','decimal(18,3)')
	,UnitPrice = t.Item.value('(UnitPrice)[1]','decimal(18,3)')
	FROM @xDoc.nodes('/StockItems/Item') AS t(Item)


select * from #data2

merge  [Warehouse].[StockItems] as target
using  [#data2]  as source on source.StockItemName=target.StockItemName
when matched then update set  SupplierId=source.SupplierId,
										UnitPackageID=source.UnitPackageID,
										OuterPackageID=source.OuterPackageID,
										QuantityPerOuter=source.QuantityPerOuter,
										TypicalWeightPerUnit=source.TypicalWeightPerUnit,
										LeadTimeDays=source.LeadTimeDays,
										IsChillerStock=source.IsChillerStock,
										TaxRate=source.TaxRate,
										UnitPrice=source.UnitPrice		
when not matched by target then insert (StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, 
LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy					 
)
values (source.StockItemName, 
 source.SupplierId, source.UnitPackageID,
 source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, 
 source.TaxRate, source.UnitPrice, 1
)
output $action, deleted.*, inserted.*;

--проверяем
select * from [Warehouse].[StockItems]
where StockItemID=229

drop table #data2

GO 




/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

declare @a_xml xml

select @a_xml = (

SELECT 
    StockItemName AS [@Name], 
    SupplierID AS [SupplierID], 
    UnitPackageID AS [Package/UnitPackageID],
    OuterPackageID AS [Package/OuterPackageID],
    QuantityPerOuter AS [Package/QuantityPerOuter],
    TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit],
    LeadTimeDays As [LeadTimeDays],
    IsChillerStock AS [IsChillerStock],
    TaxRate as [TaxRate],
	 Convert(decimal(18,6) , UnitPrice) as [UnitPrice]	
FROM Warehouse.StockItems
where StockItemName in ('"The Gu" red shirt XML tag t-shirt (Black) 3XXL',
'Developer joke mug (Yellow)',
'Dinosaur battery-powered slippers (Green) L',
'Dinosaur battery-powered slippers (Green) M',
'Dinosaur battery-powered slippers (Green) S',
'Furry gorilla with big eyes slippers (Black) XL',
'Large  replacement blades 18mm',
'Large sized bubblewrap roll 50m',
'Medium sized bubblewrap roll 20m',
'Shipping carton (Brown) 356x229x229mm',
'Shipping carton (Brown) 356x356x279mm',
'Shipping carton (Brown) 413x285x187mm',
'Shipping carton (Brown) 457x279x279mm',
'USB food flash drive - sushi roll',
'USB missile launcher (Green)')
order by StockItemName
FOR XML PATH('Item'), ROOT('StockItems')
)

drop table if exists xml1
select @a_xml as a into xml1


exec master..xp_cmdshell 'bcp "SELECT cast(a as nvarchar(max)) from [WideWorldImporters].dbo.xml1"  queryout  "D:\XML_new.xml" -w -T -S ELENA-MINI-PC'





/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select i.StockItemID, i.StockItemName, t.*, i.CustomFields
from Warehouse.StockItems as i
cross apply openjson(CustomFields) with (
	CountryOfManufacture nvarchar(25) '$.CountryOfManufacture'
	, FirstTag nvarchar(25) '$.Tags[0]'
) t



/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

--все
select ST.StockItemID, ST.StockItemName,  ST.CustomFields, 
A.CountryOfManufacture + ' , ' + isnull(cast(MinimumAge as varchar),'') + iif(MinimumAge is not null, ' , ', '') + isnull([Range],'') + iif([Range] is not null, ' , ', '') +    string_agg(A.value, ',')  from Warehouse.StockItems ST
cross apply (
				select t.*, c.value 
				from openjson (ST.CustomFields) --путь к строкам
				with (
					 CountryOfManufacture varchar(25),
					 MinimumAge int, 
					 Tags   nvarchar(max)   '$.Tags' AS JSON,
					 [Range] varchar(50)   '$.Range'
				) t
				outer apply openjson(t.Tags) c
) as A
group by st.StockItemID, st.StockItemName, st.CustomFields, A.CountryOfManufacture, A.MinimumAge, A.[Range]



--Vintage
select ST.StockItemID, ST.StockItemName,  ST.CustomFields, 
A.CountryOfManufacture + ' , ' + isnull(cast(MinimumAge as varchar),'') + iif(MinimumAge is not null, ' , ', '') + isnull([Range],'') + iif([Range] is not null, ' , ', '') +    string_agg(A.value, ',')  from Warehouse.StockItems ST
cross apply (
				select t.*, c.value 
				from openjson (ST.CustomFields) --путь к строкам
				with (
					 CountryOfManufacture varchar(25),
					 MinimumAge int, 
					 Tags   nvarchar(max)   '$.Tags' AS JSON,
					 [Range] varchar(50)   '$.Range'
				) t
				outer apply openjson(t.Tags) c
) as A
where A.value='Vintage'
group by st.StockItemID, st.StockItemName, st.CustomFields, A.CountryOfManufacture, A.MinimumAge, A.[Range]