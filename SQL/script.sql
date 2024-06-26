USE [master]
GO
/****** Object:  Database [u_foltak]    Script Date: 19.04.2024 04:34:55 ******/
CREATE DATABASE [u_foltak]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'u_foltak', FILENAME = N'/var/opt/mssql/data/u_foltak.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'u_foltak_log', FILENAME = N'/var/opt/mssql/data/u_foltak_log.ldf' , SIZE = 66048KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [u_foltak] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [u_foltak].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [u_foltak] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [u_foltak] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [u_foltak] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [u_foltak] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [u_foltak] SET ARITHABORT OFF 
GO
ALTER DATABASE [u_foltak] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [u_foltak] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [u_foltak] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [u_foltak] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [u_foltak] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [u_foltak] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [u_foltak] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [u_foltak] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [u_foltak] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [u_foltak] SET  ENABLE_BROKER 
GO
ALTER DATABASE [u_foltak] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [u_foltak] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [u_foltak] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [u_foltak] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [u_foltak] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [u_foltak] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [u_foltak] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [u_foltak] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [u_foltak] SET  MULTI_USER 
GO
ALTER DATABASE [u_foltak] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [u_foltak] SET DB_CHAINING OFF 
GO
ALTER DATABASE [u_foltak] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [u_foltak] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [u_foltak] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [u_foltak] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [u_foltak] SET QUERY_STORE = OFF
GO
USE [u_foltak]
GO
/****** Object:  UserDefinedFunction [dbo].[check_matching_answers]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[check_matching_answers]
(
    @user_id INT,
    @question_id INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @matching_answers_count INT;

    SELECT @matching_answers_count = count (*) from answers_inclusionary ai 
left join answers a on ai.ans_id = a.ans_id
join users_answers ua on ua.user_ans = a.ans_content
    WHERE ua.user_id = @user_id
    AND ua.q_id = @question_id
    group by ua.trial_id

    RETURN CASE WHEN @matching_answers_count = (select count (ans_id) from answers a join questions q 
	on q.q_id = a.ans_id
	where q.q_id = @question_id
group by trial_id)THEN 1 ELSE 0 END;
END;
GO
/****** Object:  Table [dbo].[Users_answers]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users_answers](
	[user_id] [int] NOT NULL,
	[trial_id] [int] NOT NULL,
	[q_id] [int] NOT NULL,
	[user_ans_id] [int] NOT NULL,
	[user_ans] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Users_answers_1] PRIMARY KEY CLUSTERED 
(
	[user_ans_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[firstname] [varchar](50) NOT NULL,
	[lastname] [varchar](50) NOT NULL,
	[address] [varchar](50) NULL,
	[mail] [varchar](50) NOT NULL,
	[phone] [varchar](9) NOT NULL,
	[gender_id] [int] NOT NULL,
	[age] [int] NOT NULL,
	[login] [varchar](30) NOT NULL,
	[password] [varchar](30) NOT NULL,
	[Registration_date] [datetime] NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [login_unique] UNIQUE NONCLUSTERED 
(
	[login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_user_details_with_ans]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_user_details_with_ans] AS
select firstname, lastname, trial_id, q_id, user_ans
from [user] u join users_answers ua
on u.user_id = ua.user_id
GO
/****** Object:  Table [dbo].[Participants]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Participants](
	[user_id] [int] NOT NULL,
	[trial_id] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Gender_dict]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gender_dict](
	[Gender_id] [int] IDENTITY(1,1) NOT NULL,
	[Gender_name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Gender_dict] PRIMARY KEY CLUSTERED 
(
	[Gender_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_participants_data]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_participants_data] AS
SELECT p.user_id, p.trial_id, u.firstname, u.lastname, u.address, u.mail, u.phone, g.gender_name, u.age
FROM participants p join [User] u 
on p.user_id = u.user_id join Gender_dict g 
on u.gender_id = g.gender_id
GO
/****** Object:  View [dbo].[v_for_log_in]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_for_log_in] AS
SELECT login, password 
FROM [User]
GO
/****** Object:  View [dbo].[v_for_registration]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_for_registration] AS
SELECT u.firstname, u.lastname, u.address, u.mail, u.phone, g.gender_name, u.age, u.login, u.password
FROM [User] u join Gender_dict g 
on u.gender_id = g.gender_id
GO
/****** Object:  Table [dbo].[Answers]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Answers](
	[q_id] [int] NOT NULL,
	[ans_id] [int] NOT NULL,
	[ans_content] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Answers] PRIMARY KEY CLUSTERED 
(
	[ans_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Answers_inclusionary]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Answers_inclusionary](
	[q_id] [int] NOT NULL,
	[ans_id] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Companies]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Companies](
	[company_name] [varchar](50) NOT NULL,
	[address] [varchar](50) NULL,
	[phone] [varchar](9) NOT NULL,
	[company_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Companies] PRIMARY KEY CLUSTERED 
(
	[company_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Coordinators]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coordinators](
	[coordinator_id] [int] IDENTITY(1,1) NOT NULL,
	[firstname] [varchar](50) NOT NULL,
	[lastname] [varchar](50) NULL,
	[phone] [varchar](9) NOT NULL,
	[title] [varchar](50) NULL,
 CONSTRAINT [PK_Coordinators] PRIMARY KEY CLUSTERED 
(
	[coordinator_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Diseases]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Diseases](
	[disease_id] [int] IDENTITY(1,1) NOT NULL,
	[disease_name] [nchar](30) NOT NULL,
 CONSTRAINT [PK_Diseases] PRIMARY KEY CLUSTERED 
(
	[disease_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Log_in]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Log_in](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[login] [varchar](50) NOT NULL,
	[attempt] [int] NOT NULL,
	[last_attempt_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pr_Investigators]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pr_Investigators](
	[firstname] [varchar](50) NOT NULL,
	[lastname] [varchar](50) NOT NULL,
	[specialization] [varchar](50) NOT NULL,
	[title] [varchar](50) NOT NULL,
	[phone] [varchar](9) NOT NULL,
	[pr_investigator_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Pr_Investigators] PRIMARY KEY CLUSTERED 
(
	[pr_investigator_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Questions]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Questions](
	[q_id] [int] IDENTITY(1,1) NOT NULL,
	[trial_id] [int] NOT NULL,
	[q_content] [varchar](max) NOT NULL,
	[q_form_id] [int] NULL,
 CONSTRAINT [PK_Questions] PRIMARY KEY CLUSTERED 
(
	[q_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sites]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sites](
	[site_name] [varchar](70) NOT NULL,
	[address] [varchar](50) NOT NULL,
	[phone] [nchar](9) NOT NULL,
	[site_id] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[site_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[specialization_dict]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[specialization_dict](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[titles_dict]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[titles_dict](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Trials]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Trials](
	[trial_id] [int] IDENTITY(1,1) NOT NULL,
	[trial_name] [varchar](max) NOT NULL,
	[disease_id] [int] NOT NULL,
	[company_id] [int] NOT NULL,
	[pr_investigator_id] [int] NOT NULL,
	[coordinator_id] [int] NOT NULL,
	[site_id] [int] NOT NULL,
	[trial_description] [varchar](max) NOT NULL,
	[start_date] [datetime] NOT NULL,
	[end_date] [datetime] NULL,
	[gender] [varchar](50) NOT NULL,
	[min_age] [int] NOT NULL,
	[max_age] [int] NULL,
	[ethnicity] [varchar](50) NULL,
	[phase] [int] NULL,
	[trial_number] [nchar](20) NULL,
 CONSTRAINT [PK_Trials] PRIMARY KEY CLUSTERED 
(
	[trial_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Answers]  WITH CHECK ADD  CONSTRAINT [FK_Answers_Questions] FOREIGN KEY([q_id])
REFERENCES [dbo].[Questions] ([q_id])
GO
ALTER TABLE [dbo].[Answers] CHECK CONSTRAINT [FK_Answers_Questions]
GO
ALTER TABLE [dbo].[Answers_inclusionary]  WITH CHECK ADD  CONSTRAINT [FK_Answers_inclusionary_Answers1] FOREIGN KEY([ans_id])
REFERENCES [dbo].[Answers] ([ans_id])
GO
ALTER TABLE [dbo].[Answers_inclusionary] CHECK CONSTRAINT [FK_Answers_inclusionary_Answers1]
GO
ALTER TABLE [dbo].[Answers_inclusionary]  WITH CHECK ADD  CONSTRAINT [FK_Answers_inclusionary_Questions] FOREIGN KEY([q_id])
REFERENCES [dbo].[Questions] ([q_id])
GO
ALTER TABLE [dbo].[Answers_inclusionary] CHECK CONSTRAINT [FK_Answers_inclusionary_Questions]
GO
ALTER TABLE [dbo].[Participants]  WITH CHECK ADD  CONSTRAINT [FK_Participants_Trials] FOREIGN KEY([trial_id])
REFERENCES [dbo].[Trials] ([trial_id])
GO
ALTER TABLE [dbo].[Participants] CHECK CONSTRAINT [FK_Participants_Trials]
GO
ALTER TABLE [dbo].[Participants]  WITH CHECK ADD  CONSTRAINT [FK_Participants_User] FOREIGN KEY([user_id])
REFERENCES [dbo].[User] ([user_id])
GO
ALTER TABLE [dbo].[Participants] CHECK CONSTRAINT [FK_Participants_User]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_Questions_Trials] FOREIGN KEY([trial_id])
REFERENCES [dbo].[Trials] ([trial_id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_Questions_Trials]
GO
ALTER TABLE [dbo].[Trials]  WITH CHECK ADD  CONSTRAINT [FK_Trials_Companies] FOREIGN KEY([company_id])
REFERENCES [dbo].[Companies] ([company_id])
GO
ALTER TABLE [dbo].[Trials] CHECK CONSTRAINT [FK_Trials_Companies]
GO
ALTER TABLE [dbo].[Trials]  WITH CHECK ADD  CONSTRAINT [FK_Trials_Coordinators] FOREIGN KEY([coordinator_id])
REFERENCES [dbo].[Coordinators] ([coordinator_id])
GO
ALTER TABLE [dbo].[Trials] CHECK CONSTRAINT [FK_Trials_Coordinators]
GO
ALTER TABLE [dbo].[Trials]  WITH CHECK ADD  CONSTRAINT [FK_Trials_Diseases] FOREIGN KEY([disease_id])
REFERENCES [dbo].[Diseases] ([disease_id])
GO
ALTER TABLE [dbo].[Trials] CHECK CONSTRAINT [FK_Trials_Diseases]
GO
ALTER TABLE [dbo].[Trials]  WITH CHECK ADD  CONSTRAINT [FK_Trials_Pr_Investigators] FOREIGN KEY([pr_investigator_id])
REFERENCES [dbo].[Pr_Investigators] ([pr_investigator_id])
GO
ALTER TABLE [dbo].[Trials] CHECK CONSTRAINT [FK_Trials_Pr_Investigators]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Gender_dict] FOREIGN KEY([gender_id])
REFERENCES [dbo].[Gender_dict] ([Gender_id])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Gender_dict]
GO
ALTER TABLE [dbo].[Users_answers]  WITH CHECK ADD  CONSTRAINT [FK_Users_answers_Questions] FOREIGN KEY([q_id])
REFERENCES [dbo].[Questions] ([q_id])
GO
ALTER TABLE [dbo].[Users_answers] CHECK CONSTRAINT [FK_Users_answers_Questions]
GO
ALTER TABLE [dbo].[Users_answers]  WITH CHECK ADD  CONSTRAINT [FK_Users_answers_Trials] FOREIGN KEY([trial_id])
REFERENCES [dbo].[Trials] ([trial_id])
GO
ALTER TABLE [dbo].[Users_answers] CHECK CONSTRAINT [FK_Users_answers_Trials]
GO
ALTER TABLE [dbo].[Users_answers]  WITH CHECK ADD  CONSTRAINT [FK_Users_answers_User] FOREIGN KEY([user_id])
REFERENCES [dbo].[User] ([user_id])
GO
ALTER TABLE [dbo].[Users_answers] CHECK CONSTRAINT [FK_Users_answers_User]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD CHECK  ((NOT [phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Coordinators]  WITH CHECK ADD CHECK  ((NOT [phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Coordinators]  WITH CHECK ADD CHECK  ((NOT [phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Pr_Investigators]  WITH CHECK ADD CHECK  ((NOT [phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Sites]  WITH CHECK ADD CHECK  ((NOT [phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Trials]  WITH CHECK ADD CHECK  (([end_date]>[start_date]))
GO
ALTER TABLE [dbo].[Trials]  WITH CHECK ADD CHECK  (([max_age]>[min_age]))
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD CHECK  ((NOT [phone] like '%[^0-9]%'))
GO
/****** Object:  StoredProcedure [dbo].[adding_questionaire_form]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[adding_questionaire_form]
    @idAnkiety INT,
    @idBadania INT     -- id badania, do którego odnosi się ankieta
AS
BEGIN
    -- Sprawdzenie, czy wszystkie pytania mają odpowiedzi w tabeli "odpowiedzi wlaczajace"
    IF EXISTS (
        SELECT *
        FROM Questions q
        WHERE NOT EXISTS (
            SELECT *
            FROM Answers_inclusionary ai
            WHERE ai.q_id = q.q_id
            AND q.q_form_id = @idAnkiety
        )
    )
    BEGIN
        PRINT 'Nie wszystkie pytania mają odpowiedzi, nie można dodać ankiety.'
        RETURN;  -- Zakończ procedurę, jeśli nie wszystkie pytania mają odpowiedzi
    END

    -- Wstawienie nowej ankiety do bazy danych, id ankiety = id badania (trial_id)
    INSERT INTO Questions (q_form_id)
    VALUES (@idAnkiety)

    PRINT 'Dodano nową ankietę do bazy danych.'
END

GO
/****** Object:  StoredProcedure [dbo].[registration+check_user_unique]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[registration+check_user_unique]
    @login VARCHAR(50),
    @password VARCHAR(50)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM [User]
        WHERE login = @login
    )
    BEGIN
        PRINT 'Podany login jest już zajęty.'
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM [User]
        WHERE password = @password
    )
    BEGIN
        PRINT 'Podane hasło jest już używane przez innego użytkownika. Podaj inne.'
    END
    ELSE
    BEGIN
		INSERT INTO [User] (login, password)
		VALUES (@login, @password)
    END
END
GO
/****** Object:  StoredProcedure [dbo].[user_log_in]    Script Date: 19.04.2024 04:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[user_log_in]
    @login VARCHAR(50),
    @password VARCHAR(50)
AS
BEGIN
    DECLARE @iloscProb INT

    -- Sprawdzanie, czy użytkownik jest zablokowany
    IF EXISTS (
        SELECT 1
        FROM Log_in
        WHERE login = @login
        AND DATEDIFF(MINUTE, last_attempt_date, GETDATE()) < 10
    )
    BEGIN
        PRINT 'Twoje konto jest tymczasowo zablokowane, z powodu 3 nieudanych prób logowania. Spróbuj ponownie po 10 minutach.'
        RETURN;
    END

    -- Sprawdzanie poprawności loginu i hasła
    IF EXISTS (
        SELECT 1
        FROM [User]
        WHERE login = @login
        AND password = @password
    )
    BEGIN
        -- Logowanie użytkownika
        PRINT 'Zalogowano pomyślnie.'
        -- Jeśli był wcześniej zablokowany, usuwanie wpisu z tabeli Logowanie
        DELETE FROM Log_in WHERE login = @login
    END
    ELSE
    BEGIN
        -- Zwiększenie liczby prób i zapisywanie informacji o próbie logowania
        SELECT @iloscProb = ISNULL(attempt, 0) + 1
        FROM Log_in
        WHERE login = @login

        IF @iloscProb >= 3
        BEGIN
            -- Blokowanie użytkownika na 10 minut
            PRINT 'Nieudana próba logowania. Twoje konto zostaje zablokowane na 10 minut.'
            UPDATE Log_in SET attempt = @iloscProb, last_attempt_date = GETDATE() WHERE login = @login
        END
        ELSE
        BEGIN
            -- Zapisywanie informacji o nieudanej próbie logowania
            INSERT INTO Log_in (login, attempt, last_attempt_date) VALUES (@login, @iloscProb, GETDATE())
            PRINT 'Nieudana próba logowania. Spróbuj ponownie.'
        END
    END
END
GO
USE [master]
GO
ALTER DATABASE [u_foltak] SET  READ_WRITE 
GO
