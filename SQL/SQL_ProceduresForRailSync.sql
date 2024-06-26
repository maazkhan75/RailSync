
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
	INSERT INTO [User] ([UserName], [Password],[CNIC],[PhoneNo])
	VALUES(@UserName, @Password, @CNIC, @PhoneNo);

END


--------PROCEDURE FOR SIGNUP FUNCTIONALITY OF ADMIN-------
create PROCEDURE CreateAdmin
	@AdminName nvarchar(255),
	@CNIC nvarchar(255),
	@PIN nvarchar(255),
	@PhoneNo nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

	-- Check if the user already exists
	IF EXISTS (SELECT 1 FROM [Admin] WHERE CNIC=@CNIC)
	BEGIN
		-- Admin already exists, return an error message
		RAISERROR ('Admin already exists!', 16, 1);
		RETURN -1;
	END

	-- Insert the new admin into the admin table
	INSERT INTO [Admin] ([AdminName], [Pin],[CNIC],[PhoneNo])
	VALUES(@AdminName, @PIN, @CNIC, @PhoneNo);

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
		 SELECT UserName FROM [User] WHERE CNIC = @CNIC;
	END
	ELSE
	BEGIN
		-- Return error message
		RAISERROR ('User account not found!', 16, 1);
		RETURN -1;
	END

END

--------------------------------------------------------------------------------------------------------

--------PROCEDURE FOR LOGIN FUNCTIONALITY OF ADMIN-------

CREATE PROCEDURE AuthenticateAdmin 
    @CNIC nvarchar(255),
	@PIN nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

	-- Check if the CNIC and password combination exists
	IF EXISTS (SELECT 1 FROM [Admin] WHERE  CNIC = @CNIC AND  Pin = @PIN)
	BEGIN
		-- User account found, return a success message
		 SELECT AdminName FROM [Admin] WHERE CNIC = @CNIC;
	END
	ELSE
	BEGIN
		-- Return error message
		RAISERROR ('Admin account not found!', 16, 1);
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
CREATE PROCEDURE UpdateProfile 
	@CNIC nvarchar(255),
	@UserName nvarchar(255),
	@PhoneNo nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

		 UPDATE [User]
		 SET UserName=@UserName,PhoneNo=@PhoneNo
		 WHERE CNIC=@CNIC
END

--------PROCEDURE FOR PASSWORD CHANGE FUNCTIONALITY-------
CREATE PROCEDURE ChangePassword 
	@CNIC nvarchar(255),
	@newPassword nvarchar(255)

AS 
BEGIN	
	SET NOCOUNT ON;

		 UPDATE [User]
		 SET Password=@newPassword
		 WHERE CNIC=@CNIC
END


--------PROCEDURE FOR SHOWING BOOKED TICKETS OF USER-------
alter PROCEDURE ShowBookedTickets
	@CNIC nvarchar(255)
AS 
BEGIN	
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [Ticket] WHERE  CNIC = @CNIC)
	BEGIN
		SELECT * FROM [Ticket] as T JOIN [Payment] as P on P.TicketId = T.TicketId 
        JOIN [route] R on R.TrainId=T.TrainId AND R.TrackId=T.trackId where T.CNIC=@CNIC;
    END
	ELSE
	BEGIN
		-- Return error message if no ticket of user found
		RAISERROR ('no ticket of user found!', 16, 1);
		RETURN -1;
	END
END

drop proc ShowBookedTickets

--------PROCEDURE FOR CANCEL TICKET OF USER-------
CREATE PROCEDURE [dbo].[CancelTicket]
	@TicketId int,
    @TrainId nvarchar(255),
    @CarriageId NVARCHAR(255),
    @SeatNo int 

