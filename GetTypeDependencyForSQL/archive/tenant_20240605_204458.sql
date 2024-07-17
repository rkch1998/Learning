DROP FUNCTION IF EXISTS notice.FilterNotices;

CREATE OR REPLACE FUNCTION notice."FilterNotices"("_Start" integer, "_Size" integer, "_SortExpression" character varying, "_SubscriberId" integer, "_Ids" bigint[], "_FinancialYear" integer, "_EntityIds" integer[], "_NoticeIds" character varying, "_FromNoticeDate" timestamp without time zone, "_ToNoticeDate" timestamp without time zone, "_FromNoticeDueDate" timestamp without time zone, "_ToNoticeDueDate" timestamp without time zone, "_CategoryTypes" character varying, "_ActionStatuses" character varying)
 RETURNS TABLE("Id" bigint, "TotalRecord" integer)
 LANGUAGE plpgsql
AS $function$
DECLARE 	"_SQL" TEXT = '';
			"_FromSQL" TEXT = '' ;
			"_TotalRecord" INTEGER DEFAULT 0;
BEGIN
	DROP TABLE IF EXISTS "TempEntities","TempIds";
	
	CREATE TEMP TABLE IF NOT EXISTS "TempEntities" AS
	SELECT  * FROM UNNEST("_EntityIds") AS "EntityId" ; 
	
	CREATE TEMP TABLE IF NOT EXISTS "TempIds" AS
	SELECT  * FROM UNNEST("_Ids") AS "Id"; 

	CREATE  INDEX "IDX_TempEntities_Item" ON "TempEntities"("EntityId");
	CREATE  INDEX "IDX_TempIds_Item" ON "TempIds"("Id");
	
		"_FromSQL" :=CONCAT(N' FROM 
							notice."Notices" n
							INNER JOIN "TempEntities" te ON n."EntityId" = te."EntityId"
						WHERE
							n."SubscriberId" =' || "_SubscriberId"||
							' AND n."FinancialYear" =' || "_FinancialYear" ,
							
						CASE
							WHEN EXISTS (SELECT 1 FROM "TempIds" )
							THEN ' AND n."Id" IN (SELECT "Id" FROM "TempIds")'
							ELSE ''
						END,
						CASE 
							WHEN "_NoticeIds" IS NULL 
							THEN ''
							ELSE' AND n."NoticeId" IN ('|| "_NoticeIds" ||')'  
						END,
						CASE 
							WHEN "_FromNoticeDate" IS NULL AND "_ToNoticeDate" IS NULL
							THEN ''
							ELSE ' AND n."NoticeDate" BETWEEN ''' ||"_FromNoticeDate"||'''AND''' ||"_ToNoticeDate"||''''
						END,
						CASE 
							WHEN "_FromNoticeDueDate" IS NULL AND "_ToNoticeDueDate" IS NULL
							THEN ''
							ELSE ' AND n."NoticeDueDate" BETWEEN ''' || "_FromNoticeDueDate" || '''AND''' ||"_ToNoticeDueDate"||'''' 
						END,
						CASE 
							WHEN "_CategoryTypes" IS NULL 
							THEN ''
							ELSE' AND n."CategoryType" IN (' ||"_CategoryTypes"|| ')'  
						END,
						CASE 
							WHEN "_ActionStatuses" IS NULL 
							THEN ''
							ELSE' AND n."ActionStatus" IN (' ||"_ActionStatuses"|| ')'  
						END
						);

		IF "_Start" = 0
	THEN
		EXECUTE 'SELECT COUNT(n."Id")' || "_FromSQL" INTO "_TotalRecord";
 	END IF;
	
	IF ("_SortExpression" IS NULL OR "_SortExpression" = '')
	THEN
		"_SortExpression" := 'n."Id" DESC';	
	Else
		"_SortExpression" := 'n.'|| common."GetSortExpression"("_SortExpression") || ', n."Id" DESC ';
	END IF;

	"_FromSQL" := "_FromSQL" || ' ORDER BY ' || "_SortExpression";
	
	IF "_Size" IS NOT NULL
	THEN		
		"_FromSQL" := "_FromSQL" || ' LIMIT ' || "_Size" || ' OFFSET ' || "_Start";
 	END IF;
	
	"_SQL" := 'SELECT n."Id", ' || "_TotalRecord" ||' AS "TotalRecord" ' || "_FromSQL";
	
	RETURN QUERY EXECUTE 
		'SELECT n."Id", ' || "_TotalRecord" ||'  AS "TotalRecord" ' || "_FromSQL";
	
	
	
END;
$function$
;
DROP FUNCTION IF EXISTS notice.GetNoticesByIds;

CREATE OR REPLACE FUNCTION notice."GetNoticesByIds"("_SubscriberId" integer, "_Ids" bigint[])
 RETURNS TABLE("Id" bigint, "EntityId" integer, "NoticeId" character varying, "Description" character varying, "NoticeDate" timestamp without time zone, "NoticeDueDate" timestamp without time zone, "NoticeStatus" character varying, "ActionStatus" smallint, "CategoryType" smallint, "Details" character varying, "Stamp" timestamp without time zone)
 LANGUAGE plpgsql
AS $function$
/*------------------------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name	:	notice."GetNoticesByIds"
* 	Comment			:	18/10/2022 | Chetan Saini | This procedure is used to get Notices.
--------------------------------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	    : SELECT * FROM notice."GetNoticesByIds"(
							"_SubscriberId" :=227::int,
							"_Ids":=array[1]::bigint[]
							)
*/-----------------------------------------------------------------------------------------------------------

BEGIN
		DROP  TABLE IF EXISTS "TempNoticeIds";
		CREATE TEMP TABLE "TempNoticeIds"
	(
		"AutoId" SERIAL,
		"Id" BIGINT
	);

	INSERT INTO "TempNoticeIds"("Id")
	SELECT 
		*
	FROM 
		unnest("_Ids");
	RETURN QUERY
	SELECT 
		n."Id",
		n."EntityId",
		n."NoticeId",
		n."Description",
		n."NoticeDate",
		n."NoticeDueDate",
		n."NoticeStatus",
		n."ActionStatus",
		n."CategoryType",
		n."Details",
	    n."Stamp"
	FROM 
		notice."Notices" n
		INNER JOIN "TempNoticeIds" tni ON n."Id" = tni."Id"	
	WHERE 
		n."SubscriberId" = "_SubscriberId"
	ORDER BY
		tni."AutoId";

	
END;
$function$
;
DROP FUNCTION IF EXISTS notice.GetRecentNotice;

CREATE OR REPLACE FUNCTION notice."GetRecentNotice"("_SubscriberId" integer, "_EntityIds" integer[])
 RETURNS TABLE("EntityId" integer, "Description" character varying, "NoticeDate" timestamp without time zone)
 LANGUAGE plpgsql
AS $function$
/*-------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: notice."GetRecentNotice"	 	 
*	Comments		: 24-04-2024 | Sumant Kumar |  This procedure is used to Get Recent Notices.
*   Sample Execution :  SELECT * FROM notice."GetRecentNotice"  (
										 "_SubscriberId":= 476 :: INT,
										 "_EntityIds" := ARRAY[21631] :: integer[])
-------------------------------------------------------------------------------------------------------------------------------*/
BEGIN

	DROP TABLE IF EXISTS "TempEntityIds";	
	CREATE TEMP TABLE "TempEntityIds"
	(
		"Item" INTEGER NOT NULL
	);
	
	INSERT INTO "TempEntityIds"("Item") 
	SELECT
		*
	FROM
		UNNEST("_EntityIds") AS "Item";
		
  RETURN QUERY
  SELECT 
		n."EntityId",
		n."Description",
		n."NoticeDate"
	FROM 
		notice."Notices" n
	WHERE 
	    n."SubscriberId" = "_SubscriberId"
		AND n."EntityId" IN (SELECT "Item" FROM "TempEntityIds")
	ORDER BY
	    n."Stamp" DESC
	LIMIT 5;
END;
$function$
;
