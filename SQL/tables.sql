CREATE TABLE [User] (
  [CNIC] nvarchar(255) PRIMARY KEY,
  [UserName] nvarchar(255),
  [Password] nvarchar(255),
  [PhoneNo] nvarchar(255)
)
GO

CREATE TABLE [Ticket] (
  [TicketId] nvarchar(255) PRIMARY KEY,
  [CNIC] nvarchar(255),
  [SeatNo] int,
  [TrainId] NVARCHAR(255),
  [CarriageId] NVARCHAR(255),
  [trackId] NVARCHAR(255)
)
GO


CREATE TABLE [Carriage] (
  [CarriageId] nvarchar(255) PRIMARY KEY,
  [TrainId] nvarchar(255),
  [Type] char
)
GO


CREATE TABLE [Seat] (
  [CarriageID] nvarchar(255),
  [TrainID] nvarchar(255),
  [SeatNo] int,
  [BookingStatus] char,
  PRIMARY KEY ([CarriageID], [TrainID], [SeatNo])
)
GO

CREATE TABLE [Tracks] (
  [TrackId] nvarchar(255) PRIMARY KEY,
  [Station1Id] nvarchar(255),
  [Station2Id] nvarchar(255)
)
GO

CREATE TABLE [Station] (
  [StationId] nvarchar(255) PRIMARY KEY,
  [StationName] nvarchar(255),
  [Address] nvarchar(255)
)
GO



CREATE TABLE [Train] (
  [TrainId] nvarchar(255) PRIMARY KEY,
  [UpDownStatus] char,
  [DeptStation] nvarchar(255),
  [ArrivalStation] nvarchar(255)
)
GO

CREATE TABLE [Payment] (
  [TicketId] nvarchar(255),
  [CNIC] nvarchar(255),
  [TotalPrice] nvarchar(255),
  [RefundStatus] char,
  PRIMARY KEY ([TicketId])
)
GO

CREATE TABLE [Fare] (
  [TrackId] nvarchar(255),
  [Economy] float,
  [BusinessClass] float,
  [FirstClass] float
)
GO

CREATE TABLE [Crew] (
  [CrewId] nvarchar(255) PRIMARY KEY,
  [CrewName] nvarchar(255),
  [Address] nvarchar(255),
  [DateOfBirth] nvarchar(255)
)
GO

CREATE TABLE [Pilot] (
  [CrewId] nvarchar(255),
  [TrainId] nvarchar(255),
  PRIMARY KEY ([CrewId], [TrainId])
)
GO

CREATE TABLE [Security] (
  [CrewId] nvarchar(255),
  [StationId] nvarchar(255),
  PRIMARY KEY ([CrewId], [StationId])
)
GO

CREATE TABLE [Route] (
  [TrainId] nvarchar(255),
  [TrackId] nvarchar(255),
  [DeptTime] time,
  [ArrivalTime] time,
  PRIMARY KEY ([TrainId], [TrackId])
)
GO

ALTER TABLE [Pilot] ADD FOREIGN KEY ([CrewId]) REFERENCES [Crew] ([CrewId])
GO

ALTER TABLE [Security] ADD FOREIGN KEY ([CrewId]) REFERENCES [Crew] ([CrewId])
GO

ALTER TABLE [Security] ADD FOREIGN KEY ([StationId]) REFERENCES [Station] ([StationId])
GO

ALTER TABLE [Tracks] ADD FOREIGN KEY ([Station1Id]) REFERENCES [Station] ([StationId])
GO

ALTER TABLE [Tracks] ADD FOREIGN KEY ([Station2Id]) REFERENCES [Station] ([StationId])
GO

ALTER TABLE [Route] ADD FOREIGN KEY ([TrackId]) REFERENCES [Tracks] ([TrackId])
GO

ALTER TABLE [Route] ADD FOREIGN KEY ([TrainId]) REFERENCES [Train] ([TrainId])
GO

ALTER TABLE [Ticket] ADD FOREIGN KEY ([SeatNo]) REFERENCES [Seat] ([SeatNo])
GO

ALTER TABLE [Carriage] ADD FOREIGN KEY ([TrainId]) REFERENCES [Train] ([TrainId])
GO