AS 
BEGIN	
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM [Ticket] WHERE  TicketId = @TicketId)
	BEGIN
	
		update [Seat] set BookingStatus=null where SeatNo=@SeatNo and TrainId=@TrainId and CarriageId=@CarriageId;
        update [Payment] set RefundStatus='R' where TicketId=@TicketId   --here only we are updating the refudnStatus to R rest is only frontend level changes not in the backend database
        select 'UNBOOKED SUCCESSFULLY' as ResultMessage
	END
	ELSE
	BEGIN
		-- Return error message if no ticket of user found
		        select 'UNBOOKED UNSUCCESSFULLY' as ResultMessage
	END
END
GO
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
select T.TrainId,T.UpDownStatus as UPStatus ,CTEtable.TrackId as TrackId,(select StationName from Station where StationId=fromStation) as DeptStation,((select StationName from Station where StationId=toStation)) as ArrivalStation,DeptTime,ArrivalTime,Economy,Business,FirstClass
FROM TrainRoute as CTEtable
join [Train] as T on T.TrainId=CTEtable.TrainId
join [Route] as R
on R.TrainId=CTEtable.TrainId
join Fare as F on F.TrackId=CTEtable.TrackId
AND CONVERT(date, R.ArrivalTime) = CONVERT(date, @SearchDate)



[SearchTrainWithStops]  'Karachi','Islamabad','2024-04-16'
-- Select the final train route
select T.TrainId,T.UpDownStatus as UPStatus ,fromStation as DeptStation,toStation as ArrivalStation,DeptTime,ArrivalTime,Economy,Business,FirstClass
FROM TrainRoute as CTEtable
join [Train] as T on T.TrainId=CTEtable.TrainId
join [Route] as R
on R.TrainId=CTEtable.TrainId
join Fare as F on F.TrackId=CTEtable.TrackId
AND CONVERT(date, R.ArrivalTime) = CONVERT(date, @SearchDate)

-----------------Procedure to searchtrainwith one stop--------------
alter procedure [dbo].[SearchTrainWithOneStop] @Search_from_Station nvarchar(30),@Search_to_Station nvarchar(30), @SearchDate datetime
as
with my_cte as (
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
        Tr.Station1Id=(select StationId from Station where Station.StationName=@Search_from_Station) and Tr.Station2Id<> (select StationId from Station where Station.StationName=@Search_to_Station)
),
second_cte as(
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
	JOIN my_cte as PrevRoute on PrevRoute.toStation=Tr.Station1Id
    WHERE
        Tr.Station2Id= (select StationId from Station where Station.StationName=@Search_to_Station)
		)
, union_cte as
(select * from my_cte union select * from second_cte
)
,FinalRoute as(
select U1.TrainId,U1.TrackId,U1.fromStation,U1.toStation
from union_cte as U1, union_cte as U2
where U1.toStation=U2.fromStation
union
select U1.TrainId,U1.TrackId,U1.fromStation,U1.toStation
from union_cte as U1, union_cte as U2
where U1.fromStation=U2.toStation)


select T.TrainId,T.UpDownStatus as UPStatus ,CTEtable.TrackId as TrackId,(select StationName from Station where StationId=fromStation) as DeptStation,(select StationName from Station where StationId=toStation) as ArrivalStation,DeptTime,ArrivalTime,Economy,Business,FirstClass
FROM FinalRoute as CTEtable
join [Route] as R
on R.TrainId=CTEtable.TrainId and R.TrackId=CTEtable.TrackId
join [Train] as T on T.TrainId=R.TrainId 
join Fare as F on F.TrackId=R.TrackId


exec SearchTrainWithOneStop 'Karachi Cannt','Islamabad','2024-08-05'
---------------------Procedure to Search non Stops----------------------
ALTER PROCEDURE [dbo].[SearchForTrains] @fromStation nvarchar(30), @toStation nvarchar(30), @SearchDate datetime
as
select T.TrainId,Tr.TrackId as TrackId,T.UpDownStatus as UPStatus ,@fromStation as DeptStation,@toStation as ArrivalStation,DeptTime,ArrivalTime,Economy,Business,FirstClass
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
select @FoundCarriage as CarriageID, @TrackId as TrackId, @FoundSeat as SeatNo,@TrainId as TrainId, t.Station1Id as DeptStaion, t.Station2Id as ArrivalStation, r.ArrivalTime, r.DeptTime,F.Economy,F.Business,F.FirstClass
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

