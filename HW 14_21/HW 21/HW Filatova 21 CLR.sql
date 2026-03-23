/*
Часть 1
sp_configure 'show advanced options', 1
sp_configure 'clr enabled', 1
sp_configure 'clr strict security', 0
ALTER DATABASE [Finance] SET TRUSTWORTHY ON;
RECONFIGURE 
*/
/*
Часть 2
--CREATE ASSEMBLY StringAggDLL FROM
--'D:\StringAggProject.dll'

*/
--пришлось ставить nvarchar(4000), иначе писал разные параметры
--create procedure dbo.StringAggProc
--		  @tablename nvarchar(4000),
--		  @columnname nvarchar(4000),
--		  @separator nvarchar(4000)=''
--as external name StringAggDLL.[StringAggProject.MyCLRProjectStringAgg].MyClr;


select top 10 Name, clientid into items1 from items
where ExpIncSav='exp'

select * from items1

exec dbo.StringAggProc @tablename='items1', @columnname='name', @separator='; '