DROP FUNCTION IF EXISTS gst."DeleteNotificationsByIds";

CREATE OR REPLACE FUNCTION gst."DeleteNotificationsByIds"("_SubscriberId" integer, "_Ids" bigint[], "_IsNotificationDocumentIds" boolean)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*--------------------------------------------------------------------------------------------------------------------------------------
* 	Procedure Name	: gst."DeleteNotificationsByIds"
*	Comments		: 11-08-2022 | Ravi Chauhan | This procedure is used to Delete Notifications By Ids.
					: 06-08-2024 | Prakash Parmar | Handled Documents And DocumentItems Deletion
----------------------------------------------------------------------------------------------------------------------------------------
*   Test Execution	: SELECT * FROM gst."DeleteNotificationsByIds"
					  (
					  	 123::INTEGER,
					  	 array[154,234,1134]::bigint[],
					  	 0::boolean
					  );

DROP FUNCTION gst."DeleteNotificationsByIds";
--------------------------------------------------------------------------------------------------------------------------------------*/

DECLARE
	"_Min" INT := 1; 
	"_Max" INT;
	"_BatchSize" INT; 
	"_Records" INT;
	
BEGIN

	DROP TABLE IF EXISTS "TempNotificationsIds", "TempIds";
	
	CREATE TEMP TABLE "TempNotificationsIds"(
		"AutoId" serial,
		"NotificationDocumentId" BIGINT,
		"NotificationId" BIGINT
	);
	
	CREATE TEMP TABLE "TempIds" AS
	SELECT * FROM UNNEST("_Ids") AS "Id";

	-- Notification Documents Details

	INSERT INTO "TempNotificationsIds"("NotificationDocumentId", "NotificationId")
	SELECT
		nd."Id", 
		n."Id" 
	FROM
		"TempIds" t 
		INNER JOIN gst."Notifications" n ON t."Id" = n."Id"
		LEFT JOIN gst."NotificationDocumentMapper" ndm ON n."Id" = ndm."NotificationId"
		LEFT JOIN gst."NotificationDocuments" nd ON ndm."NotificationDocumentId" = nd."Id" 
	WHERE
		n."SubscriberId" = "_SubscriberId";

	IF EXISTS (SELECT "NotificationId" FROM "TempNotificationsIds")
	THEN
		
		SELECT 
			COUNT("AutoId")
		INTO	
			"_Max"
		FROM
			"TempNotificationsIds";
			
		SELECT 
			CASE 
				WHEN COALESCE("_Max",0) > 100000
				THEN (("_Max"*10)/100)
				ELSE "_Max"
				END
		INTO
			"_BatchSize";
			
		WHILE ("_Min" <= "_Max")
		LOOP
			"_Records" := "_Min" + "_BatchSize";

			DELETE
			FROM
				gst."NotificationDocumentMapper" ndm
				USING "TempNotificationsIds" tnid  
			WHERE
				tnid."NotificationId" = ndm."NotificationId"
				AND tnid."AutoId" BETWEEN "_Min" AND "_Records";

			DELETE
			FROM
				gst."NotificationReminders" nr
				USING "TempNotificationsIds" tnid  
			WHERE
				tnid."NotificationId" = nr."NotificationId"
				AND tnid."AutoId" BETWEEN "_Min" AND "_Records";
				
			DELETE
			FROM
				gst."NotificationAttachments" na
				USING "TempNotificationsIds" tnid  
			WHERE
				tnid."NotificationId" = na."NotificationId"
				AND tnid."AutoId" BETWEEN "_Min" AND "_Records";

			DELETE
			FROM
				gst."NotificationLevels" nl
				USING "TempNotificationsIds" tnid  
			WHERE
				tnid."NotificationId" = nl."NotificationId"
				AND tnid."AutoId" BETWEEN "_Min" AND "_Records";
				
			DELETE
			FROM
				gst."Notifications" n
				USING "TempNotificationsIds" tnid  
			WHERE
				tnid."NotificationId" = n."Id"
				AND tnid."AutoId" BETWEEN "_Min" AND "_Records";
				
			"_Min" := "_Records";
				
		END LOOP;

		DELETE
		FROM
			gst."NotificationDocumentItems" ndi
			USING "TempNotificationsIds" tnid 
		WHERE
			tnid."NotificationDocumentId" = ndi."NotificationDocumentId"
			AND NOT EXISTS (SELECT 1
							FROM gst."NotificationDocumentMapper" ndm
							WHERE ndm."NotificationDocumentId" = ndi."NotificationDocumentId");

		DELETE
		FROM
			gst."NotificationDocuments" nd 
			USING "TempNotificationsIds" tnid 
		WHERE
			tnid."NotificationDocumentId" = nd."Id"
			AND NOT EXISTS (SELECT 1
							FROM gst."NotificationDocumentMapper" ndm
							WHERE ndm."NotificationDocumentId" = nd."Id");
	END IF;

END;
$function$
;
