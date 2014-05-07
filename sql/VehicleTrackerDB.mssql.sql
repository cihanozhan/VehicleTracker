USE [master]
GO
/****** Object:  Database [VehicleTrackerDB]    Script Date: 07.05.2014 8:43:24 ******/
CREATE DATABASE [VehicleTrackerDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'VehicleTrackerDB', FILENAME = N'D:\Program Files\Microsoft SQL Server 2012\MSSQL11.MSSQLSERVER2012\MSSQL\DATA\VehicleTrackerDB.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'VehicleTrackerDB_log', FILENAME = N'D:\Program Files\Microsoft SQL Server 2012\MSSQL11.MSSQLSERVER2012\MSSQL\DATA\VehicleTrackerDB_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [VehicleTrackerDB] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [VehicleTrackerDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [VehicleTrackerDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [VehicleTrackerDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [VehicleTrackerDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [VehicleTrackerDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [VehicleTrackerDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [VehicleTrackerDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET RECOVERY FULL 
GO
ALTER DATABASE [VehicleTrackerDB] SET  MULTI_USER 
GO
ALTER DATABASE [VehicleTrackerDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [VehicleTrackerDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [VehicleTrackerDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [VehicleTrackerDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'VehicleTrackerDB', N'ON'
GO
USE [VehicleTrackerDB]
GO
/****** Object:  User [NodeDbUser]    Script Date: 07.05.2014 8:43:25 ******/
CREATE USER [NodeDbUser] FOR LOGIN [NodeDbUser] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_datareader] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_denydatareader] ADD MEMBER [NodeDbUser]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [NodeDbUser]
GO
/****** Object:  StoredProcedure [dbo].[CreateVehicle]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateVehicle](@managerId    UNIQUEIDENTIFIER, 
                               @driverId     UNIQUEIDENTIFIER, 
                               @licensePlage NVARCHAR(10), 
                               @longitude    NVARCHAR(20), 
                               @latitude     NVARCHAR(20), 
                               @SRID         INT = 4326) 
AS 
  BEGIN 
      DECLARE @vehicleId UNIQUEIDENTIFIER 

      SET @vehicleId = NEWID() 

      INSERT INTO [dbo].[Vehicle] 
                  ([Id], 
                   [LicensePlate], 
                   [ManagerId]) 
      VALUES      (@vehicleId, 
                   @licensePlage, 
                   @managerId) 

      DECLARE @vehiclePositionWKT NVARCHAR(50) 

      SET @vehiclePositionWKT = 'POINT(' + @longitude + ' ' + @latitude + ')' 

      DECLARE @vehiclePosition GEOGRAPHY 

      SET @vehiclePosition = geography::STGeomFromText(@vehiclePositionWKT, 
                             @SRID) 

      INSERT INTO [dbo].[VehiclePosition] 
                  ([Position], 
                   [VehicleId], 
                   [Date]) 
      VALUES      (@vehiclePosition, 
                   @vehicleId, 
                   GETDATE()) 

      INSERT INTO [dbo].[DriverVehicle] 
                  ([DriverId], 
                   [VehicleId]) 
      VALUES      (@driverId, 
                   @vehicleId) 
  END 


GO
/****** Object:  StoredProcedure [dbo].[Employ]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Employ](@managerId UNIQUEIDENTIFIER, 
                        @driverId  UNIQUEIDENTIFIER) 
AS 
  BEGIN 
      INSERT INTO [dbo].[ManagerDriver] 
                  ([ManagerId], 
                   [DriverId], 
                   [EmploymentStatus]) 
      VALUES      (@managerId, 
                   @driverId, 
                   'employed') 
  END 


GO
/****** Object:  StoredProcedure [dbo].[GetConfig]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetConfig](@configName  VARCHAR(50), 
                           @configValue NVARCHAR(255) output) 
AS 
  BEGIN 
      SET @configValue = (SELECT Value 
                          FROM   Configuration 
                          WHERE  Name = @configName) 
  END 


GO
/****** Object:  StoredProcedure [dbo].[GetDriversInfo]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetDriversInfo](@managerId UNIQUEIDENTIFIER) 
AS 
  BEGIN 
      SELECT Email, 
             Id, 
             EmploymentStatus 
      FROM   ManagerDriver 
             JOIN [User] 
               ON ManagerDriver.DriverId = [User].Id 
      WHERE  ( ManagerDriver.ManagerId = @managerId ) 
  END 


GO
/****** Object:  StoredProcedure [dbo].[GetProfile]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetProfile](@userId UNIQUEIDENTIFIER) 
AS 
  BEGIN 
      SELECT [Id], 
             [Email], 
             [Name] AS [Role] 
      FROM   [dbo].[UserRolesView] 
      WHERE  [Id] = @userId 
  END 


GO
/****** Object:  StoredProcedure [dbo].[GetUnemployedDrivers]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetUnemployedDrivers] 
AS 
  BEGIN 
      SELECT Email, 
             [User].Id, 
             [Role].Name 
      FROM   [User] 
             INNER JOIN UserRole 
                     ON [User].Id = UserRole.UresId 
             INNER JOIN [Role] 
                     ON UserRole.RoleId = [Role].Id 
      WHERE  [Role].Name = 'driver' 
             AND NOT EXISTS(SELECT * 
                            FROM   ManagerDriver 
                            WHERE  ManagerDriver.DriverId = [User].Id 
                                   AND EmploymentStatus = 'employed') 
  END 


GO
/****** Object:  StoredProcedure [dbo].[GetVehicle]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetVehicle](@driverId UNIQUEIDENTIFIER) 
AS 
  BEGIN 
      SELECT Vehicle.Id, 
             Vehicle.LicensePlate 
      FROM   DriverVehicle 
             INNER JOIN Vehicle 
                     ON DriverVehicle.VehicleId = Vehicle.Id 
      WHERE  ( DriverVehicle.DriverId = @driverId ) 
  END 
GO
/****** Object:  StoredProcedure [dbo].[GetVehiclePositions]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetVehiclePositions](@vehicleId UNIQUEIDENTIFIER) 
AS 
  BEGIN 
      SELECT Id, 
             Position.Long as Longitude,
             Position.Lat as Latitude,
			 [Date] 
      FROM   VehiclePosition 
      WHERE  VehicleId = @vehicleId 
      ORDER  BY [Date] ASC 
  END 
GO
/****** Object:  StoredProcedure [dbo].[GetVehicleTrackInfos]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetVehicleTrackInfos](@managerId UNIQUEIDENTIFIER) 
AS 
  BEGIN 
      SELECT Vehicle.Id, 
             Vehicle.LicensePlate, 
             [Date], 
             Position.Long AS Longitude, 
             Position.Lat  AS Latitude
      FROM   Vehicle 
             JOIN VehiclePosition 
               ON Vehicle.Id = VehiclePosition.VehicleId 
      WHERE  Vehicle.ManagerId = @managerId 
  END 


GO
/****** Object:  StoredProcedure [dbo].[IsAdminRegistered]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Checks whether admin exists. 
--If config 'isAdminRegistered' is set to 'TRUE' returns 1. 
--Else goes through all the users. 
--IF admin if found returns 1 and sets config 'isAdminRegistered' to 'TRUE'. 
--IF admin is not found returns 0 and sets 'isAdminRegistered' to 'FALSE'. 
CREATE PROCEDURE [dbo].[IsAdminRegistered](@isAdminRegistered BIT OUTPUT) 
AS 
  BEGIN 
      DECLARE @isAdminRegisteredConfigValue AS NVARCHAR(255) 

      EXEC dbo.GetConfig 'isAdminRegistered', @isAdminRegisteredConfigValue output 

      IF @isAdminRegisteredConfigValue = 'TRUE' 
        BEGIN 
            SET @isAdminRegistered = 'TRUE' 

            RETURN 
        END 

      IF EXISTS(SELECT [User].Id 
                FROM   Role 
                       INNER JOIN UserRole 
                               ON Role.Id = UserRole.RoleId 
                       INNER JOIN [User] 
                               ON UserRole.UresId = [User].Id 
                WHERE  Role.Name = 'admin') 
        BEGIN 
            EXEC dbo.Setconfig 'isAdminRegistered', 'TRUE' 

            SET @isAdminRegistered = 'TRUE' 

            RETURN 
        END 

      EXEC dbo.Setconfig 'isAdminRegistered', 'FALSE' 

      SET @isAdminRegistered = 'FALSE' 

      RETURN 0 
  END 


GO
/****** Object:  StoredProcedure [dbo].[LoginUser]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--      var manager1 = {    
--          id: 4,    
--          name: 'Manager id:4',    
--          roles: ['manager'],    
--          driverIds: [2, 3]    
--      };    

CREATE PROCEDURE [dbo].[LoginUser](@email         NVARCHAR(50), 
                           @passwordHash  NVARCHAR(50), 
                           @isSuccessfull BIT output, 
                           @errorMessage  NVARCHAR(50) output, 
                           @userId        UNIQUEIDENTIFIER output, 
                           @displayName   NVARCHAR(50) output) 
AS 
  BEGIN 
      DECLARE @truePasswordHash NVARCHAR(50) 

      SELECT @truePasswordHash = [PasswordHash], 
             @userId = [Id], 
             @displayName = [DisplayName] 
      FROM   [User] 
      WHERE  [Email] = @email 

      IF @truePasswordHash IS NULL 
        BEGIN 
            SET @isSuccessfull = 'FALSE' 
            SET @errorMessage = 'User with such email is not found.' 

            RETURN 
        END 

      IF @truePasswordHash != @passwordHash 
        BEGIN 
            SET @isSuccessfull = 'FALSE' 
            SET @errorMessage = 'Password is incorrect.' 

            RETURN 
        END 

      --Authenticated successfull. Gathering data.   
      --Getting roles     
      DECLARE @userRoles TABLE 
        ( 
           Name NVARCHAR(10) 
        ) 

      INSERT INTO @userRoles 
      SELECT Role.Name 
      FROM   Role 
             INNER JOIN UserRole 
                     ON Role.Id = UserRole.RoleId 
             INNER JOIN [User] 
                     ON UserRole.UresId = [User].Id 
      WHERE  [User].Id = @userId 

      --Getting employees   
      DECLARE @isManager BIT; 
      DECLARE @driverIds TABLE 
        ( 
           driverId UNIQUEIDENTIFIER 
        ) 

      IF ( EXISTS(SELECT * 
                  FROM   @userRoles 
                  WHERE  Name = 'manager') ) 
        BEGIN 
            INSERT INTO @driverIds 
            SELECT DriverId 
            FROM   ManagerDriver 
            WHERE  ManagerId = @userId 
        END 

      --Returning values    
      SET @isSuccessfull = 'TRUE' 

      SELECT Name as RoleName 
      FROM   @userRoles 

      SELECT DriverId
      FROM   @driverIds 
  END 


GO
/****** Object:  StoredProcedure [dbo].[RegisterUser]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--drop procedure RegisterUser   
--go   
CREATE PROCEDURE [dbo].[RegisterUser](@email         NVARCHAR(50), 
                              @passwordHash  NVARCHAR(50), 
                              @role          NCHAR(10), 
                              @isSuccessfull BIT output, 
                              @errorMessage  NVARCHAR(50) output) 
AS 
  BEGIN 
      IF ( @role = 'admin' ) 
        BEGIN 
            DECLARE @isManagerRegistered BIT 

            EXEC dbo.IsAdminRegistered 
              @isManagerRegistered output 

            IF ( @isManagerRegistered = 'TRUE' ) 
              BEGIN 
                  SET @isSuccessfull = 'FALSE' 
                  SET @errorMessage = 'Admin is already registerd' 

                  RETURN 
              END 
        END 

      IF EXISTS(SELECT * 
                FROM   [dbo].[User] 
                WHERE  [dbo].[User].email = @email) 
        BEGIN 
            SET @isSuccessfull = 'FALSE' 
            SET @errorMessage = 'User with such eail already exists.' 

            RETURN 
        END 

      DECLARE @newUserId UNIQUEIDENTIFIER; 

      SET @newUserId = NEWID() 

      INSERT INTO [dbo].[User] 
                  (Id, 
                   Email, 
                   PasswordHash, 
                   IsBlocked) 
      VALUES      (@newUserId, 
                   @email, 
                   @passwordHash, 
                   'FALSE') 

      --Default value is NULL        
      DECLARE @roleId AS INT; 

      SELECT @roleId = Id 
      FROM   [dbo].[Role] 
      WHERE  [dbo].[Role].Name = @role 

      IF ( @roleId IS NULL ) 
        BEGIN 
            SET @isSuccessfull = 'FALSE' 
            SET @errorMessage = 'Role not found.' 

            RETURN 
        END 

      INSERT INTO [dbo].[UserRole] 
      VALUES      (@newUserId, 
                   @roleId) 

      SET @isSuccessfull = 'TRUE' 
  END 


GO
/****** Object:  StoredProcedure [dbo].[SetConfig]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SetConfig](@configName  VARCHAR(50), 
                           @configValue NVARCHAR(255)) 
AS 
  BEGIN 
      BEGIN TRAN 

      UPDATE Configuration 
      SET    Value = @configValue 
      WHERE  Name = @configName 

      IF @@rowcount = 0 
        BEGIN 
            INSERT INTO Configuration 
            VALUES      (@configName, 
                         @configValue) 
        END 

      COMMIT TRAN 
  END 


GO
/****** Object:  StoredProcedure [dbo].[SetVehiclePosition]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SetVehiclePosition](@vehicleId UNIQUEIDENTIFIER, 
                                    @longitude NVARCHAR(20), 
                                    @latitude  NVARCHAR(20), 
                                    @SRID      INT = 4326) 
AS 
  BEGIN 
      DECLARE @vehiclePositionWKT NVARCHAR(50) 

      SET @vehiclePositionWKT = 'POINT(' + @longitude + ' ' + @latitude + ')' 

      DECLARE @vehiclePosition GEOGRAPHY 

      SET @vehiclePosition = geography::STGeomFromText(@vehiclePositionWKT, 
                             @SRID) 

      INSERT INTO [dbo].[VehiclePosition] 
                  ([Position], 
                   [VehicleId], 
                   [Date]) 
      VALUES      (@vehiclePosition, 
                   @vehicleId, 
                   GETDATE()) 
  END 


GO
/****** Object:  Table [dbo].[Configuration]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Configuration](
	[Name] [varchar](50) NOT NULL,
	[Value] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Configuration] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DriverVehicle]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DriverVehicle](
	[DriverId] [uniqueidentifier] NOT NULL,
	[VehicleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_DriverVehicle] PRIMARY KEY CLUSTERED 
(
	[DriverId] ASC,
	[VehicleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Geofences]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Geofences](
	[Position] [geography] NULL,
	[UserId] [uniqueidentifier] NULL,
	[Id] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Geofences] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ManagerDriver]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ManagerDriver](
	[ManagerId] [uniqueidentifier] NOT NULL,
	[DriverId] [uniqueidentifier] NOT NULL,
	[EmploymentStatus] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_ManagerDriver] PRIMARY KEY CLUSTERED 
(
	[ManagerId] ASC,
	[DriverId] ASC,
	[EmploymentStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Role]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[Id] [uniqueidentifier] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[PasswordHash] [nvarchar](50) NOT NULL,
	[DisplayName] [nvarchar](20) NULL,
	[IsBlocked] [bit] NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[UresId] [uniqueidentifier] NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[UresId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Vehicle]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicle](
	[Id] [uniqueidentifier] NOT NULL,
	[LicensePlate] [nvarchar](10) NULL,
	[ManagerId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Vehicle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VehiclePosition]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehiclePosition](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Position] [geography] NOT NULL,
	[VehicleId] [uniqueidentifier] NOT NULL,
	[Date] [date] NOT NULL,
 CONSTRAINT [PK_VehiclePosition] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  View [dbo].[UserRolesView]    Script Date: 07.05.2014 8:43:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserRolesView]
AS
SELECT        dbo.[User].Id, dbo.[User].Email, dbo.[User].PasswordHash, dbo.Role.Name
FROM            dbo.Role INNER JOIN
                         dbo.UserRole ON dbo.Role.Id = dbo.UserRole.RoleId INNER JOIN
                         dbo.[User] ON dbo.UserRole.UresId = dbo.[User].Id

GO
ALTER TABLE [dbo].[DriverVehicle]  WITH CHECK ADD  CONSTRAINT [FK_DriverVehicle_User] FOREIGN KEY([DriverId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[DriverVehicle] CHECK CONSTRAINT [FK_DriverVehicle_User]
GO
ALTER TABLE [dbo].[DriverVehicle]  WITH CHECK ADD  CONSTRAINT [FK_DriverVehicle_Vehicle] FOREIGN KEY([VehicleId])
REFERENCES [dbo].[Vehicle] ([Id])
GO
ALTER TABLE [dbo].[DriverVehicle] CHECK CONSTRAINT [FK_DriverVehicle_Vehicle]
GO
ALTER TABLE [dbo].[Geofences]  WITH CHECK ADD  CONSTRAINT [FK_Geofences_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Geofences] CHECK CONSTRAINT [FK_Geofences_User]
GO
ALTER TABLE [dbo].[ManagerDriver]  WITH CHECK ADD  CONSTRAINT [FK_ManagerDriver_User] FOREIGN KEY([ManagerId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ManagerDriver] CHECK CONSTRAINT [FK_ManagerDriver_User]
GO
ALTER TABLE [dbo].[ManagerDriver]  WITH CHECK ADD  CONSTRAINT [FK_ManagerDriver_User1] FOREIGN KEY([DriverId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[ManagerDriver] CHECK CONSTRAINT [FK_ManagerDriver_User1]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_User] FOREIGN KEY([UresId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User]
GO
ALTER TABLE [dbo].[Vehicle]  WITH CHECK ADD  CONSTRAINT [FK_Vehicle_User] FOREIGN KEY([ManagerId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Vehicle] CHECK CONSTRAINT [FK_Vehicle_User]
GO
ALTER TABLE [dbo].[VehiclePosition]  WITH CHECK ADD  CONSTRAINT [FK_VehiclePosition_Vehicle] FOREIGN KEY([VehicleId])
REFERENCES [dbo].[Vehicle] ([Id])
GO
ALTER TABLE [dbo].[VehiclePosition] CHECK CONSTRAINT [FK_VehiclePosition_Vehicle]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Role"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 217
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 227
               Right = 405
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UserRole"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 199
               Right = 626
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UserRolesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UserRolesView'
GO
USE [master]
GO
ALTER DATABASE [VehicleTrackerDB] SET  READ_WRITE 
GO
