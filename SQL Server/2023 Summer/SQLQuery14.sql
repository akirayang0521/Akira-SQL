/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [LineID],[填写日期],[FACTORY],t1.[TYPE],[POSLIPNo],t1.[ITEM],[DESC]
	  ,[GRN_Date]
	  ,[Last_Ex_Fact_Date]
  FROM [TEST1].[dbo].[GRN20230627] t1
  left JOIN (select max(GRN_Date) as GRN_Date,SLIPNO,ITEM 
			 from(
				SELECT GRN_Date,SLIPNO,ITEM
				FROM [SDM].[dbo].[FACT_GRN_DETAIL_receiptFY21]
				union all
				SELECT GRN_Date,SLIPNO,ITEM
				FROM [SDM].[dbo].[FACT_GRN_DETAIL_receiptFY22]
				union all
				SELECT GRN_Date,SLIPNO,ITEM
				FROM [SDM].[dbo].[FACT_GRN_DETAIL]
				) tt1
			 group by SLIPNO,ITEM
			 ) t2 
  ON t1.[POSLIPNo]=t2.[SLIPNO] and t1.[ITEM]=t2.[ITEM]
  left join (select max([Last_Ex_Fact_Date]) as [Last_Ex_Fact_Date],SLIPNO,ITEM
			 from [SDM].[dbo].[FACT_PO_INQUERY_REPORT]
			 group by SLIPNO,ITEM
			 ) t3
  on t1.[POSLIPNo]=t3.[SLIPNO] and t1.[ITEM]=t3.[ITEM]
  order by LineID