-------------------����ѯ��λ�̵��-----------------------
select LocTo,Item,Item,OpRef from (select ta.*,case when isnull(tb.OpRef,'')='' then case when LocTo='2400L' then 'AA800' when LocTo='2300L' then 'CD800' when LocTo= '2700L' then 'DZ900' else '' end else OpRef end as OpRef 
                                   from (select distinct mst.LocTo,Item 
								         from SCM_FlowDet as det left join SCM_FlowMstr as mst on det.Flow=mst.Code 
										 where Flow in (select flow 
													    from SCM_FlowStrategy where Strategy=3)) as ta 
														left join (select Item,OpRef, case when isnull(Location,'')='' then case when  LEFT(opref,1)='A' then '2400L'  when LEFT(opref,1)='C' then '2300L' when LEFT(opref,1)='T' then '2700L' else '' end  else location end as location 
																   from (select Item,tt.OpRef,location 
																	     from (select distinct Item,OpRef 
																			   from SCM_OpRefBalance )as tt 
																			   left join (select distinct Location,OpRef 
																						  from dbo.PRD_RoutingDet) as ttt on tt.OpRef=ttt.OpRef
										                                 ) as tmp
										                           ) as tb on ta.Item=tb.Item and ta.LocTo=tb.location
                                   )tt where LocTo in ('2400L','2300L','2700L')
--AD=2400L C=2300L T=2700L
-------------------����ѯ��λ�̵��-----------------------


-------------------����ѯ���ر�δ�رյĳ�������������Ҫ����-----------------------
--Ҫ����״̬
	--Create = 0,	//����
	--Submit = 1,	//�ͷ�
	--InProcess = 2,//ִ����
	--Complete = 3,	//��ɣ�����
	--Close = 4,	//�ر�
	--Cancel = 5	//ȡ��
--Ҫ��������
	--NA = 0,        //�����ֹ����Ժ�����
	--Manual = 1,    //�ֹ�
	--KB = 2,        //���ӿ���
	--JIT = 3,       //JIT
	--SEQ = 4,       //����
	--ANDON = 7,     //����
	--TRIAL = 8,     //����
	--SPARTPART = 9,  //����
	--REPAIR = 10,     //����
	--CKD = 11,    //CKD
	--Semi = 12,      //���Ƽ�
--��ѯδ�رյĳ�������������Ҫ����
select * from ORD_OrderMstr_1 where Status not in (4, 5) --and OrderStrategy not in (8,9,10,11,12)
select * from ORD_OrderMstr_2 where Status not in (4, 5) --and OrderStrategy not in (8,9,10,11,12)
--select OrderStrategy, COUNT(1) from ORD_OrderMstr_1 where Status not in (4, 5) and OrderStrategy not in (8,9,10,11,12) group by OrderStrategy
--select OrderStrategy, COUNT(1) from ORD_OrderMstr_2 where Status not in (4, 5) and OrderStrategy not in (8,9,10,11,12) group by OrderStrategy

--�ر�δ�رյĳ�������������Ҫ����
--��Ϊ�ر�����Ҫ������ԭ���Ǳ������ֱ��������ϵ������ǻ������������ȱ�� 20140628
update ORD_OrderMstr_1 set Status = 4, CloseUser = 1, CloseUserNm = 'su', CloseDate = GETDATE(), LastModifyUser = 1, LastModifyUserNm = 'su', LastModifyDate = GETDATE() where Status not in (4, 5) --and OrderStrategy not in (8,9,10,11,12)
update ORD_OrderMstr_2 set Status = 4, CloseUser = 1, CloseUserNm = 'su', CloseDate = GETDATE(), LastModifyUser = 1, LastModifyUserNm = 'su', LastModifyDate = GETDATE() where Status not in (4, 5) --and OrderStrategy not in (8,9,10,11,12)
-------------------����ѯ���ر�δ�رյĳ����������ϵ�����Ҫ����-----------------------

