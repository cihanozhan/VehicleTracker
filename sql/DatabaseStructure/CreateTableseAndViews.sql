--#region Recreate Database
USE master

GO

IF EXISTS(SELECT *
          FROM   sys.databases
          WHERE  name = 'VehicleTrackerDb')
  BEGIN
      DROP DATABASE VehicleTrackerDb
  END

  CREATE DATABASE VehicleTrackerDb

GO
--#endregion

USE VehicleTrackerDb

GO

--#region Create Tables
CREATE TABLE Users
  (
     Id           INT PRIMARY KEY IDENTITY,
     Name         NVARCHAR(20),
     Email        VARCHAR(320) UNIQUE NOT NULL,
     PasswordHash VARCHAR(60) NOT NULL,
     IsBlocked    BIT DEFAULT 'false' NOT NULL
  )

CREATE TABLE Roles
  (
     Id   INT PRIMARY KEY IDENTITY,
     Name VARCHAR (20) UNIQUE NOT NULL
  )

INSERT INTO Roles
            (Name)
VALUES      ('admin'),
            ('manager'),
            ('driver')

CREATE TABLE UsersXRoles
  (
     UserId INT FOREIGN KEY REFERENCES Users(Id),
     RoleId INT FOREIGN KEY REFERENCES Roles(Id)
     PRIMARY KEY (UserId, RoleId)
  )

CREATE TABLE JobOffers
  (
     --TODO: Inconsistency. Manager offers a job. Driver applies for a job. This should cause autosubmit.
	 Id           INT PRIMARY KEY IDENTITY,
     SenderId     INT FOREIGN KEY REFERENCES Users(Id),
     RecieverId   INT FOREIGN KEY REFERENCES Users(Id),
     OfferStatus  VARCHAR(20) DEFAULT 'Pending' NOT NULL,
     OfferDate    DATETIME NOT NULL,
     DecisionDate DATETIME
  )

CREATE TABLE Messages
  (
     Id          INT PRIMARY KEY IDENTITY,
     SenderId    INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
     RecieverId  INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
     MessageText NVARCHAR(1000) NOT NULL,
     IsRead      BIT DEFAULT 'false' NOT NULL
  )

CREATE TABLE ManagerXDrivers
  (
     DriverId  INT FOREIGN KEY REFERENCES Users(Id) PRIMARY KEY,
     ManagerId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
  )

CREATE TABLE Vehicles
  (
     Id        INT PRIMARY KEY IDENTITY,
     ManagerId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
     Name      NVARCHAR(30) NOT NULL,
     Info      NVARCHAR(600)
  )

CREATE TABLE Positions
  (
     Id           INT PRIMARY KEY IDENTITY,
     VehicleId    INT FOREIGN KEY REFERENCES Vehicles(Id) NOT NULL,
     CheckoutDate DATETIME NOT NULL,
     Position     GEOGRAPHY NOT NULL
  )

CREATE TABLE DriverXVehicle
  (
     DriverId  INT FOREIGN KEY REFERENCES Users(Id) PRIMARY KEY,
     VehicleId INT FOREIGN KEY REFERENCES Vehicles(Id) NOT NULL
  )
GO
--#endregion


--#region Create Views
CREATE VIEW [VW_UserRoles]
AS
  SELECT Users.Id as UserId,
         Email,
         Roles.Name as RoleName
  FROM   Roles INNER JOIN
         UsersXRoles ON Roles.Id = UsersXRoles.RoleId INNER JOIN
         Users ON UsersXRoles.UserId = Users.Id
GO

CREATE VIEW [VW_ManagerDrivers]
AS
  SELECT ManagerId,
         DriverId
  FROM   ManagerXDrivers
         INNER JOIN Users
                 ON ManagerXDrivers.DriverId = Users.Id
                    AND ManagerXDrivers.ManagerId = Users.Id

GO

CREATE VIEW [VW_DriverVehicle]
AS
  SELECT *
  FROM   DriverXVehicle
         INNER JOIN Vehicles
                 ON DriverXVehicle.VehicleId = Vehicles.Id

GO
--#endregion