create trigger [dbo].[Addpayment] on [dbo].[Ticket]
after insert
as
declare @CNIC nvarchar(255)
declare @TicketId nvarchar(255)
declare @TrackId nvarchar(255)
declare @CarriageId nvarchar(255)
declare @price int
declare @type char
select @CNIC=CNIC,@TicketId=TicketId,@CarriageId=CarriageId,@TrackId=TrackId from inserted
select @type=[Type] from Carriage where CarriageId=@CarriageId
if (@type='B')
begin
select @price= Business from Fare where TrackId= @TrackId
end
if (@type='E')
begin
select @price= Economy from Fare where TrackId= @TrackId
end
if (@type='F')
begin
select @price= FirstClass from Fare where TrackId= @TrackId
end
insert into Payment
values(@TicketId,@CNIC,@Price,NULL)

GO
ALTER TABLE [dbo].[Ticket] ENABLE TRIGGER [Addpayment]
GO
















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

INSERT INTO [Ticket] ([TicketId],[CNIC],[SeatNo],[StartingStation],[EndingStation],[date])
VALUES(NEWID(),'0CD8799B-6898-4682-8C22-75A6C7224DA0',1,'KHI','LHR','2025-3-13')

SELECT * FROM [Ticket]

ShowBookedTickets '3520297089087'

update  [Ticket]
set date_and_time='2024-2-1 10:13:02'
where TicketId='F8553E69-5A65-4EA3-AFFE-A7C8CEB704AA'

update  [Ticket]
set Date_and_Time='2025-2-1 20:03:12'
where TicketId='8FDD6A4D-938B-4871-88AA-DC1F7B0D8A1D'


alter table [Ticket] drop  column date
alter table [ticket] add  Date_and_Time DATETIME


--------EditTrain
CREATE PROCEDURE EditTrain
    @TRAINID NVARCHAR(255),
    @DEPARTURESTATION NVARCHAR(255),
    @ARRIVALSTATION NVARCHAR(255),
    @UPDOWNSTATUS CHAR
AS 
BEGIN
    IF EXISTS (SELECT * FROM Train WHERE TrainId = @TRAINID)
    BEGIN
        UPDATE Train 
        SET DeptStation = @DEPARTURESTATION, 
            ArrivalStation = @ARRIVALSTATION, 
            UpDownStatus = @UPDOWNSTATUS 
        WHERE TrainId = @TRAINID;
    END
END

exec EditTrain '206','ISB','QUET','1'

CREATE PROCEDURE AddTrain
    @TRAINID NVARCHAR(255),
    @DEPARTURESTATION NVARCHAR(255),
    @ARRIVALSTATION NVARCHAR(255),
    @UPDOWNSTATUS CHAR
AS 
BEGIN
    IF NOT EXISTS (SELECT * FROM Train WHERE TrainId = @TRAINID)
    BEGIN
        INSERT INTO Train (TrainId, StationName, DeptStation, ArrivalStation)
        VALUES (@TRAINID, @UPDOWNSTATUS, @DEPARTURESTATION, @ARRIVALSTATION);
        SELECT 'TRAIN ADDED SUCCESSFULLY' AS ResultMessage; -- Return success message
    END
    ELSE
    BEGIN
        SELECT 'ID ALREADY EXISTS' AS ResultMessage; -- Return message indicating ID already exists
    END
END


CREATE PROCEDURE AddStation
    @STATIONID NVARCHAR(255),
    @STATIONNAME NVARCHAR(255),
    @STATIONADDRESS NVARCHAR(255)
