
REM VGER_SUPPORT CSC_REPORT_GROUP

  CREATE TABLE "VGER_SUPPORT"."CSC_REPORT_GROUP" 
   (	"REPORT_GROUP_ID" NUMBER NOT NULL ENABLE, 
	"REPORT_GROUP_DESC" VARCHAR2(4000)
   ) ;
 CREATE UNIQUE INDEX "VGER_SUPPORT"."CSC_REPORT_GROUP_PK" ON "VGER_SUPPORT"."CSC_REPORT_GROUP" ("REPORT_GROUP_ID") 
  ;
  ALTER TABLE "VGER_SUPPORT"."CSC_REPORT_GROUP" ADD CONSTRAINT "CSC_REPORT_GROUP_PK" PRIMARY KEY ("REPORT_GROUP_ID") ENABLE;
 