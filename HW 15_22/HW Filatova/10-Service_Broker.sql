
--------------------------
-- подготовка
USE [Finance]

--включить брокер
USE master 
ALTER DATABASE [Finance] SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; 
-- NO WAIT дл¤ prod (в однопользовательском режиме!!!)

--sb должен функционировать от имени sa
ALTER AUTHORIZATION ON DATABASE::[Finance] TO [sa];


--------------------------
-- инфраструктура
-- Service: Queue + Contract(Direction, MessageType) 

USE [Finance]

-- naming
CREATE MESSAGE TYPE [//FI/SB/RequestMessage] VALIDATION=WELL_FORMED_XML;
CREATE MESSAGE TYPE [//FI/SB/ReplyMessage] VALIDATION=WELL_FORMED_XML;

CREATE CONTRACT [//FI/SB/Contract] (
	[//FI/SB/RequestMessage] SENT BY INITIATOR
    , [//FI/SB/ReplyMessage] SENT BY TARGET
    );

-- цель
CREATE QUEUE TargetQueueFI;
CREATE SERVICE [//FI/SB/TargetService] ON QUEUE TargetQueueFI ([//FI/SB/Contract]);

--инициатор
CREATE QUEUE InitiatorQueueFI;
CREATE SERVICE [//FI/SB/InitiatorService] ON QUEUE InitiatorQueueFI ([//FI/SB/Contract]);

--- хп
-- 20-dbo.SendNewIncomeToSavings.sql - обычная хп
-- 30-[dbo].[SendNewIncomeToSavings].sql - RECEIVE на стороне цели; активационная процедура (всегда без параметров)
-- 40-dbo.ConfirmIncome.sql - RECEIVE на стороне инициатора; активационная процедура (всегда без параметров)

--------------------------
-- тесты

SELECT *
FROM Income i
join Items it on i.ItemId=it.ItemId
WHERE it.Name = 'Андрей зарплата' and i.incomeid=5

-- отправка в ручном режме
-- SEND 2 target (открыли диалог)
EXEC dbo.SendNewIncomeToSavings @IncomeId = 5;

SELECT CAST(message_body AS XML),* FROM dbo.TargetQueueFI; -- здесь сообщение
SELECT CAST(message_body AS XML),* FROM dbo.InitiatorQueueFI;

EXEC [dbo].[GetNewAmountFromIncome]; -- без параметров!

select * from savings
where itemid=162

SELECT CAST(message_body AS XML),* FROM dbo.TargetQueueFI; -- здесь сообщение
SELECT CAST(message_body AS XML),* FROM dbo.InitiatorQueueFI;

EXEC [dbo].[ConfirmIncome] -- без параметров

--список диалогов
SELECT conversation_handle, is_initiator, s.name as 'local service', far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce 
-- представление диалогов удаляется асинхронно сборщиком мусора Service Broker, а не в момент END CONVERSATION
-- чтобы её не переполнять НЕЛЬЗЯ ЗАВЕРШАТЬ ДИАЛОГ ДО ОТПРАВКИ ПЕРВОГО СООБЩЕНИЯ
LEFT JOIN sys.services s ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;


--------------------------
-- автоматическая обработка через процедуры активации (без параметров)
ALTER QUEUE TargetQueueFI 
WITH ACTIVATION (
	STATUS = Off -- вкл
	, PROCEDURE_NAME = [dbo].[GetNewAmountFromIncome]
	, MAX_QUEUE_READERS = 1 -- 1 worker (0 - хп будет вызвана)
	, EXECUTE AS OWNER -- контекст безопаности
	); 
GO

ALTER QUEUE InitiatorQueueFI 
WITH ACTIVATION (
	STATUS = Off --  вкл
	, PROCEDURE_NAME = [dbo].[ConfirmIncome]
	, MAX_QUEUE_READERS = 1 -- 1 worker (0 - хп будет вызвана)
	, EXECUTE AS OWNER -- контекст безопаности
	); 
GO

/*
ALTER QUEUE InitiatorQueueWWI WITH 
	STATUS = ON -- вкл очередь
	, RETENTION = OFF -- успешая обработка => сообщение удаляетс¤ (очередь не раздуваетс¤)
	, POISON_MESSAGE_HANDLING (STATUS = OFF) -- защита от бесконечного цикла попытки доставить сообщение (5 раз и стоп)
	, ACTIVATION (STATUS = ON -- автоактиваци¤
		, PROCEDURE_NAME = Sales.ConfirmInvoice
		, MAX_QUEUE_READERS = 1 -- количество потоков
		, EXECUTE AS OWNER -- учетка от имени которой запуститс¤ ’ѕ
		); 
GO

ALTER QUEUE TargetQueueWWI WITH 
	STATUS = ON 
	, RETENTION = OFF 
	, POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  
		STATUS = ON 
		, PROCEDURE_NAME = Sales.GetNewInvoice
		, MAX_QUEUE_READERS = 1
		, EXECUTE AS OWNER
		); 
GO
*/
