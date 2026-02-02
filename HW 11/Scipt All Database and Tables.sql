create database Finance3
/****** Object:  Table [dbo].[Accounts]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
use Finance3
CREATE TABLE [dbo].[Accounts](
	[AccountId] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[ClientId] [bigint] NOT NULL,
	[Description] [varchar](255) NULL,
	[Image] [image] NULL,
	[Is_del] [bit] NULL,
	[LastUpdate] [datetime] NOT NULL,
	[UserCode] [varchar](30) NOT NULL,
	[TimeStamp] [timestamp] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Clients]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients](
	[ClientId] [bigint] IDENTITY(1,1) NOT NULL,
	[Surname] [varchar](50) NULL,
	[Name] [varchar](50) NOT NULL,
	[Otchestvo] [varchar](50) NULL,
	[Phone] [varchar](20) NULL,
	[Phonenum] [bigint] NULL,
	[Email] [varchar](100) NULL,
	[LastUpdate] [datetime] NOT NULL,
	[UserCode] [varchar](30) NOT NULL,
	[TimeStamp] [timestamp] NOT NULL,
	[Is_del] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ClientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Expenses]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Expenses](
	[ExpenseId] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientId] [bigint] NOT NULL,
	[AccountId] [bigint] NOT NULL,
	[ItemId] [bigint] NOT NULL,
	[SummE] [money] NOT NULL,
	[DateE] [datetime] NOT NULL,
	[Description] [varchar](255) NULL,
	[Image] [image] NULL,
	[Huge] [bit] NULL,
	[FromSavingId] [bigint] NULL,
	[Is_del] [bit] NULL,
	[Is_test] [bit] NULL,
	[LastUpdate] [datetime] NOT NULL,
	[UserCode] [varchar](30) NOT NULL,
	[TimeStamp] [timestamp] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ExpenseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Expenses_2]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Expenses_2](
	[ExpenseId] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientId] [bigint] NOT NULL,
	[AccountId] [bigint] NOT NULL,
	[ItemId] [bigint] NOT NULL,
	[SummE] [money] NOT NULL,
	[DateE] [datetime] NOT NULL,
	[Description] [varchar](255) NULL,
	[Image] [image] NULL,
	[Huge] [bit] NULL,
	[Is_del] [bit] NULL,
	[Is_test] [bit] NULL,
	[LastUpdate] [datetime] NOT NULL,
	[UserCode] [varchar](30) NOT NULL,
	[TimeStamp] [timestamp] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Income]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Income](
	[IncomeId] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientId] [bigint] NOT NULL,
	[AccountId] [bigint] NOT NULL,
	[ItemId] [bigint] NOT NULL,
	[SummI] [money] NOT NULL,
	[DateI] [datetime] NOT NULL,
	[Description] [varchar](255) NULL,
	[Image] [image] NULL,
	[Is_del] [bit] NULL,
	[Is_test] [bit] NULL,
	[LastUpdate] [datetime] NOT NULL,
	[UserCode] [varchar](30) NOT NULL,
	[TimeStamp] [timestamp] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IncomeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Items]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Items](
	[ItemId] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[ClientId] [bigint] NOT NULL,
	[ExpIncSav] [varchar](3) NOT NULL,
	[Description] [varchar](255) NULL,
	[Image] [image] NULL,
	[Is_del] [bit] NULL,
	[Is_test] [bit] NULL,
	[LastUpdate] [datetime] NOT NULL,
	[UserCode] [varchar](30) NOT NULL,
	[TimeStamp] [timestamp] NOT NULL,
	[Huge] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MoneyOK_020125]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MoneyOK_020125](
	[Дата] [datetime] NULL,
	[Сумма] [float] NULL,
	[Валюта] [nvarchar](255) NULL,
	[Счет] [nvarchar](255) NULL,
	[Статья] [nvarchar](255) NULL,
	[Группа статей] [nvarchar](255) NULL,
	[Комментарий﻿] [nvarchar](255) NULL,
	[Itemid] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MoneyOK4]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MoneyOK4](
	[Дата] [datetime] NULL,
	[Сумма] [float] NULL,
	[Валюта] [nvarchar](255) NULL,
	[Счет] [nvarchar](255) NULL,
	[Статья] [nvarchar](255) NULL,
	[Группа статей] [nvarchar](255) NULL,
	[Комментарий﻿] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Savings]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Savings](
	[SavingId] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientId] [bigint] NOT NULL,
	[AccountId] [bigint] NOT NULL,
	[ItemId] [bigint] NOT NULL,
	[SummS] [money] NOT NULL,
	[DateS] [datetime] NOT NULL,
	[Description] [varchar](255) NULL,
	[Image] [image] NULL,
	[FromIncomeId] [bigint] NULL,
	[Is_del] [bit] NULL,
	[Is_test] [bit] NULL,
	[LastUpdate] [datetime] NOT NULL,
	[UserCode] [varchar](30) NOT NULL,
	[TimeStamp] [timestamp] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SavingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Статьи_020125]    Script Date: 02.02.2026 9:37:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Статьи_020125](
	[Item] [nvarchar](255) NULL,
	[Types] [nvarchar](255) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accounts] ADD  CONSTRAINT [DF_Accounts_Is_del]  DEFAULT ((0)) FOR [Is_del]
GO
ALTER TABLE [dbo].[Accounts] ADD  CONSTRAINT [DF_Accounts_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[Accounts] ADD  CONSTRAINT [DF_Accounts_UserCode]  DEFAULT (suser_sname()) FOR [UserCode]
GO
ALTER TABLE [dbo].[Clients] ADD  CONSTRAINT [DF_Clients_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[Clients] ADD  CONSTRAINT [DF_Clients_UserCode]  DEFAULT (suser_sname()) FOR [UserCode]
GO
ALTER TABLE [dbo].[Clients] ADD  CONSTRAINT [DF_Clients_Is_del]  DEFAULT ((0)) FOR [Is_del]
GO
ALTER TABLE [dbo].[Expenses] ADD  CONSTRAINT [DF_Expenses_DateE]  DEFAULT (getdate()) FOR [DateE]
GO
ALTER TABLE [dbo].[Expenses] ADD  CONSTRAINT [DF_Expenses_Huge]  DEFAULT ((0)) FOR [Huge]
GO
ALTER TABLE [dbo].[Expenses] ADD  CONSTRAINT [DF_Expenses_Is_del]  DEFAULT ((0)) FOR [Is_del]
GO
ALTER TABLE [dbo].[Expenses] ADD  CONSTRAINT [DF_Expenses_Is_test]  DEFAULT ((0)) FOR [Is_test]
GO
ALTER TABLE [dbo].[Expenses] ADD  CONSTRAINT [DF_Expenses_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[Expenses] ADD  CONSTRAINT [DF_Expenses_UserCode]  DEFAULT (suser_sname()) FOR [UserCode]
GO
ALTER TABLE [dbo].[Income] ADD  CONSTRAINT [DF_Income_DateI]  DEFAULT (getdate()) FOR [DateI]
GO
ALTER TABLE [dbo].[Income] ADD  CONSTRAINT [DF_Income_Is_del]  DEFAULT ((0)) FOR [Is_del]
GO
ALTER TABLE [dbo].[Income] ADD  CONSTRAINT [DF_Income_Is_test]  DEFAULT ((0)) FOR [Is_test]
GO
ALTER TABLE [dbo].[Income] ADD  CONSTRAINT [DF_Income_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[Income] ADD  CONSTRAINT [DF_Income_UserCode]  DEFAULT (suser_sname()) FOR [UserCode]
GO
ALTER TABLE [dbo].[Items] ADD  CONSTRAINT [DF_Items_Is_del]  DEFAULT ((0)) FOR [Is_del]
GO
ALTER TABLE [dbo].[Items] ADD  CONSTRAINT [DF_Items_Is_test]  DEFAULT ((0)) FOR [Is_test]
GO
ALTER TABLE [dbo].[Items] ADD  CONSTRAINT [DF_Items_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[Items] ADD  CONSTRAINT [DF_Items_UserCode]  DEFAULT (suser_sname()) FOR [UserCode]
GO
ALTER TABLE [dbo].[Savings] ADD  CONSTRAINT [DF_Savings_DateS]  DEFAULT (getdate()) FOR [DateS]
GO
ALTER TABLE [dbo].[Savings] ADD  CONSTRAINT [DF_Savings_Is_del]  DEFAULT ((0)) FOR [Is_del]
GO
ALTER TABLE [dbo].[Savings] ADD  CONSTRAINT [DF_Savings_Is_test]  DEFAULT ((0)) FOR [Is_test]
GO
ALTER TABLE [dbo].[Savings] ADD  CONSTRAINT [DF_Savings_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[Savings] ADD  CONSTRAINT [DF_Savings_UserCode]  DEFAULT (suser_sname()) FOR [UserCode]
GO
ALTER TABLE [dbo].[Accounts]  WITH NOCHECK ADD  CONSTRAINT [FK_Accounts_ClientId] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Clients] ([ClientId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Accounts] CHECK CONSTRAINT [FK_Accounts_ClientId]
GO
ALTER TABLE [dbo].[Expenses]  WITH NOCHECK ADD  CONSTRAINT [FK_Expenses_AccountId] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Accounts] ([AccountId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Expenses] CHECK CONSTRAINT [FK_Expenses_AccountId]
GO
ALTER TABLE [dbo].[Expenses]  WITH NOCHECK ADD  CONSTRAINT [FK_Expenses_ClientId] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Clients] ([ClientId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Expenses] CHECK CONSTRAINT [FK_Expenses_ClientId]
GO
ALTER TABLE [dbo].[Expenses]  WITH NOCHECK ADD  CONSTRAINT [FK_Expenses_ItemId] FOREIGN KEY([ItemId])
REFERENCES [dbo].[Items] ([ItemId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Expenses] CHECK CONSTRAINT [FK_Expenses_ItemId]
GO
ALTER TABLE [dbo].[Income]  WITH NOCHECK ADD  CONSTRAINT [FK_Accounts_AccountId] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Accounts] ([AccountId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Income] CHECK CONSTRAINT [FK_Accounts_AccountId]
GO
ALTER TABLE [dbo].[Income]  WITH NOCHECK ADD  CONSTRAINT [FK_Income_ClientId] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Clients] ([ClientId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Income] CHECK CONSTRAINT [FK_Income_ClientId]
GO
ALTER TABLE [dbo].[Income]  WITH NOCHECK ADD  CONSTRAINT [FK_Income_ItemId] FOREIGN KEY([ItemId])
REFERENCES [dbo].[Items] ([ItemId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Income] CHECK CONSTRAINT [FK_Income_ItemId]
GO
ALTER TABLE [dbo].[Items]  WITH NOCHECK ADD  CONSTRAINT [FK_Items_ClientId] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Clients] ([ClientId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Items] CHECK CONSTRAINT [FK_Items_ClientId]
GO
ALTER TABLE [dbo].[Savings]  WITH NOCHECK ADD  CONSTRAINT [FK_Savings_AccountId] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Accounts] ([AccountId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Savings] CHECK CONSTRAINT [FK_Savings_AccountId]
GO
ALTER TABLE [dbo].[Savings]  WITH NOCHECK ADD  CONSTRAINT [FK_Savings_ClientId] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Clients] ([ClientId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Savings] CHECK CONSTRAINT [FK_Savings_ClientId]
GO
ALTER TABLE [dbo].[Savings]  WITH NOCHECK ADD  CONSTRAINT [FK_Savings_ItemId] FOREIGN KEY([ItemId])
REFERENCES [dbo].[Items] ([ItemId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Savings] CHECK CONSTRAINT [FK_Savings_ItemId]
GO
ALTER TABLE [dbo].[Accounts]  WITH CHECK ADD  CONSTRAINT [CH_LastUpdate_XXI_centiry] CHECK  (([LastUpdate]>='2000-01-01'))
GO
ALTER TABLE [dbo].[Accounts] CHECK CONSTRAINT [CH_LastUpdate_XXI_centiry]
GO
ALTER TABLE [dbo].[Clients]  WITH CHECK ADD  CONSTRAINT [CH_Phone_Rus] CHECK  (([Phonenum]>(0)))
GO
ALTER TABLE [dbo].[Clients] CHECK CONSTRAINT [CH_Phone_Rus]
GO
ALTER TABLE [dbo].[Expenses]  WITH CHECK ADD  CONSTRAINT [CH_SummE] CHECK  (([SummE]<(0)))
GO
ALTER TABLE [dbo].[Expenses] CHECK CONSTRAINT [CH_SummE]
GO
ALTER TABLE [dbo].[Income]  WITH CHECK ADD  CONSTRAINT [CH_SummI] CHECK  (([SummI]>(0)))
GO
ALTER TABLE [dbo].[Income] CHECK CONSTRAINT [CH_SummI]
GO
