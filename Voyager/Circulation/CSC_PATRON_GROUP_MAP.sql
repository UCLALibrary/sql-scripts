
REM VGER_SUPPORT CSC_PATRON_GROUP_MAP

  CREATE TABLE "VGER_SUPPORT"."CSC_PATRON_GROUP_MAP" 
   (	"PATRON_GROUP_ID" NUMBER NOT NULL ENABLE, 
	"REPORT_GROUP_ID" NUMBER
   ) ;
 CREATE UNIQUE INDEX "VGER_SUPPORT"."CSC_PATRON_GROUP_MAP_PK" ON "VGER_SUPPORT"."CSC_PATRON_GROUP_MAP" ("PATRON_GROUP_ID") 
  ;
  ALTER TABLE "VGER_SUPPORT"."CSC_PATRON_GROUP_MAP" ADD CONSTRAINT "CSC_PATRON_GROUP_MAP_PK" PRIMARY KEY ("PATRON_GROUP_ID") ENABLE;
 