AS 
BEGIN
    IF NOT EXISTS (SELECT * FROM Station WHERE StationId = @STATIONID)
    BEGIN
        INSERT INTO Station (StationId, StationName, [Address])
        VALUES (@STATIONID, @STATIONNAME, @STATIONADDRESS);
        SELECT 'STATION ADDED SUCCESSFULLY' AS ResultMessage; -- Return success message
    END
    ELSE
    BEGIN
        SELECT 'ID ALREADY EXISTS' AS ResultMessage; -- Return message indicating ID already exists
    END
END


alter PROCEDURE InsertTrack
    @Station1Id NVARCHAR(255),
    @Station2Id NVARCHAR(255),
    @Economy FLOAT,
    @Business float,
    @FirstClass FLOAT
AS 
BEGIN
    if(Not exists(select * from [Tracks] where Station1Id=@Station1Id and Station2Id=@Station2Id))
    BEGIN

    DECLARE @COUNT_NVARCHAR NVARCHAR(255);
    SET @COUNT_NVARCHAR = SUBSTRING(CONVERT(NVARCHAR(255), NEWID()), 1, 10);


   INSERT INTO Tracks (TrackId, Station1Id, Station2Id)
    VALUES (@COUNT_NVARCHAR, @Station1Id, @Station2Id);

    INSERT INTO Fare (TrackId,Economy,Business,FirstClass)
    VALUES (@COUNT_NVARCHAR,@Economy,@Business,@FirstClass)

    select 'TRACK ADDED SUCCESSFULLY' as ResultMessage
    
    END
    ELSE
    BEGIN
        SELECT 'TRACK ALREADY EXISTS' AS ResultMessage;
    END
END;

exec InsertTrack 'PESH','ISL',500,1000,2000
select * from [Tracks]


alter PROCEDURE AddSecurity
    @CrewId NVARCHAR(255),
    @CrewName NVARCHAR(255),
    @Address NVARCHAR(255),
    @DateOfBirth DATE,
    @StationId NVARCHAR(255)
   AS 
BEGIN
    if(not exists(select * from [Crew] where CrewId=@CrewId))
    BEGIN
    INSERT INTO Crew (CrewId,CrewName,[Address],DateOfBirth)
    VALUES (@CrewId, @CrewName, @Address,@DateOfBirth);

    Insert into [Security] (CrewId,StationId) values(@CrewId,@StationId);
    SELECT 'GUARD ADDED SUCCESSFULLY' AS ResultMessage;
    end
    else 
    BEGIN
        SELECT 'GUARD NOT ADDED SUCCESSFULLY' AS ResultMessage;
    END
    end;

exec  AddSecurity '31203412311','Daniel','Lahore,Pakistan','2000-01-01','ISB'

alter PROCEDURE AddPilot
    @CrewId NVARCHAR(255),
    @CrewName NVARCHAR(255),
    @Address NVARCHAR(255),
    @DateOfBirth DATE,
    @TrainId NVARCHAR(255)
   AS 
BEGIN
    if(not exists(select * from [Crew] where CrewId=@CrewId))
    BEGIN
    INSERT INTO Crew (CrewId,CrewName,[Address],DateOfBirth)
    VALUES (@CrewId, @CrewName, @Address,@DateOfBirth);

    Insert into [Pilot] (CrewId,TrainId) values(@CrewId,@TrainId);
    SELECT 'PILOT ADDED SUCCESSFULLY' AS ResultMessage;
    end
    else 
    BEGIN
        SELECT 'PILOT NOT ADDED SUCCESSFULLY' AS ResultMessage;
    END
    end;


CREATE PROCEDURE AddRoute
    @TrainId NVARCHAR(255),
    @TrackId NVARCHAR(255),
    @DepartureTime DATETIME,
    @ArrivalTime DATETIME
