USE [DBDinoM]
GO
/****** Object:  StoredProcedure [dbo].[sp_Mam_TA001]    Script Date: 15/12/2019 05:26:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--drop procedure sp_Mam_TY004
ALTER PROCEDURE [dbo].[sp_Mam_TA001] (@tipo int=-1,@aanumi int=-1,@aata2dep int=-1,@aata2depVenta int=-1,@aadesc nvarchar(50)=''
,@aadir nvarchar(50)='',@aatelf nvarchar(30)='',@aalat decimal(18,14)=0,@aalong decimal(18,14)=0,@aaimg nvarchar(50)='',@aauact nvarchar(10)='')
AS
BEGIN
	DECLARE @newHora nvarchar(5)
	set @newHora=CONCAT(DATEPART(HOUR,GETDATE()),':',DATEPART(MINUTE,GETDATE()))
	declare @numi int
	DECLARE @newFecha date
	set @newFecha=GETDATE()

	IF @tipo=-1 --ELIMINAR REGISTRO
	BEGIN
		BEGIN TRY 
			DELETE from TA001   where aanumi =@aanumi
         	select @aanumi as newNumi  --Consultar que hace newNumi
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),-1,@newFecha,@newHora,@aauact)
		END CATCH
	END

	IF @tipo=1 --NUEVO REGISTRO
	BEGIN
		BEGIN TRY 
			set @aanumi=IIF((select COUNT(aanumi) from TA001)=0,0,(select MAX(aanumi) from TA001))+1
			INSERT INTO TA001  VALUES(@aanumi ,@aata2dep,@aata2depVenta,@aadesc ,@aadir ,@aatelf ,@aalat ,@aalong,@aaimg ,@newFecha,@newHora,@aauact)
			select @aanumi  as newNumi
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),1,@newFecha,@newHora,@aauact)
		END CATCH
	END
	
	IF @tipo=2--MODIFICACION
	BEGIN
		BEGIN TRY 
			UPDATE TA001 set aabdes =@aadesc ,aadir =@aadir ,aatel =@aatelf ,aalat =@aalat ,aalong =@aalong ,aaimg=@aaimg ,
			aata2dep =@aata2dep  ,aata2depVenta =@aata2depVenta,
			aafact =@newFecha ,aahact =@newHora ,aauact =@aauact 
					 Where aanumi  = @aanumi
				select @aanumi as newNumi
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),2,@newFecha,@newHora,@aauact)
		END CATCH
	END

	IF @tipo=3 --MOSTRAR TODOS
	BEGIN
		BEGIN TRY
	select a.aanumi ,a.aabdes ,a.aadir ,a.aatel ,a.aalat ,a.aalong ,a.aaimg,aata2dep,b.abdesc as deposito,isnull(aata2depVenta,0)as aata2depVenta  ,a.aafact ,a.aahact ,a.aauact 
	from TA001 as a inner join TA002 as b on b.abnumi =a.aata2dep 
	order by a.aanumi asc
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@aauact)
		END CATCH

END


IF @tipo=4 --MOSTRAR TODOS
	BEGIN
		BEGIN TRY
	select a.abnumi ,a.abdesc  
	from TA002 as a
	order by a.abnumi asc
		END TRY
		BEGIN CATCH
			INSERT INTO TB001 (banum,baproc,balinea,bamensaje,batipo,bafact,bahact,bauact)
				   VALUES(ERROR_NUMBER(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),3,@newFecha,@newHora,@aauact)
		END CATCH

END
End


