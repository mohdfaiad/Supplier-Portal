------------------------------��֤������������+���Ŀ�λ����·����ϸ��Ӧ���ų�û�вɹ����ص�����ϣ�-------------------------------
--Ӧ��·�ߵ����+��λ
select tar.Item, tar.Location from
	--��ȡ�����߱����Ϻ����Ŀ�λ���ų����Ƽ�
	(select distinct Item, Location from LE_OrderBomCPTimeSnapshot where BESKZ <> 'E') as tar
	left join 
	--û�вɹ����ص�����
	(select distinct Item from LOG_SnapshotFlowDet4LeanEngine where ErrorId = 15) as i1
	on tar.Item = i1.Item
	where i1.Item is null
	
except

--����·����ϸ�����+����λ��
(select det.Item, ISNULL(det.LocTo, mstr.LocTo) from SCM_FlowMstr as mstr 
inner join SCM_FlowDet as det on mstr.Code = det.Flow
where mstr.Type in (1, 2)  --�ɹ����ƿ�
union
--ϵͳ���ݹ������·����ϸ�����+����λ��
select Item, LocTo from LE_FlowDetSnapShot where FlowDetId = 0)
 


----------------------------��֤JIT�����Ƿ�����©----------------------------------
select * from LE_FlowDetSnapShot as det 
inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
inner join LE_OrderBomCPTimeSnapshot as bom 
	on det.Item = bom.Item and det.LocTo = bom.Location 
		and bom.CPTime < mstr.ReqTimeTo
where mstr.Strategy = 3 and bom.IsCreateOrder = 0




----------------------------��֤��������+ ��λ�������Ƿ�����Bom����----------------------------------
select bom.Item, bom.OpRef, bom.BomQty, ISNULL(ord.OrderQty, 0) as OrderQty, ISNULL(ord.OpRefConsumeQty, 0) as OpRefConsumeQty
from
--���Ϲ�λ����
(select bom.Item, bom.OpRef, SUM(bom.OrderQty) as BomQty
from LE_FlowDetSnapShot as det 
inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
inner join LE_OrderBomCPTimeSnapshot as bom 
	on det.Item = bom.Item and det.LocTo = bom.Location 
		and bom.CPTime < mstr.ReqTimeTo
group by bom.Item, bom.OpRef) as bom
left join
--�������� + ��λ������
(select det.Item, det.BinTo as OpRef, SUM(det.ReqQty) as ReqQty, SUM(det.OrderQty) as OrderQty, SUM(ISNULL(trace.OpRefConsumeQty, 0)) as OpRefConsumeQty
from VIEW_OrderDet as det 
inner join VIEW_OrderMstr as mstr on det.OrderNo = mstr.OrderNo
left join 
	(select Item, OpRef, SUM(OrgOpRefQty - OpRefQty) as OpRefConsumeQty
	from LOG_VanOrderTrace 
	group by Item, OpRef) as trace on det.Item = trace.Item and det.BinTo = trace.OpRef
where mstr.OrderStrategy = 3
group by det.Item, det.BinTo) as ord on bom.Item = ord.Item and bom.OpRef = ord.OpRef
--Bom���� > �������� + ��λ������
where bom.BomQty <> ISNULL(ord.OrderQty, 0) + ISNULL(ord.OpRefConsumeQty, 0)
--where bom.Item = '5801276239' and bom.OpRef = 'AF050'
