SELECT SDLITM as ITEM_ID
      ,abalph as CUSTOMER_NAME
	  ,SDVR01 as CUTOMER_INV
	  ,SDUORG as quantity
	  ,SDUNCS/10000 as unitprice
  FROM [OEZDW].[dbo].[F42119] S1, [OEZDW].[dbo].[F0101] S2
  WHERE S1.[SDAN8]=S2.[ABAN8]