ALTER TABLE [Seat] ADD FOREIGN KEY ([CarriageID]) REFERENCES [Carriage] ([CarriageId])
GO

ALTER TABLE [Seat] ADD FOREIGN KEY ([TrainID]) REFERENCES [Train] ([TrainId])
GO

ALTER TABLE [Fare] ADD FOREIGN KEY ([TrackId]) REFERENCES [Tracks] ([TrackId])
GO

ALTER TABLE [Payment] ADD FOREIGN KEY ([TicketId]) REFERENCES [Ticket] ([TicketId])
GO

ALTER TABLE [Ticket] ADD FOREIGN KEY ([CNIC]) REFERENCES [User] ([CNIC])
GO

ALTER TABLE [Ticket]
ADD CONSTRAINT FK_Ticket_Seat
FOREIGN KEY ([CarriageId], [TrainId], [SeatNo])
REFERENCES [Seat] ([CarriageID], [TrainID], [SeatNo]);

ALTER TABLE [Payment] ADD FOREIGN KEY ([CNIC]) REFERENCES [User] ([CNIC])
GO

ALTER TABLE [Pilot] ADD FOREIGN KEY ([TrainId]) REFERENCES [Train] ([TrainId])
GO

ALTER TABLE [Ticket] ADD FOREIGN KEY ([StartingStation]) REFERENCES [Station] ([StationId])
GO

ALTER TABLE [Ticket] ADD FOREIGN KEY ([EndingStation]) REFERENCES [Station] ([StationId])
GO

ALTER TABLE [Train] ADD FOREIGN KEY ([DeptStation]) REFERENCES [Station] ([StationId])
GO

ALTER TABLE [Train] ADD FOREIGN KEY ([ArrivalStation]) REFERENCES [Station] ([StationId])
GO


--------------- UPDATES -------------------------------

ALTER TABLE [Ticket]
DROP CONSTRAINT FK__Ticket__TrainId__607251E5;

ALTER TABLE [Ticket]
DROP CONSTRAINT FK__Ticket__Carriage__6166761E;

ALTER TABLE [User]
DROP CONSTRAINT PK__User__3214EC072F032F7B;

ALTER TABLE [Payment] 
DROP FK__Payment__CNIC__5D95E53A

ALTER TABLE [Ticket]
DROP CONSTRAINT FK__Ticket__user_CNIC;

ALTER TABLE [User]
ADD CONSTRAINT PK_User PRIMARY KEY ([CNIC]);

ALTER TABLE [User]
ALTER COLUMN [CNIC] nvarchar(255) NOT NULL;

SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Seat' AND CONSTRAINT_TYPE = 'PRIMARY KEY';

SELECT
    name
FROM
    sys.foreign_keys
WHERE
    parent_object_id = OBJECT_ID('Ticket');

EXEC sp_rename 'Ticket.carriageId', 'CarriageId', 'COLUMN';

ALTER TABLE [Seat]
ADD CONSTRAINT UQ_Seat
UNIQUE ([CarriageID], [TrainID], [SeatNo]);

SELECT name
FROM sys.objects
WHERE type_desc = 'FOREIGN_KEY_CONSTRAINT'
AND parent_object_id = OBJECT_ID('Ticket');

delete from [user]
where userName='Muhammad Hassan Javed'

insert into [User]
values('1234567890123','Muhammad Hassan Javed','jackpot123','03200202469')
go

alter table [user] drop column id




CREATE TABLE [Ticket] (
  [CNIC] nvarchar(255),
  [SeatNo] int,
  [TrainId] NVARCHAR(255),
  [CarriageId] NVARCHAR(255),
  [trackId] NVARCHAR(255),
  [TicketId] nvarchar(255) PRIMARY KEY
)

insert into Ticket
values('3520297089087',1,'KhiExpress','KhiExpressCarriage','1')
go



select * from [User]
select * from [Ticket]
select * from [Crew]
select * from [Pilot]
select * from [Train]
select * from [Carriage]
select * from [Fare]
select * from [Payment]
select * from [Station]
select * from [Security]
select * from [Tracks]
select * from [Seat]
select * from [Route]
