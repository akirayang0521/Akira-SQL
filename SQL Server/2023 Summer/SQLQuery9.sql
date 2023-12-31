/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [SLIP_NO]
      ,[ITEM_DES]
	  ,[ITEM_ID]
      ,[QUANTITY]
      ,[EXT_AMT]
      ,[UNIT_COST]*[QUANTITY] AS [COST]
      ,[SHIPPED_DATE]
	  ,SDLOTN
  FROM [SDM].[dbo].[FACT_SALESDETAIL_HISTORY_BP]
  inner join RF42119
  on COMPANY_ID = sdkcoo and ORDER_NO = sddoco and ORDER_TYPE = sddcto and LINE_ID=sdlnid
  WHERE SHIPPED_DATE between '2022-01-01'and '2023-03-31'
    AND LEFT(SDLOTN,8)<=20211231