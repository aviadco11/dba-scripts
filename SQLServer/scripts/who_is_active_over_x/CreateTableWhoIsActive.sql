
USE [DBAUtilities]
GO

/****** Object:  Table [Monitoring].[WhoIsActiveOver5]    Script Date: 9/5/2022 9:40:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Monitoring].[WhoIsActiveOver5](
                [WhoIsActiveOver5_ID] [int] IDENTITY(1,1) NOT NULL,
                [dd hh:mm:ss.mss] [varchar](16) NULL,
                [session_id] [smallint] NOT NULL,
                [login_name] [nvarchar](128) NOT NULL,
                [host_name] [nvarchar](128) NULL,
                [database_name] [nvarchar](128) NULL,
                [collection_time] [datetime] NOT NULL,
                [start_time] [datetime] NOT NULL,
                [sql_text] [xml] NULL,
                [collection_date]  AS (CONVERT([date],[collection_time])) PERSISTED,
                [collection_hour]  AS (datepart(hour,[collection_time])) PERSISTED,
                [blocking_session_id] [int] NULL,
                [program_name] [nvarchar](256) NULL,
                [wait_info] [nvarchar](256) NULL,
                [CPU] [nvarchar](25) NULL,
                [reads] [nvarchar](25) NULL,
                [writes] [nvarchar](25) NULL,
                [physical_reads] [nvarchar](25) NULL,
CONSTRAINT [pk_WhoIsActiveOver5_WhoIsActiveOver5_ID] PRIMARY KEY CLUSTERED 
(
                [WhoIsActiveOver5_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO




