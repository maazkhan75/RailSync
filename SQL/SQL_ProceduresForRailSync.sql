
--------PROCEDURE FOR SIGNUP FUNCTIONALITY-------
CREATE PROCEDURE CreateUser 
	@UserName nvarchar(255),
	@CNIC nvarchar(255),
	@Password nvarchar(255),
	@PhoneNo nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

	-- Check if the user already exists
	IF EXISTS (SELECT 1 FROM [User] WHERE CNIC=@CNIC)
	BEGIN
		-- User already exists, return an error message
		RAISERROR ('User already exists!', 16, 1);
		RETURN -1;
	END

	-- Insert the new user into the User table
	INSERT INTO [User] ([Id], [UserName], [Password],[CNIC],[PhoneNo])
	VALUES(NEWID(), @UserName, @Password,@CNIC,@PhoneNo);

END

--------PROCEDURE FOR LOGIN FUNCTIONALITY-------

CREATE PROCEDURE AuthenticateUser 
	@CNIC nvarchar(255),
	@Password nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

	-- Check if the CNIC and password combination exists
	IF EXISTS (SELECT 1 FROM [User] WHERE  CNIC = @CNIC AND  Password = @Password)
	BEGIN
		-- User account found, return a success message
		 SELECT ID, UserName FROM [User] WHERE CNIC = @CNIC;
	END
	ELSE
	BEGIN
		-- Return error message
		RAISERROR ('User account not found!', 16, 1);
		RETURN -1;
	END

END

--------------------------------------------------------------------------------------------------------


--------PROCEDURE FOR SHOW PROFILE FUNCTIONALITY-------

CREATE PROCEDURE GetUserCredentials
	@CNIC nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

	 SELECT * FROM [User] WHERE CNIC = @CNIC;
END


--------PROCEDURE FOR UPDATE PROFILE FUNCTIONALITY-------
CREATE PROCEDURE UpdateUser 
	@CNIC nvarchar(255),
	@UserName nvarchar(255),
	@Password nvarchar(255),
	@PhoneNo nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

		 UPDATE [User]
		 SET UserName=@UserName,[Password]=@Password,PhoneNo=@PhoneNo
		 WHERE CNIC=@CNIC
END

--------PROCEDURE FOR SHOWING BOOKED TICKETS OF USER-------
CREATE PROCEDURE ShowBookedTickets
	@UserId nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [Ticket] WHERE  UserId = @UserId)
	BEGIN
		SELECT * FROM [Ticket] WHERE  UserId = @UserId
	END
	ELSE
	BEGIN
		-- Return error message if no ticket of user found
		RAISERROR ('no ticket of user found!', 16, 1);
		RETURN -1;
	END
END



--------PROCEDURE FOR CANCEL TICKET OF USER-------
CREATE PROCEDURE CancelTicket
	@UserId nvarchar(255),
AS 
BEGIN	
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [Ticket] WHERE  UserId = @UserId)
	BEGIN
	
		DELETE FROM [Ticket] WHERE  UserId = @UserId
	END
	ELSE
	BEGIN
		-- Return error message if no ticket of user found
		RAISERROR ('no ticket of user found!', 16, 1);
		RETURN -1;
	END
END


---------------Procedure to Search Train recursively-=----------------
USE [afaqkhaliq_SampleDB]
GO
/****** Object:  StoredProcedure [dbo].[SearchTrainWithStops]    Script Date: 22-04-2024 05:32:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


USE [afaqkhaliq_SampleDB]
GO
/****** Object:  StoredProcedure [dbo].[SearchTrainWithStops]    Script Date: 25-04-2024 03:01:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[SearchTrainWithStops] @Search_from_Station nvarchar(30),@Search_to_Station nvarchar(30), @SearchDate datetime

as
WITH  TrainRoute AS (
    -- Base case: 
    SELECT
        T.TrainId,
        Tr.TrackId,
        Tr.Station1Id AS fromStation,
        Tr.Station2Id AS toStation
    FROM
        [Train] AS T
    JOIN
        [Route] AS R ON R.TrainId = T.TrainId
    JOIN
        [Tracks] AS Tr ON Tr.TrackId = R.TrackId
    JOIN
        Fare AS F ON F.TrackId = Tr.TrackId
    WHERE
        Tr.Station1Id = (SELECT StationId FROM Station WHERE StationName = @Search_from_Station)

    UNION ALL

    -- Recursive step: select the next train route
    SELECT
        T.TrainId,
        Tr.TrackId,
        Tr.Station1Id AS fromStation,
        Tr.Station2Id AS toStation
    FROM
        [Train] AS T
    JOIN
        [Route] AS R ON R.TrainId = T.TrainId
    JOIN
        [Tracks] AS Tr ON Tr.TrackId = R.TrackId
    JOIN
        Fare AS F ON F.TrackId = Tr.TrackId
    JOIN
        TrainRoute AS PrevRoute ON PrevRoute.toStation = Tr.Station1Id
    WHERE
        Tr.Station1Id <> (SELECT StationId FROM Station WHERE StationName = @Search_to_Station)
)
-- Select the final train route
select T.TrainId,T.UpDownStatus as UPStatus ,CTEtable.TrackId as TrackId,(select StationName from Station where StationId=fromStation) as DeptStation,((select StationName from Station where StationId=toStation)) as ArrivalStation,DeptTime,ArrivalTime,Economy,BusinessClass,FirstClass
FROM TrainRoute as CTEtable
join [Train] as T on T.TrainId=CTEtable.TrainId
join [Route] as R
on R.TrainId=CTEtable.TrainId
join Fare as F on F.TrackId=CTEtable.TrackId
AND CONVERT(date, R.ArrivalTime) = CONVERT(date, @SearchDate)



[SearchTrainWithStops]  'Karachi','Islamabad','2024-04-16'
-- Select the final train route
select T.TrainId,T.UpDownStatus as UPStatus ,fromStation as DeptStation,toStation as ArrivalStation,DeptTime,ArrivalTime,Economy,BusinessClass,FirstClass
FROM TrainRoute as CTEtable
join [Train] as T on T.TrainId=CTEtable.TrainId
join [Route] as R
on R.TrainId=CTEtable.TrainId
join Fare as F on F.TrackId=CTEtable.TrackId
AND CONVERT(date, R.ArrivalTime) = CONVERT(date, @SearchDate)


---------------------Procedure to Search non Stops----------------------
ALTER PROCEDURE [dbo].[SearchForTrains] @fromStation nvarchar(30), @toStation nvarchar(30), @SearchDate datetime
as
select T.TrainId,Tr.TrackId as TrackId,T.UpDownStatus as UPStatus ,@fromStation as DeptStation,@toStation as ArrivalStation,DeptTime,ArrivalTime,Economy,BusinessClass,FirstClass
from [Train] as T
join [Route] as R
on R.TrainId=T.TrainId
join [Tracks] as Tr
on Tr.TrackId=R.TrackId
join Fare as F on F.TrackId=Tr.TrackId
where Tr.Station1Id=(select StationId from Station where StationName=@fromStation )
and Tr.Station2Id=(select StationId from Station where StationName=@toStation )
AND CONVERT(date, R.ArrivalTime) = CONVERT(date, @SearchDate)
-------------------Proceduure to getdetails about seats-----------------------------
ALTER Procedure [dbo].[GetTicketInfo] @FoundCarriage nvarchar(30), @FoundSeat  int, @TrainId nvarchar(30), @TrackId nvarchar(30)
as
select @FoundCarriage as CarriageID,@FoundSeat as SeatNo,@TrainId as TrainId, t.Station1Id as DeptStaion, t.Station2Id as ArrivalStation, r.ArrivalTime, r.DeptTime,F.Economy,F.BusinessClass,F.FirstClass
from Tracks as t
join [Route] as r on r.TrackId=@TrackId and r.TrainId=@TrainId
join Fare as F on F.TrackId=@TrackId
where t.TrackId=@TrackId

---------------procdure to search fot available trains----------------------------------
alter PROCEDURE [dbo].[BookTicket] @TrainId nvarchar(30), @TrackId nvarchar(30), @Class nvarchar(30)
as
select top 1 s.SeatNo,c.CarriageId,T.TrainId
from [Train] as T
join [Route] as R
on R.TrainId=T.TrainId
join [Tracks] as Tr
on Tr.TrackId=R.TrackId
join Fare as F on F.TrackId=Tr.TrackId
join Carriage as c on c.TrainId=T.TrainId
join Seat as s on s.TrainID=T.TrainId
where c.Type=@Class and s.BookingStatus is  Null
-----------------------;---------

create trigger Addpayment on Ticket
as
after insert
declare @CNIC nvarchar(255)
declare @TicketId nvarchar(255)
declare @TrackId nvarchar(255)
declare @CarriageId nvarchar(255)
declare @price int
declare @type char
select @CNIC=CNIC,@TicketId=TicketId,@CarriageId=CarriageId,@TrackId=TrackId from inserted
select @type=[Type] from Carriage where CarraigeId=@CarriageId
if (type='B')
begin
select @price=select BussinessClass from Fare where TrackId= @TrackId
end
if (type='E')
begin
select @price=select Economy from Fare where TrackId= @TrackId
end
if (type='F')
begin
select @price=select FirstClass from Fare where TrackId= @TrackId
end
insert into Payment
values(@TicketId,@CNIC,@Price,NULL)














--************************** (TESTING AREA) **************************

CreateUser 'maazkhan75','3520297089087','password1965','03204553255'

drop proc CreateUser

INSERT INTO [User] ([Id], [UserName], [Password],[CNIC],[PhoneNo])
VALUES(NEWID(), awais, awais123,1352049128298,03239292982);

delete from [User]
where UserName='user17'
SELECT * FROM [User]
GO

truncate table [User]  --we have to remove one by one 

drop proc AuthenticateUser

exec ShowUser '3520297089087'

UpdateUser '3520297089087','m maaz khan','mypass123','03204553255'

INSERT INTO [Ticket] ([TicketId], [UserId],[SeatNo],[StartingStation],[EndingStation],[date])
VALUES(NEWID(),'0CD8799B-6898-4682-8C22-75A6C7224DA0',1,'KHI','LHR','2025-3-13')

SELECT * FROM [Ticket]

ShowBookedTickets '0CD8799B-6898-4682-8C22-75A6C7224DA0'

update  [Ticket]
set date_and_time='2024-2-1 10:13:02'
where TicketId='F8553E69-5A65-4EA3-AFFE-A7C8CEB704AA'

update  [Ticket]
set Date_and_Time='2025-2-1 20:03:12'
where TicketId='8FDD6A4D-938B-4871-88AA-DC1F7B0D8A1D'


alter table [Ticket] drop  column date
alter table [ticket] add  Date_and_Time DATETIME


