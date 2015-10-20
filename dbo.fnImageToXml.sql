
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		petervandivier
-- Create date: 2015-10-12
-- Description:	inline scalar to convert image to xml
-- =============================================
CREATE FUNCTION fnImageToXml 
(
	@Image Image
)
RETURNS xml
AS
BEGIN
	DECLARE 
		@Xml xml,
		@VarBin varbinary( max ) ;

	select @VarBin = convert( varbinary( max ), @Image ) ;

	if left( @VarBin, 3 ) = 0xEFBBBF
		set @VarBin = convert( varbinary( max ), substring( @Image, 4, len( @VarBin ) ) ) ;

	SELECT @Xml = convert( xml, @VarBin ) ;

	RETURN @Xml ;

END ;
GO