AS 
BEGIN
    IF NOT EXISTS (SELECT * FROM [Route] WHERE TrainId = @TrainId AND TrackId = @TrackId)
    BEGIN
        INSERT INTO [Route] (TrainId, TrackId, [DeptTime], ArrivalTime)
        VALUES (@TrainId, @TrackId, @DepartureTime, @ArrivalTime);

        SELECT 'ROUTE ADDED SUCCESSFULLY' AS ResultMessage;
    END
    ELSE
    BEGIN
        SELECT 'ROUTE ALREADY EXISTS' AS ResultMessage;
    END
END;


ALTER PROCEDURE AddCarriage
    @TrainId NVARCHAR(255),
    @CarriageId NVARCHAR(255),
    @Type CHAR,
    @NoOfSeats INT
AS 
BEGIN
    IF NOT EXISTS (SELECT * FROM [Carriage] WHERE CarriageId = @CarriageId )
    BEGIN
        INSERT INTO [Carriage] (TrainId, CarriageId, [Type])
        VALUES (@TrainId, @CarriageId, @Type);
        
        DECLARE @SeatID INT = 1; -- Initialize SeatID

        -- Loop to insert seats
        WHILE @SeatID <= @NoOfSeats
        BEGIN
            INSERT INTO [Seat] (TrainID, CarriageID, SeatNo, BookingStatus)
            VALUES (@TrainId, @CarriageId, @SeatID, NULL);
            SET @SeatID = @SeatID + 1; -- Increment SeatID
        END

        SELECT 'CARRIAGE ADDED SUCCESSFULLY' AS ResultMessage;
    END
    ELSE
    BEGIN
        SELECT 'CARRIAGE ALREADY EXISTS' AS ResultMessage;
    END
END;

select * from [Seat] where CarriageID='222'

CREATE PROCEDURE EditRoute
    @TrainId NVARCHAR(255),
    @TrackId NVARCHAR(255),
    @DepartureTime DATETIME,
    @ArrivalTime DATETIME
AS 
BEGIN
    IF EXISTS (SELECT * FROM [Route] WHERE TrainId = @TrainId AND TrackId = @TrackId)
    BEGIN
        UPDATE [Route]
        SET DeptTime=@DepartureTime, ArrivalTime=@ArrivalTime
        WHERE TrackId = @TrackId and TrainId=@TrainId

        SELECT 'ROUTE UPDATED SUCCESSFULLY' AS ResultMessage;
    END
    ELSE
    BEGIN
        SELECT 'ROUTE DOES NOT EXISTS' AS ResultMessage;
    END
END;





ALTER PROCEDURE EditFare
    @TrackId NVARCHAR(255),
    @Economy FLOAT,
    @Business float,
    @FirstClass FLOAT
AS 
BEGIN
    if( exists(select * from [Fare] where TrackId=@TrackId ))
    BEGIN

    update [Fare] set Economy=@Economy,Business=@Business,FirstClass=@FirstClass 
    where TrackId=@TrackId;
    SELECT 'FARE UPDATED SUCCESSFULLY' AS ResultMessage;
    END
    ELSE
    BEGIN
        SELECT 'FARE NOT EXISTS' AS ResultMessage;
    END
END;

alter PROCEDURE EditSecurity
    @CrewId NVARCHAR(255),
    @CrewName NVARCHAR(255),
    @Address NVARCHAR(255),
    @StationId NVARCHAR(255)
AS 
BEGIN
    if( exists(select * from [Crew] where CrewId=@CrewId ))
    BEGIN

    update [Crew] set CrewName=@CrewName,[Address]=@Address
    where CrewId=@CrewId;
    update [Security] set StationId=@StationId where CrewId=@CrewId;
    SELECT 'CREW UPDATED SUCCESSFULLY' AS ResultMessage;
    END
    ELSE
    BEGIN
        SELECT 'CREW NOT EXISTS' AS ResultMessage;
    END
END;


alter PROCEDURE EditPilot
    @CrewId NVARCHAR(255),
    @CrewName NVARCHAR(255),
    @Address NVARCHAR(255),
    @TrainId NVARCHAR(255)
