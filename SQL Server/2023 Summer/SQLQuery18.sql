SELECT [CUSTOMER_NAME]--客户名称
	  ,[sold_to]--JDE CODE
	  ,[section]--所属营业部门
	  ,[section_id]--BU
	  ,[TRANS_CURRENCY_ID]--原币种
	  ,[QUANTITY]
      ,[UNIT_PRICE]
	  ,[QUANTITY]*[UNIT_PRICE] AS AMT--销售额（USD）
      ,[FOREIGN_UNIT_PRICE]
	  ,[FOREIGN_AMT] as FOREIGN_AMT--销售额（原币）
      ,[UNIT_COST]*0.158 as UNIT_COST
	  ,[SHIPPED_DATE]--销售确认日期
  FROM [SDM].[dbo].[FACT_SALESDETAIL_HISTORY_BP]
  where company_id='00280' and SHIPPED_DATE between '2022-04-01'and '2023-03-31'
  order by [CUSTOMER_NAME]