--��ѯ����δ�깤����
select mstr.OrderNo, mstr.ExtOrderNo, det.Item, det.ItemDesc, (det.OrderQty - det.RecQty) 
from ORD_OrderDet_4 as det inner join ORD_OrderMstr_4 as mstr on det.OrderNo = mstr.OrderNo
where mstr.OrderNo in (
select OrderNo from ORD_OrderMstr_4 where Flow = 'BP01' and Status not in (4, 5)
)
--�رձ���������
update ORD_OrderMstr_4 set Status = 4, CloseUser = 1, CloseUserNm = 'su', CloseDate = GETDATE(), LastModifyUser = 1, LastModifyUserNm = 'su', LastModifyDate = GETDATE()
where OrderNo in (
select OrderNo from ORD_OrderMstr_4 where Flow = 'BP01' and Status not in (4, 5)
)

-------------------����ѯ���ر�δ�رյķ�����������������Ҫ�������������⣩-----------------------
----��ѯδ�رյı�����������
--select * from ORD_OrderMstr_4 where Status not in (4, 5) and ProdLineType not in (1,2,3,4,9) and Flow = 'BP01'

----��ѯ��Ҫ�رյı���Ҫ�������ɹ���
--select * from ORD_OrderMstr_1 as m1
--inner join CUST_ManualGenOrderTrace as map on m1.OrderNo = map.OrderNo
--inner join ORD_OrderMstr_4 as m4 on m4.OrderNo = map.ProdOrderNo
--where m1.Status not in (4, 5) and m1.OrderStrategy = 9  --δ�رյı���Ҫ�������ɹ���
--and m4.Status in (4, 5)  and m4.Flow = 'BP01' --�ѹرյı���������

----��ѯ��Ҫ�رյı���Ҫ�������ƿ⣩
--select * from ORD_OrderMstr_2 as m1
--inner join CUST_ManualGenOrderTrace as map on m1.OrderNo = map.OrderNo
--inner join ORD_OrderMstr_4 as m4 on m4.OrderNo = map.ProdOrderNo
--where m1.Status not in (4, 5) and m1.OrderStrategy = 9  --δ�رյı���Ҫ�������ɹ���
--and m4.Status in (4, 5)  and m4.Flow = 'BP01' --δ�رյı���������

----ֱ����Ӧ����Ҫ������Ҫ����
--select m1.* from ORD_OrderMstr_1 as m1
--inner join CUST_ManualGenOrderTrace as map on m1.OrderNo = map.OrderNo
--inner join ORD_OrderMstr_4 as m4 on m4.OrderNo = map.ProdOrderNo
--where m1.Status not in (4, 5) and m1.OrderStrategy = 9  --δ�رյı���Ҫ�������ɹ���
--and m4.Status not in (4, 5)  and m4.Flow = 'BP01' --δ�رյı���������

----WMS��Ҫ������Ҫ����
--select m2.* from ORD_OrderMstr_2 as m2
--inner join CUST_ManualGenOrderTrace as map on m2.OrderNo = map.OrderNo
--inner join ORD_OrderMstr_4 as m4 on m4.OrderNo = map.ProdOrderNo
--where m2.Status not in (4, 5) and m2.OrderStrategy = 9  --δ�رյı���Ҫ�������ɹ���
--and m2.PartyFrom in ('LOC', 'SQC')   --��WMSҪ��
--and m4.Status not in (4, 5)  and m4.Flow = 'BP01' --δ�رյı���������

----�ر�δ�رյķ����������������вɹ�Ҫ�������������⣩
--update ORD_OrderMstr_1 set Status = 4, CloseUser = 1, CloseUserNm = 'su', CloseDate = GETDATE(), LastModifyUser = 1, LastModifyUserNm = 'su', LastModifyDate = GETDATE() 
--where Status not in (4, 5) and OrderStrategy in (8,9,10,11,12)
--and OrderNo not in (select m1.OrderNo from ORD_OrderMstr_1 as m1
--inner join CUST_ManualGenOrderTrace as map on m1.OrderNo = map.OrderNo
--inner join ORD_OrderMstr_4 as m4 on m4.OrderNo = map.ProdOrderNo
--where m1.Status not in (4, 5) and m1.OrderStrategy = 9  --δ�رյı���Ҫ�������ɹ���
--and m4.Status not in (4, 5)  and m4.Flow = 'BP01' --δ�رյı���������
--)

