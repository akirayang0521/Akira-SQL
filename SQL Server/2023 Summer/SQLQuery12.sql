select OPID,OPNAME,OPACID,ACCN,OPOWID,USERNAME,TERRITORY,OPCRDA,OPSTAT
from SDM.SFA.DBO.OPP01 INNER JOIN SDM.SFA.DBO.ACC01 ON OPACID=ACID
INNER JOIN SDM.SFA.DBO.USERTABLE ON OPOWID=USERID
WHERE OPCRDA >= '2023-01-01'
AND (OPNAME LIKE '%�Ӿ�%'or
     OPNAME LIKE '%���%'or
	 OPNAME LIKE '%���%'or
	 OPNAME LIKE '%FH%')

--����23��1��1�մ�������Ŀ
--ɸѡ��������Ŀ�����а������Ӿ���or����顱or ����⡱or ��FH��
--�����ֶΣ��ͻ�ID���ͻ�������ĿID����Ŀ������Ŀ�������������ڲ��ţ�����ʱ�䣬��Ŀ״̬