AS 
BEGIN
    if( exists(select * from [Crew] where CrewId=@CrewId ))
    BEGIN

    update [Crew] set CrewName=@CrewName,[Address]=@Address
    where CrewId=@CrewId;
    update [Pilot] set TrainId=@TrainId where CrewId=@CrewId;
    SELECT 'CREW UPDATED SUCCESSFULLY' AS ResultMessage;
    END
    ELSE
    BEGIN
        SELECT 'CREW NOT EXISTS' AS ResultMessage;
    END
END;

CREATE PROCEDURE EditSeat
    @SeatNo INT,
    @CarriageID NVARCHAR(255),
    @TrainID NVARCHAR(255)
AS 
BEGIN
    DECLARE @Status CHAR;

    IF EXISTS(SELECT BookingStatus FROM [Seat] WHERE TrainID = @TrainID AND CarriageID = @CarriageID AND SeatNo = @SeatNo)
    BEGIN
        SELECT @Status = BookingStatus FROM [Seat] WHERE TrainID = @TrainID AND CarriageID = @CarriageID AND SeatNo = @SeatNo;

        IF (@Status IS NULL)
        BEGIN
            UPDATE [Seat] SET BookingStatus = 'B' 
            WHERE TrainID = @TrainID AND CarriageID = @CarriageID AND SeatNo = @SeatNo;
            SET @Status = 'B';
            SELECT @Status AS BookingStatus, 'BOOKED' AS ResultMessage;
        END
        ELSE
        BEGIN
            UPDATE [Seat] SET BookingStatus = NULL
            WHERE TrainID = @TrainID AND CarriageID = @CarriageID AND SeatNo = @SeatNo;
            SET @Status = NULL;
            SELECT @Status AS BookingStatus, 'UNBOOKED' AS ResultMessage;
        END
    END
    ELSE
    BEGIN
        SELECT 'SEAT DOES NOT EXIST' AS ResultMessage;
    END
END;


alter PROCEDURE DeleteStation
    @StationId NVARCHAR(255)
    AS 
    BEGIN
    if(exists(select * from [Station] where StationId=@StationId))
    BEGIN
    delete [Station] where StationId=@StationId
    SELECT 'Success' AS ResultMessage;
    END
    else 
    begin
        SELECT 'Fail' AS ResultMessage;
    end
    END;

alter TRIGGER DeletingStation
ON [Station]
INSTEAD OF DELETE
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @StationId NVARCHAR(255);
    DECLARE @TrackId NVARCHAR(255);

    SELECT @StationId = deleted.StationId FROM deleted;
    Update [Train] set DeptStation=NULL where DeptStation=@StationId
    Update [Train] set ArrivalStation=NULL where ArrivalStation=@StationId

    WHILE EXISTS (SELECT * FROM [Tracks] WHERE Station1Id = @StationId OR Station2Id = @StationId)
    BEGIN
        SELECT TOP 1 @TrackId = TrackId FROM [Tracks] WHERE Station1Id = @StationId OR Station2Id = @StationId;
        
        
        DELETE FROM [Fare] WHERE TrackId=@TrackId;
        DELETE FROM [Tracks] WHERE TrackId = @TrackId;
        
    END

     DELETE FROM Station WHERE StationId = @StationId
END;


alter PROCEDURE DeleteTrack
    @TrackId NVARCHAR(255)
    AS 
    BEGIN
    if(exists(select * from [Tracks] where TrackId=@TrackId))
    BEGIN
    delete [Tracks] where TrackId=@TrackId
    SELECT 'Success' AS ResultMessage;
    END
    else 
    begin
        SELECT 'Fail' AS ResultMessage;
    end
    END;