----�ر�δ�رյķ������������������ƿ�Ҫ�������������⣩
--update ORD_OrderMstr_2 set Status = 4, CloseUser = 1, CloseUserNm = 'su', CloseDate = GETDATE(), LastModifyUser = 1, LastModifyUserNm = 'su', LastModifyDate = GETDATE() 
--where Status not in (4, 5) and OrderStrategy in (8,9,10,11,12)
--and OrderNo not in (select m2.OrderNo from ORD_OrderMstr_2 as m2
--inner join CUST_ManualGenOrderTrace as map on m2.OrderNo = map.OrderNo
--inner join ORD_OrderMstr_4 as m4 on m4.OrderNo = map.ProdOrderNo
--where m2.Status not in (4, 5) and m2.OrderStrategy = 9  --δ�رյı���Ҫ�������ɹ���
----and m2.PartyFrom in ('LOC', 'SQC')   --��WMSҪ�����ڲ��ֿ��ƿ��Ҫ����ҲҪ��������ע�͵��������
--and m4.Status not in (4, 5)  and m4.Flow = 'BP01' --�ѹرյı���������
--)
-------------------����ѯ���ر�δ�رյķ�����������������Ҫ�������������⣩-----------------------




-------------------��ɾ��δ���ߵ�����������-----------------------
--select OrderNo into #tempOrderNo from ORD_OrderMstr_4 
--where TraceCode in (select distinct TraceCode from ORD_OrderMstr_4 where ProdLineType in (1,2,3,4) and Status not in (3,4,5))

