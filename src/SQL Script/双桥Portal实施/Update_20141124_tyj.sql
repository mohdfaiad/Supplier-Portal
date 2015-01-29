alter table SCM_FlowMstr add IsAutoAsnConfirm bit default(0) not null
go
alter table SCM_FlowMstr add AsnConfirmMoveType varchar(50) 
go
alter table SCM_FlowMstr add CancelAsnConfirmMoveType varchar(50) 
go
alter table SCM_FlowMstr add IsAsnConfirmCreateDN bit default(0)  not null
go 
alter table SCM_FlowMstr add ShipPlant varchar(50) 
go 
alter table SCM_FlowDet add ShipLocation varchar(50) 
go 
