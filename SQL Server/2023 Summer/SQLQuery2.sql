SELECT [GLANI] as 帐号
      ,[GLMCU] as 部门
	  ,[GLDCT] as 单据类型
	  ,[GLJELN] as 行号
      ,[GLDOC] as 单据号
      ,[GLKCO] as 公司
	  ,dbo.cjulian(GLDGJ) as 总帐日期
	  ,[GLEXA] as 说明
      ,[GLAA]/100 as 分类帐类型1金额
  FROM [OEZDW].[dbo].[F0911]