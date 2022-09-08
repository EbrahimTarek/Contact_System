--1. Create database 
	USE Master;
	IF NOT EXISTS
	(
		select 1 from sys.databases where name = 'contacts'
	)
	BEGIN;
		CREATE DATABASE Contacts;
	END;

--2.create tables 
	--2.1.Create table contacts   
	use Contacts
	if exists (select 1 from sys.tables where name = 'contacts')
	begin
		drop table Contacts
	end
	create table Contacts
		(
		Contactid int primary key identity(1,1) not null,
		FirstName varchar(40) not null,
		lastname varchar(40) not null,
		DateOfBirth Date,
		AllowContactByPhone bit not null constraint Df_Contacts_AllowContactByPhone default 0,
		CreateDate datetime not null constraint Df_Contracts_CreateDate Default getdate(),
		Constraint contacts_FirstName_LastName check (FirstName != '' and LastName != ''),
		Constraint Contacts_DateOfBirth Check ( DateOfBirth >= '1850-01%' )
		)
	Go
	select * from contacts

--2.2.Create table ContactNotes   
	if exists(select 1 from sys.tables where [name] = 'ContactNotes')
	Begin
		Drop table ContactNotes
	end
	create table ContactNotes
	(
	NoteId int identity(1,1) not null,
	ContactId int not null Constraint FK_ContactNotes_Contacts foreign key references dbo.Contacts(Contactid),
	Notes varchar(200) not null,
	constraint PK_ContactNotes primary key (NoteId)
	)

--2.3.Create table Roles 
	if exists(select 1 from sys.tables where [name] = 'Roles')
	Begin
		drop table Roles
	end
	create table Roles
	(
	RoleId int primary key identity(1,1) not null,
	RoleTitle varchar(200) not null
	)
	select * from Roles

--2.4.Create table ContactRoles
	Drop table if exists ContactRoles
	create table dbo.ContactRoles
	(
     ContactId int not null,
	 RoleId int not null ,
	 Constraint PK_ContactId_RoleId primary key (ContactId,RoleId)
	 )
	  alter table dbo.ContactRoles  
		 add constraint FK_ContactRoles_Contacts 
		 foreign key (ContactId) 
		 references Contacts(ContactId)
		 on update no action
		 on delete CASCADE

	 alter table dbo.ContactRoles  
	 add constraint FK_ContactRoles_Roles foreign key (RoleId) references Roles(RoleId) on update no action on delete cascade

--2.5. create table ContactAddresses
	use Contacts
	if exists(select 1 from sys.tables where name = 'ContactAddresse')
	Begin
		drop table ContactAddresse
	end
	create table dbo.ContactAddresse
	(
	 AddressId int primary key identity(1,1) not null,
	 ContactId int not null constraint FK_ContactAddresse_Contacts foreign key references contacts(Contactid) on update no action on delete cascade,
	 HouseNumber VARCHAR(200),
     Street VARCHAR(200),
     City VARCHAR(200),
     Postcode VARCHAR(20),
	 constraint CK_ContactAddresse_HouseNumberstreetcitypostcode check (HouseNumber != '' AND Street != '' AND City != '' AND Postcode != '')
	 )
	 select * from ContactAddresse

--2.6 create table phonenumber
	Drop table if exists PhoneNumberTypes
	CREATE TABLE dbo.PhoneNumberTypes
	(
	 PhoneNumberTypeId		TINYINT	IDENTITY(1,1)	NOT NULL,
	 PhoneNumberType		VARCHAR(40)				NOT NULL,
	 CONSTRAINT PK_PhoneNumberTypes PRIMARY KEY CLUSTERED (PhoneNumberTypeId)
	)