create PROCEDURE DeleteRoute
    @TrackId NVARCHAR(255),
    @TrainId NVARCHAR(255)
    AS 
    BEGIN
    if(exists(select * from [Route] where TrackId=@TrackId and @TrainId=TrainId))
    BEGIN
    delete [Route] where TrackId=@TrackId and @TrainId=TrainId;
    SELECT 'Success' AS ResultMessage;
    END
    else 
    begin
        SELECT 'Fail' AS ResultMessage;
    end
    END;


    create PROCEDURE DeleteCrew
    @CrewId NVARCHAR(255)

    AS 
    BEGIN
    if(exists(select * from [Crew] where CrewId=@CrewId ))
    BEGIN
    delete [Crew] where CrewId=@CrewId;
    SELECT 'Success' AS ResultMessage;
    END
    else 
    begin
        SELECT 'Fail' AS ResultMessage;
    end
    END;


    create PROCEDURE DeleteTrain
    @TrainId NVARCHAR(255)

    AS 
    BEGIN
    if(exists(select * from [Train] where TrainId=@TrainId ))
    BEGIN
    delete [Train] where TrainId=@TrainId;
    SELECT 'Success' AS ResultMessage;
    END
    else 
    begin
        SELECT 'Fail' AS ResultMessage;
    end
    END;

    create PROCEDURE DeleteCarriage
    @CarriageId NVARCHAR(255)
    AS 
    BEGIN
    if(exists(select * from [Carriage] where CarriageId=@CarriageId ))
    BEGIN
    delete [Carriage] where CarriageId=@CarriageId;
    SELECT 'Success' AS ResultMessage;
    END
    else 
    begin
        SELECT 'Fail' AS ResultMessage;
    end
    END;
   
 



 



select* FROM Carriage where TrainId='101';

insert into Carriage
values('203','101','F');

CREATE PROCEDURE SearchForCarriage
    @ID nvarchar(255)
AS
BEGIN
    SELECT * FROM Carriage WHERE TrainId = @ID;
END;


EXEC SearchForCarriage @ID='101';

CREATE PROCEDURE SearchForSeats
    @CARRIAGEID nvarchar(255)
AS
BEGIN
    Select * from [Seat] where CarriageID=@CARRIAGEID
END;

EXEC SearchForSeats @CARRIAGEID='202'

 




 SELECT name
FROM sys.objects
WHERE type_desc = 'FOREIGN_KEY_CONSTRAINT'
AND parent_object_id = OBJECT_ID('Payment');

SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTableName,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumnName,
    fk.delete_referential_action_desc AS OnDeleteAction,
    fk.update_referential_action_desc AS OnUpdateAction
FROM 
    sys.foreign_keys AS fk
INNER JOIN 
    sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
WHERE 
    fk.name = 'FK__Ticket__CNIC__2B947552'

ALTER TABLE [Ticket]
DROP CONSTRAINT FK_Ticket_Seat;

ALTER TABLE [Carriage] ADD CONSTRAINT FK_TRAINID FOREIGN KEY ([TrainId]) REFERENCES [Train] ([TrainId]) ON UPDATE CASCADE on delete CASCADE
ALTER TABLE [Seat] ADD CONSTRAINT FK_CARRIAGEID FOREIGN KEY ([CarriageID]) REFERENCES [Carriage] ([CarriageId]) ON UPDATE CASCADE on delete CASCADE

ALTER TABLE [Security] ADD CONSTRAINT FK_CREW_ID FOREIGN KEY ([CrewId]) REFERENCES [Crew] ([CrewId]) on delete CASCADE
ALTER TABLE [Pilot] ADD CONSTRAINT FK_CREWID_PILOT FOREIGN KEY ([CrewId]) REFERENCES [Crew] ([CrewId]) on delete CASCADE
ALTER TABLE [Pilot] ADD CONSTRAINT FK_STATIONID_PILOT FOREIGN KEY ([TrainId]) REFERENCES [Train] ([TrainId]) on delete SET NULL

select * from [Ticket] as T join [Payment] as P on T.TicketId=P.TicketId; 