----�����ЩҪɾ���������Ƿ����û���깤
--select * from ORD_OrderMstr_4 where OrderNo in (select OrderNo from #tempOrderNo) and Status <> 1
--delete from CUST_CabOut where OrderNo in (select OrderNo from #tempOrderNo)
--delete from ORD_OrderItemTraceResult where OrderNo in (select OrderNo from #tempOrderNo)
--delete from ORD_OrderItemTrace where OrderNo in (select OrderNo from #tempOrderNo)
--delete from ORD_OrderOp where OrderNo in (select OrderNo from #tempOrderNo)
--delete from ORD_OrderBomDet where OrderNo in (select OrderNo from #tempOrderNo)
--delete from ORD_OrderSeq where OrderNo in (select OrderNo from #tempOrderNo)
--delete from ORD_OrderDet_4 where OrderNo in (select OrderNo from #tempOrderNo)
--delete from ORD_OrderMstr_4 where OrderNo in (select OrderNo from #tempOrderNo)
--drop table #tempOrderNo
-------------------��ɾ��δ���ߵ�����������-----------------------



-------------------�����������һ̨���Ÿ���Ϊ�����ߵ����һ̨��-----------------------
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RAA00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RAB00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RAC00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RAD00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RCA00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RCB00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RTX00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine
update sg set PrevOrderNo = seq.OrderNo, PrevSeq = seq.Seq, PrevSubSeq = seq.SubSeq, PrevTraceCode = seq.TraceCode
from SCM_SeqGroup as sg inner join 
(select top 1 ProdLine, OrderNo, Seq, SubSeq, TraceCode from ORD_OrderSeq where ProdLine = 'RJC00' and  OrderNo is not null order by Seq desc, SubSeq desc) as seq
on sg.ProdLine = seq.ProdLine

--select top 1 * from ORD_OrderSeq where ProdLine = 'RAA00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RAA00'
--select top 1 * from ORD_OrderSeq where ProdLine = 'RAB00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RAB00'
--select top 1 * from ORD_OrderSeq where ProdLine = 'RAC00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RAC00'
--select top 1 * from ORD_OrderSeq where ProdLine = 'RAD00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RAD00'
--select top 1 * from ORD_OrderSeq where ProdLine = 'RCA00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RCA00'
--select top 1 * from ORD_OrderSeq where ProdLine = 'RCB00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RCB00'
--select top 1 * from ORD_OrderSeq where ProdLine = 'RTX00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RTX00'
--select top 1 * from ORD_OrderSeq where ProdLine = 'RJC00' and  OrderNo is not null order by Seq desc, SubSeq desc
--select * from SCM_SeqGroup where ProdLine = 'RJC00'
-------------------�����������һ̨���Ÿ���Ϊ�����ߵ����һ̨��-----------------------


-------------------���ر������ʼ쵥-----------------------
update INP_InspectMstr set Status = 2, LastModifyUser = 1, LastModifyUserNm = 'su', LastModifyDate = GETDATE() where Status <> 2
-------------------���ر������ʼ쵥-----------------------



-------------------�����³�ʼ����������-----------------------
delete from PRD_ItemConsume

--���µ��볧������
-------------------�����³�ʼ����������-----------------------



-------------------�����³�ʼ����λ����-----------------------
delete from SCM_OpRefBalance

--���µ��빤λ����
-------------------�����³�ʼ����λ����-----------------------


-------------------��ѭ���ۼ�����ʼ��-----------------------
--ֻ�������̵����Ҫ���
--update SCM_Quota set AccumulateQty = 0, AdjQty = 0
-------------------��ѭ���ۼ�����ʼ��-----------------------


-------------------���鵵�����ƶ����ͽӿ�-----------------------
insert into Sconit5_Arch.dbo.SAP_InvTrans select * from SAP_InvTrans
insert into Sconit5_Arch.dbo.SAP_InvLoc select * from SAP_InvLoc
insert into Sconit5_Arch.dbo.SAP_TransCallBack select * from SAP_TransCallBack
delete from SAP_InvTrans
delete from SAP_InvLoc
delete from SAP_TransCallBack
--truncate table SAP_InvTrans
--truncate table SAP_InvLoc
--truncate table SAP_TransCallBack
go

--set IDENTITY_INSERT SAP_InvLoc on
--insert into SAP_InvLoc(Id, SourceType, SourceId, FRBNR, SGTXT, CreateUser, CreateDate, BWART) select top 1 Id, SourceType, SourceId, FRBNR, SGTXT, CreateUser, CreateDate, BWART from Sconit5_Arch.dbo.SAP_InvLoc order by Id desc
--set IDENTITY_INSERT SAP_InvLoc off
--delete from SAP_InvLoc
--go

--set IDENTITY_INSERT SAP_TransCallBack on
--insert into SAP_TransCallBack(Id, FRBNR, SGTXT, MBLNR, ZEILE, BUDAT, CPUDT, MTYPE, MSTXT, CreateDate) select top 1 Id, FRBNR, SGTXT, MBLNR, ZEILE, BUDAT, CPUDT, MTYPE, MSTXT, CreateDate from Sconit5_Arch.dbo.SAP_TransCallBack order by Id desc
--set IDENTITY_INSERT SAP_TransCallBack off
--delete from SAP_TransCallBack
--go
-------------------���鵵�����ƶ����ͽӿ�-----------------------



-------------------���鵵�������Ϳ����ϸ-----------------------
insert into Sconit5_Arch.dbo.INV_LocTrans select * from INV_LocTrans
insert into Sconit5_Arch.dbo.INV_LocTrans_0 select * from INV_LocTrans_0
insert into Sconit5_Arch.dbo.INV_LocTrans_1 select * from INV_LocTrans_1
insert into Sconit5_Arch.dbo.INV_LocTrans_2 select * from INV_LocTrans_2
insert into Sconit5_Arch.dbo.INV_LocTrans_3 select * from INV_LocTrans_3
insert into Sconit5_Arch.dbo.INV_LocTrans_4 select * from INV_LocTrans_4
insert into Sconit5_Arch.dbo.INV_LocTrans_5 select * from INV_LocTrans_5
insert into Sconit5_Arch.dbo.INV_LocTrans_6 select * from INV_LocTrans_6
insert into Sconit5_Arch.dbo.INV_LocTrans_7 select * from INV_LocTrans_7
insert into Sconit5_Arch.dbo.INV_LocTrans_8 select * from INV_LocTrans_8
insert into Sconit5_Arch.dbo.INV_LocTrans_9 select * from INV_LocTrans_9
insert into Sconit5_Arch.dbo.INV_LocTrans_10 select * from INV_LocTrans_10
insert into Sconit5_Arch.dbo.INV_LocTrans_11 select * from INV_LocTrans_11
insert into Sconit5_Arch.dbo.INV_LocTrans_12 select * from INV_LocTrans_12
insert into Sconit5_Arch.dbo.INV_LocTrans_13 select * from INV_LocTrans_13
insert into Sconit5_Arch.dbo.INV_LocTrans_14 select * from INV_LocTrans_14
insert into Sconit5_Arch.dbo.INV_LocTrans_15 select * from INV_LocTrans_15
insert into Sconit5_Arch.dbo.INV_LocTrans_16 select * from INV_LocTrans_16
insert into Sconit5_Arch.dbo.INV_LocTrans_17 select * from INV_LocTrans_17
insert into Sconit5_Arch.dbo.INV_LocTrans_18 select * from INV_LocTrans_18
insert into Sconit5_Arch.dbo.INV_LocTrans_19 select * from INV_LocTrans_19
insert into Sconit5_Arch.dbo.INV_LocationLotDet select * from INV_LocationLotDet
insert into Sconit5_Arch.dbo.INV_LocationLotDet_0 select * from INV_LocationLotDet_0
insert into Sconit5_Arch.dbo.INV_LocationLotDet_1 select * from INV_LocationLotDet_1
insert into Sconit5_Arch.dbo.INV_LocationLotDet_2 select * from INV_LocationLotDet_2
insert into Sconit5_Arch.dbo.INV_LocationLotDet_3 select * from INV_LocationLotDet_3
insert into Sconit5_Arch.dbo.INV_LocationLotDet_4 select * from INV_LocationLotDet_4
insert into Sconit5_Arch.dbo.INV_LocationLotDet_5 select * from INV_LocationLotDet_5
insert into Sconit5_Arch.dbo.INV_LocationLotDet_6 select * from INV_LocationLotDet_6
insert into Sconit5_Arch.dbo.INV_LocationLotDet_7 select * from INV_LocationLotDet_7
insert into Sconit5_Arch.dbo.INV_LocationLotDet_8 select * from INV_LocationLotDet_8
insert into Sconit5_Arch.dbo.INV_LocationLotDet_9 select * from INV_LocationLotDet_9
insert into Sconit5_Arch.dbo.INV_LocationLotDet_10 select * from INV_LocationLotDet_10
insert into Sconit5_Arch.dbo.INV_LocationLotDet_11 select * from INV_LocationLotDet_11
insert into Sconit5_Arch.dbo.INV_LocationLotDet_12 select * from INV_LocationLotDet_12
insert into Sconit5_Arch.dbo.INV_LocationLotDet_13 select * from INV_LocationLotDet_13
insert into Sconit5_Arch.dbo.INV_LocationLotDet_14 select * from INV_LocationLotDet_14
insert into Sconit5_Arch.dbo.INV_LocationLotDet_15 select * from INV_LocationLotDet_15
insert into Sconit5_Arch.dbo.INV_LocationLotDet_16 select * from INV_LocationLotDet_16
insert into Sconit5_Arch.dbo.INV_LocationLotDet_17 select * from INV_LocationLotDet_17
insert into Sconit5_Arch.dbo.INV_LocationLotDet_18 select * from INV_LocationLotDet_18
insert into Sconit5_Arch.dbo.INV_LocationLotDet_19 select * from INV_LocationLotDet_19
delete from INV_LocTrans
delete from INV_LocTrans_0
delete from INV_LocTrans_1
delete from INV_LocTrans_2
delete from INV_LocTrans_3
delete from INV_LocTrans_4
delete from INV_LocTrans_5
delete from INV_LocTrans_6
delete from INV_LocTrans_7
delete from INV_LocTrans_8
delete from INV_LocTrans_9
delete from INV_LocTrans_10
delete from INV_LocTrans_11
delete from INV_LocTrans_12
delete from INV_LocTrans_13
delete from INV_LocTrans_14
delete from INV_LocTrans_15
delete from INV_LocTrans_16
delete from INV_LocTrans_17
delete from INV_LocTrans_18
delete from INV_LocTrans_19
delete from INV_LocationLotDet
delete from INV_LocationLotDet_0
delete from INV_LocationLotDet_1
delete from INV_LocationLotDet_2
delete from INV_LocationLotDet_3
delete from INV_LocationLotDet_4
delete from INV_LocationLotDet_5
delete from INV_LocationLotDet_6
delete from INV_LocationLotDet_7
delete from INV_LocationLotDet_8
delete from INV_LocationLotDet_9
delete from INV_LocationLotDet_10
delete from INV_LocationLotDet_11
delete from INV_LocationLotDet_12
delete from INV_LocationLotDet_13
delete from INV_LocationLotDet_14
delete from INV_LocationLotDet_15
delete from INV_LocationLotDet_16
delete from INV_LocationLotDet_17
delete from INV_LocationLotDet_18
delete from INV_LocationLotDet_19
-------------------���鵵�������Ϳ����ϸ-----------------------


-------------------���鵵���ϼ��ۺͼ����-----------------------
--insert into Sconit5_Arch.dbo.BIL_ActBill select * from BIL_ActBill
--insert into Sconit5_Arch.dbo.BIL_PlanBill select * from BIL_PlanBill
--insert into Sconit5_Arch.dbo.BIL_BillTrans select * from BIL_BillTrans
delete from BIL_ActBill
delete from BIL_PlanBill
delete from BIL_BillTrans
-------------------���鵵���ϼ��ۺͼ����-----------------------


-------------------���鵵���ϻس��-----------------------
insert into Sconit5_Arch.dbo.ORD_OrderBackflushDet select * from ORD_OrderBackflushDet
delete from ORD_OrderBackflushDet
-------------------���鵵���ϻس��-----------------------


-------------------���鵵SAP������-----------------------
insert into Sconit5_Arch.dbo.SAP_ProdOpReport select * from SAP_ProdOpReport
insert into Sconit5_Arch.dbo.SAP_CancelProdOpReport select * from SAP_CancelProdOpReport
insert into Sconit5_Arch.dbo.SAP_ProdOpBackflush select * from SAP_ProdOpBackflush
delete from SAP_ProdOpBackflush
delete from SAP_CancelProdOpReport
delete from SAP_ProdOpReport
-------------------���鵵SAP������-----------------------



-------------------���鵵�����ƻ�Э��-----------------------
insert into Sconit5_Arch.dbo.SAP_CRSL select * from SAP_CRSL
insert into Sconit5_Arch.dbo.SAP_CRSLSummary select * from SAP_CRSLSummary
delete from SAP_CRSLSummary
delete from SAP_CRSL
-------------------���鵵�����ƻ�Э��-----------------------



-------------------���鵵�Ѵ�������-----------------------
insert into Sconit5_Arch.dbo.ORD_SeqOrderTrace select * from ORD_SeqOrderTrace
delete from ORD_SeqOrderTrace
-------------------���鵵�Ѵ�������-----------------------


--�������ݿ�
DBCC SHRINKDATABASE(Sconit5, 0)

--�����ؽ������飬���ƽ����һ�к�ִ��
exec USP_Tools_TableIndexRebuildAndReorgnaize



-------------------��Ϊ�˼�����������ʱ������һ̨���߳���ʱ�����Ϊ�̵�����-----------------------
update mstr set StartDate = '2015-1-1'
--select mstr.*
from ORD_OrderMstr_4 as mstr 
inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo
inner join (select ProdLine, Seq / 1000 as Seq, Seq - Seq / 1000 * 1000 as SubSeq
from (select seq.ProdLine, MAX(seq.Seq * 1000 + seq.SubSeq) as Seq from ORD_OrderSeq as seq 
inner join ORD_OrderMstr_4 as mstr on seq.OrderNo = mstr.OrderNo
where mstr.Status not in (0, 1) group by seq.ProdLine) as a) 
as a on seq.ProdLine = a.ProdLine and seq.Seq = a.Seq and seq.SubSeq = a.SubSeq
-------------------��Ϊ�˼�����������ʱ������һ̨���߳���ʱ�����Ϊ�̵�����-----------------------



--delete from ORD_OrderDet_1 where CreateDate > '2014-1-1'
--delete from ORD_OrderDet_2 where CreateDate > '2014-1-1'
--delete from ORD_OrderMstr_1 where CreateDate > '2014-1-1'
--delete from ORD_OrderMstr_2 where CreateDate > '2014-1-1'
--update ORD_OrderBomDet set IsCreateOrder = 0 where CreateDate > '2014-1-1'
--update SCM_FlowStrategy set PreWinTime = '2014-1-1' where PreWinTime is not null
--delete from ORD_OrderOpCPTime

--��ղ��Ե��ϴδ���ʱ��
update SCM_FlowStrategy set PreWinTime = null

--����������֮��
exec USP_LE_RunLeanEngine 1, 'su'