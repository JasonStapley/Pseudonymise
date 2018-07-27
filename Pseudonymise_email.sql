IF OBJECT_ID('dbo.vRandomView') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[vRandomView]
END
GO
CREATE VIEW [dbo].[vRandomView]
AS
/*
 This view is needed for function 
 UDF_Pseudonymise_Email GDPR

 Returns a random number between 1 and 99
*/
SELECT cast(FLOOR(RAND()*(99-5+1)+1) as int) RandomView
GO

IF OBJECT_ID('DBO.UDF_PSEUDONYMISE_EMAIL') IS NOT NULL
BEGIN
	DROP FUNCTION [DBO].[UDF_PSEUDONYMISE_EMAIL]
END
GO
CREATE FUNCTION [DBO].[UDF_PSEUDONYMISE_EMAIL]
(@EMAIL VARCHAR(50))
RETURNS VARCHAR(50)
    AS
    BEGIN 	
	/*
	UDF_PSEUDONYMISE_EMAIL

	Date: 27/07/2018

	Description:
	PSEUDONYMISE an email address

	Depends:[dbo].[vRandomView]

	Usage
	SELECT [dbo].[UDF_Pseudonymise_Email]('Jason.stapley@somewhere.co.uk')


	*/	       
	DECLARE @STRLEN INT
	DECLARE @STRCOUNT INT
	DECLARE @RETVAL VARCHAR(150)
	DECLARE @RANDVALUE VARCHAR(2)

	SET @STRLEN = 0
	SET @RETVAL = ''
	SET @STRLEN = LEN(@EMAIL) 
	SET @STRCOUNT = 0
	SET @RANDVALUE = '00'

	-- Is it an emtpy email address? then create 50 random numbers
	IF  @STRLEN = 0
	BEGIN
		SET @STRLEN = 50
	END

	WHILE @STRCOUNT < @STRLEN
	BEGIN

		SELECT @RANDVALUE=RANDOMVIEW FROM VRANDOMVIEW;		
		SET  @RETVAL = @RETVAL + @RANDVALUE			
		SET @STRCOUNT = @STRCOUNT + 1;
	END
	
	-- WHY ZZZ EXTENTION? SO WE KNOW ITS BEEN PSEUDONYMISED.. 
	SET @RETVAL = RIGHT(@RETVAL,42)
	SET @RETVAL = @RETVAL + '@ZZZ.ZZZ'
	-- @EMAIL IS 50 CHARACTERS
        RETURN RIGHT(@RETVAL,50)
    END  
GO


SELECT [dbo].[UDF_Pseudonymise_Email]('jasonstapley@somewhere.com')
-- Will return something like 208043884159539324358285416562161116604310@ZZZ.ZZZ