--2.7 Create table ContactsPhoneNumbers
	use Contacts
	drop table if exists ContactPhoneNumbers
	create table dbo.ContactPhoneNumbers
	(
	 PhoneNumberId		INT			NOT NULL IDENTITY(1,1),
	 ContactId			INT			NOT NULL constraint FK_ContactPhoneNumbers_Contacts references dbo.Contacts (ContactId) on update no action on delete cascade,
	 PhoneNumberTypeId	TINYINT		NOT NULL constraint FK_ContactPhoneNumbers_ContactPhoneNumbers references dbo.PhoneNumberTypes(PhoneNumberTypeId) on update no action on delete cascade,
	 PhoneNumber		VARCHAR(30)	NOT NULL
	 CONSTRAINT PK_ContactPhoneNumbers PRIMARY KEY CLUSTERED (PhoneNumberId),
	 Constraint UQ_ContactPhoneNumbers unique (ContactId,PhoneNumber)
	)
	select * from dbo.ContactPhoneNumbers

--2.8.create table ContactVerificationDetails
	use Contacts
	drop table if exists dbo.ContactVerificationDetails
	create table dbo.ContactVerificationDetails
	(
	ContactId				INT				NOT NULL,
	DrivingLicenseNumber	VARCHAR(40)		NULL,
	PassportNumber			VARCHAR(40)		NULL,
	ContactVerified		BIT				NOT NULL	CONSTRAINT DF_ContactVerificationDetails_ContactVerified DEFAULT 0
	CONSTRAINT PK_ContactVerificationDetails PRIMARY KEY CLUSTERED (ContactId)
	)

	ALTER TABLE dbo.ContactVerificationDetails
		ADD CONSTRAINT FK_ContactVerificationDetails_Contacts
			FOREIGN KEY (ContactId)
			REFERENCES dbo.Contacts (ContactId)
			ON UPDATE NO ACTION
			ON DELETE CASCADE;

--3.Insert into dbo.PhoneNumberTypes
insert into dbo.PhoneNumberTypes(PhoneNumberType)
values('Home'),('Work'),('Mobile'),('Other')

--4.Insert into Roles
INSERT INTO dbo.Roles(RoleTitle) 
VALUES('Developer'),('DBA'),('IT Support Specialist'),('Manager'),('Director');

--5.Bulk insert into dbo.contacts
use Contacts
bulk insert dbo.Contacts
	from 'E:\ITI\microsoft azure\sql-server-database-programming-stored-procedures\Database\contactsdb\importfiles\01_Contacts.csv'
With
(
	ROWTERMINATOR = '\n',
	FIELDTERMINATOR = ',',
	FIRSTROW = 2,
	ERRORFILE = 'E:\ITI\microsoft azure\sql-server-database-programming-stored-procedures\Database\contactsdb\01_Contacts_Errors.csv',
	CHECK_CONSTRAINTS
)

--6.Bulk Insert into dbo.contactAddresses
use Contacts
bulk insert  dbo.ContactAddresse
	from 'E:\ITI\microsoft azure\sql-server-database-programming-stored-procedures\Database\contactsdb\importfiles\02_ContactAddresses.Csv'
with
(
	ROWTERMINATOR = '\n',
	fieldterminator = ',',
	FirstRow = 2,
	Check_constraints
)

--7.Bulk Insert into dbo.ContactNotes
use Contacts
bulk insert dbo.ContactNotes
	from 'E:\ITI\microsoft azure\sql-server-database-programming-stored-procedures\Database\contactsdb\importfiles\03_ContactNotes.Csv'
with
(
	Rowterminator = '\n',
	fieldterminator = ',',
	firstrow = 2,
	check_constraints
)

--8.Bulk Insert into dbo.ContactPhoneNumbers
use Contacts
bulk insert dbo.ContactPhoneNumbers
	from 'E:\ITI\microsoft azure\sql-server-database-programming-stored-procedures\Database\contactsdb\importfiles\04_ContactPhoneNumbers.Csv'
with
(
	rowterminator = '\n',
	fieldterminator = ',',
	firstrow = 2,
	check_constraints
)

