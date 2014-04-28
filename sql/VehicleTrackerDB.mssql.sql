USE [master]
GO
/****** Object:  Database [VehicleTrackerDB]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  User [NodeDbUser]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  StoredProcedure [dbo].[GetConfig]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  StoredProcedure [dbo].[IsAdminRegistered]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  StoredProcedure [dbo].[SetConfig]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  Table [dbo].[Configuration]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  Table [dbo].[Geofences]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  Table [dbo].[ManagerDriver]    Script Date: 28.04.2014 13:49:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ManagerDriver](
	[ManagerId] [uniqueidentifier] NOT NULL,
	[DriverId] [uniqueidentifier] NOT NULL,
	[EmploymentStatus] [nvarchar](10) NULL,
 CONSTRAINT [PK_ManagerDriver] PRIMARY KEY CLUSTERED 
(
	[ManagerId] ASC,
	[DriverId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Role]    Script Date: 28.04.2014 13:49:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[Id] [int] NOT NULL,
	[Name] [nchar](10) NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  Table [dbo].[UserRole]    Script Date: 28.04.2014 13:49:10 ******/
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
/****** Object:  Table [dbo].[Vehicle]    Script Date: 28.04.2014 13:49:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicle](
	[Id] [uniqueidentifier] NOT NULL,
	[LicensePlate] [nvarchar](10) NULL,
	[UserId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Vehicle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VehiclePosition]    Script Date: 28.04.2014 13:49:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehiclePosition](
	[Id] [int] NOT NULL,
	[Position] [geography] NOT NULL,
	[VehicleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_VehiclePosition] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

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
ALTER TABLE [dbo].[Vehicle]  WITH CHECK ADD  CONSTRAINT [FK_Vehicle_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Vehicle] CHECK CONSTRAINT [FK_Vehicle_User]
GO
ALTER TABLE [dbo].[VehiclePosition]  WITH CHECK ADD  CONSTRAINT [FK_VehiclePosition_Vehicle] FOREIGN KEY([VehicleId])
REFERENCES [dbo].[Vehicle] ([Id])
GO
ALTER TABLE [dbo].[VehiclePosition] CHECK CONSTRAINT [FK_VehiclePosition_Vehicle]
GO
USE [master]
GO
ALTER DATABASE [VehicleTrackerDB] SET  READ_WRITE 
GO
