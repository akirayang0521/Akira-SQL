SELECT [ABBR]
      ,[CUSTOMER_NAME]
      ,sum([EXT_AMT]) as FY22_EXT_AMT
  FROM [SDM].[dbo].[FACT_SALESDETAIL_HISTORY_BP] t1
  inner join [SDM].[dbo].[LU_ITEM] t2
  on t1.ITEM_ID=t2.ITEM_ID
  where SHIPPED_DATE between '2022-04-01'and '2023-03-31'
    and segment_id in ('SCABE','SCABF')
  group by [ABBR],[CUSTOMER_NAME]