
CREATE NONCLUSTERED INDEX [NCIDX_MplDailyServicingTapeReporting_FileNameRportDateMPLAcctId] ON [dbo].[MplDailyServicingTapeReporting]
(
                [FileName] ASC,
                [ReportDate] ASC,
                [MPLAcctId]
)WITH (maxdop=4, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = on, DROP_EXISTING = OFF, ONLINE = on, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