--9.Bulk Insert into dbo.ContactRoles
use Contacts
bulk insert dbo.ContactRoles
	from 'E:\ITI\microsoft azure\sql-server-database-programming-stored-procedures\Database\contactsdb\importfiles\05_ContactRoles.Csv'
with
(
	rowterminator = '\n',
	fieldterminator = ',',
	firstrow = 2,
	check_constraints
)

--10.Bulk Insert into dbo.ContactRoles
use Contacts
bulk insert dbo.ContactVerificationDetails
	from 'E:\ITI\microsoft azure\sql-server-database-programming-stored-procedures\Database\contactsdb\importfiles\06_ContactVerificationDetails.Csv'
with
(
	rowterminator = '\n',
	fieldterminator = ',',
	firstrow = 2,
	check_constraints
)
--Create stored procedure to allows new contacts to be inserted into the database
use Contacts
create procedure dbo.InsertContacts
(@firstname varchar(40),@lastname varchar(40),@DateOfBirth date = null , @AllowContactByPhone bit,@Contactid int output)--output parameter
as
begin
set nocount on 
	insert into dbo.Contacts(FirstName,lastname,DateOfBirth,AllowContactByPhone)
	values(@firstname,@lastname,@DateOfBirth,@AllowContactByPhone)
	select @Contactid = SCOPE_IDENTITY()
	select Contactid , FirstName , lastname , DateOfBirth , AllowContactByPhone
	from dbo.Contacts
	where Contactid = @Contactid
end

declare @ContactIdOut int 
exec InsertContacts 'ebrahim','tarek',1, @Contactid = @ContactIdOut output

--create procedure with table valued parameters
create type dbo.contactNote
as table
(
Note varchar(max) not null 
)
create PROCEDURE dbo.InsertContactNotes(@ContactId INT,@Notes ContactNote READONLY)
AS
BEGIN
INSERT INTO dbo.ContactNotes (ContactId, Notes)
	SELECT @ContactId, Note FROM @Notes
SELECT * FROM dbo.ContactNotes
	WHERE ContactId = @ContactId
	ORDER BY NoteId DESC
END;

DECLARE @Mynotes ContactNote;

INSERT INTO @Mynotes(Note)
VALUES ('Ebrahim'),('ali'),('fathy');

EXEC dbo.InsertContactNotes
	@ContactId = 189,
	@Notes = @MyNotes

-- create procedure using (transaction & try and catch )
alter procedure dbo.InsertContactRoles(@ContactId int , @RoleTitle varchar(200))
as
begin
declare @RoleId int 
	begin try
		begin transaction
			if not exists (select 1 from dbo.Roles where RoleTitle = @RoleTitle )
				begin
					insert into dbo.Roles(RoleTitle)
					values (@RoleTitle)
				end
				select @RoleId = RoleId from Roles where RoleTitle = @RoleTitle
			if not exists(select 1 from ContactRoles where ContactId = @ContactId and RoleId = @RoleId)
				begin
					insert into ContactRoles(ContactId,RoleId)
					values(@ContactId,@RoleId)
				end
		commit transaction
			select c.Contactid,FirstName,lastname,RoleTitle
			from Contacts C , ContactRoles CR , Roles R
			where C.Contactid = Cr.ContactId
			and cr.RoleId = r.RoleId
			and C.Contactid = @ContactId
			and R.RoleTitle = RoleTitle
			print('transaction is commited')
	end try
	begin catch
		rollback transaction
		Select 
		   ERROR_NUMBER() as ErrorNumber,
		   ERROR_MESSAGE() as ErrorMessage,
		   ERROR_PROCEDURE() as ErrorProcedure,
		   ERROR_STATE() as ErrorState,
		   ERROR_SEVERITY() as ErrorSeverity,
		   ERROR_LINE() as ErrorLine
		print('transaction is rolled back')
	end catch
end












