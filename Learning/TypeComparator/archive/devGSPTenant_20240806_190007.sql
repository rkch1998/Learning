CREATE TYPE "import"."ModuleActionCriteriaType" AS ("EntityId" integer, "SummaryType" smallint, "ActionType" smallint, "PurposeType" smallint, "SupplyType" smallint, "ReturnPeriod" integer, "GroupId" integer);

CREATE TYPE "import"."DocumentCriteriaType" AS ("EntityId" integer, "PortCode" character varying(6), "BillFromGstin" character varying(15), "SupplyType" smallint, "DocumentNumber" character varying(40), "DocumentDate" timestamp without time zone, "GroupId" integer);

CREATE TYPE "import"."DocumentType" AS ("Property4" text, "Property3" text, "Property2" text, "Property19" text, "Property1" text, "Property18" text, "Property17" text, "Property16" text, "Property15" text, "Property14" text, "Property13" text, "Property12" text, "Property11" text, "Property10" text, "ErrorCodes" character varying, "Checksum" bytea, "Status" smallint, "Others" character varying, "Property20" text, "GroupId" uuid, "EntityId" integer, "Errors" character varying, "Id" bigint, "Property9" text, "Property8" text, "Property7" text, "Property6" text, "Property5" text);

CREATE TYPE "import"."SuccessDocumentType" AS ("EntityId" integer, "Checksum" bytea);

CREATE TYPE "import"."DocumentActionCriteriaType" AS ("ActionType" smallint, "DisplayNumber" bigint, "Irn" character varying(64), "Uqc" character varying(3), "GroupNumber" smallint, "DocumentType" smallint, "Quantity" integer, "ToState" smallint, "DocumentNumber" character varying(40), "GroupId" integer, "EwayBillNumber" bigint, "EntityId" integer, "PortCode" character varying(6), "ToCity" character varying(110), "PurposeType" smallint, "BillFromGstin" character varying(15), "IsForMultiVehicleORConsolidate" boolean, "FromCity" character varying(110), "SupplyType" smallint, "TransportMode" smallint, "ConsolidatedEwayBillNumber" bigint, "DocumentDate" timestamp without time zone, "FromState" smallint);

CREATE TYPE "import"."UpdateFileDetailsType" AS ("Path" character varying(2000), "Id" bigint);


