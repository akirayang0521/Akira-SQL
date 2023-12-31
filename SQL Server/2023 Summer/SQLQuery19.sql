/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [ITEM_DES]
	  ,[ITEM_ID]
	  ,[ABBR]
      ,sum([QUANTITY]) as quantity
  FROM [SDM].[dbo].[FACT_SALESDETAIL_ALL_HISTORY_BP] t1
  inner join [SDM].[dbo].[230803ABBR] t2 on t1.[ITEM_ID]=t2.[货号]
  where COMPANY_ID='00200' and ORDER_TYPE='CO' and [SHIPPED_DATE] between '2020-08-01'and '2023-07-31'
  group by [ITEM_DES],[ITEM_ID],[ABBR]
  order by [ITEM_DES]