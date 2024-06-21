SELECT [GLANI] as 帐号
      ,[GLMCU] as 部门
	  ,[GLDCT] as 单据类型
	  ,[GLJELN] as 行号
      ,[GLDOC] as 单据号
      ,[GLKCO] as 公司
	  ,dbo.cjulian(GLDGJ) as 总帐日期
	  ,[GLEXA] as 说明
      ,[GLAA]/100 as 分类帐类型1金额
	  ,SDLITM as ITEM_ID 
	  ,abalph as CUSTOMER_NAME
	  ,SDVR01 as CUTOMER_INV
	  ,SDUORG as quantity
	  ,SDUNCS/10000 as unitprice
FROM [OEZDW].[dbo].[F0911] S1 inner join
     [OEZDW].[dbo].[F42119] S3 on gldoc=sddoc left outer join
     [OEZDW].[dbo].[F0101] S2  on sdan8=aban8
WHERE  GLOBJ=6051
   AND GLSUB IN ('0308','0106')
   AND GLLT='AA'
   AND DATEPART(YY, dbo.cjulian(sdaddj))*100+DATEPART(MM, dbo.cjulian(sdaddj))=
       DATEPART(YY,(DATEADD(MM,-1,GETDATE())))*100+DATEPART(MM,(DATEADD(MM,-1,GETDATE())))
	 