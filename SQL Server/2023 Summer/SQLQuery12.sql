select OPID,OPNAME,OPACID,ACCN,OPOWID,USERNAME,TERRITORY,OPCRDA,OPSTAT
from SDM.SFA.DBO.OPP01 INNER JOIN SDM.SFA.DBO.ACC01 ON OPACID=ACID
INNER JOIN SDM.SFA.DBO.USERTABLE ON OPOWID=USERID
WHERE OPCRDA >= '2023-01-01'
AND (OPNAME LIKE '%视觉%'or
     OPNAME LIKE '%检查%'or
	 OPNAME LIKE '%检测%'or
	 OPNAME LIKE '%FH%')

--对象：23年1月1日创建的项目
--筛选条件：项目名称中包含“视觉”or“检查”or “检测”or “FH“
--导出字段：客户ID，客户名，项目ID，项目名，项目担当，担当所在部门，创建时间，项目状态
