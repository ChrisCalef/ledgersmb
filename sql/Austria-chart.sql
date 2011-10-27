begin;
-- Kontoplan für Österreich
-- Ferdinand Gassauer, Tue, 5 Feb 2002
-- checked and completed, Thu, 7 Feb 2002, Dieter Simader
--
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0000','AUFWENDUNGEN FÜR INGANGSETZEN UND ERWEITERN DES BETRIEBES','H','00','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0010','Firmenwert','A','015','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0100','IMMATERIELLE VERMÖGENSGEGENSTÄNDE','H','01','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0110','Rechte','A','011','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0200','GRUNDSTÜCKE','H','02-03','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0210','unbebaute Grundstücke','A','020','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0220','bebaute Grundstücke','A','021','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link,contra) values ('0229','kum. Abschreibung bebaute Grundstücke','A','039','A','','1');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0400','MASCHINEN','H','04-05','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0410','Maschinen','A','041','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link,contra) values ('0419','kum. Abschreibung Maschinen','A','069','A','','1');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0500','FAHRZEUGE','H','06','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0510','Fahrzeuge','A','063','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link,contra) values ('0519','kum. Abschreibung Fahrzeuge','A','069','A','','1');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0600','BETRIEBS- UND GESCHÄFTSAUSSTATTUNG','H','06','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0620','Büroeinrichtungen','A','066','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link,contra) values ('0625','kum. Abschreibung Betriebs- und Geschäftsausstattung','A','069','A','','1');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0700','GELEISTETE ANZAHLUNGEN','H','07','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0800','FINANZANLAGEN','H','08-09','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0810','Beteiligungen','A','081','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('0820','Wertpapiere','A','080','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1100','ROHSTOFFE','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1120','Vorräte - Rohstoffe','A','110-119','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1200','BEZOGENE TEILE','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1220','Vorräte - bezogene Teile','A','120-129','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1300','HILFS- UND BETRIEBSSTOFFE','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1320','Hilfsstoffe','A','130-134','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1350','Betriebssstoffe','A','135-139','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1400','UNFERTIGE ERZEUGNISSE','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1420','Vorräte - unfertige Erzeugnisse','A','140-149','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1500','FERTIGE ERZEUGNISSE','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1520','Vorräte - Hardware','A','150-159','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1530','Vorräte - Software','A','150-159','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1540','Vorräte - Ersatzteile','A','150-159','A','IC');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1600','WAREN','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1700','NOCH NICHT ABGERECHNETE LEISTUNGEN','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1800','GELEISTETE ANZAHLUNGEN','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('1900','WERTBERICHTIGUNGEN','H','1','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2000','FORDEUNGEN AUS LIEFERUNGEN UND LEISTUNGEN','H','2','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2010','Forderungen Lieferung & Leistung','A','200-207','A','AR');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2019','Wertberichtigung uneinbringliche Forderungen','A','20-21','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2300','SONSTIGE FORDERUNGEN','H','2','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2320','sonstige Forderungen','A','23-24','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2500','FORDERUNGEN AUS ABGABENVERRECHNUNG','H','2','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2520','sonstige Forderungen aus Abgebenverrechnung','A','25','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2600','WERTPAPIERE UND ANTEILE','H','2','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2620','Wertpapiere Umlaufvermögen','A','26','A','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2700','KASSABESTAND','H','2','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2701','Kassa','A','27-28','A','AR_paid:AP_paid');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2800','SCHECKS, GUTHABEN BEI KREDITINSTITUTEN','H','2','A','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2810','Schecks','A','27-28','A','AR_paid:AP_paid');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('2820','Bankguthaben','A','280-288','A','AR_paid:AP_paid');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3100','LANGFRISTIGE VERBINDLICHKEITEN','H','3','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3110','Bank Verbindlichkeiten','A','31','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3120','Kredite von Eigentümern','A','310','L','AP_paid');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3300','VERBINDLICHKEITEN AUS LIEFERUNGEN UND LEISTUNGEN','H','33','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3310','Verbindlichkeiten aus Lieferungen und Leistungen','A','330-335','L','AP');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3500','VERBINDLICHKEITEN FINANZAMT','H','35','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3510','Finanzamt Verrechnung Körperschaftssteuer','A','350-359','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3520','Finanzamt Verrechnung Umsatzsteuer','A','350-359','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3530','Mehrwertsteuer 0%','A','350-359','L','AR_tax:AP_tax:IC_taxpart:IC_taxservice');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3531','Mehrwertsteuer 10%','A','350-359','L','AR_tax:AP_tax:IC_taxpart:IC_taxservice');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3532','Mehrwertsteuer 20%','A','350-359','L','AR_tax:AP_tax:IC_taxpart:IC_taxservice');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3540','Vorsteuer 0%','A','350-359','L','AR_tax:AP_tax:IC_taxpart:IC_taxservice');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3541','Vorsteuer 10%','A','350-359','L','AR_tax:AP_tax:IC_taxpart:IC_taxservice');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('3542','Vorsteuer 20%','A','350-359','L','AR_tax:AP_tax:IC_taxpart:IC_taxservice');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4000','UMSATZ','H','4','I','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4020','Verkauf - Hardware','A','40-44','I','AR_amount:IC_sale');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4030','Verkauf - Software ','A','40-44','I','AR_amount:IC_sale');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4040','Verkauf - Ersatzteile','A','40-44','I','AR_amount:IC_sale');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4300','UMSATZ BERATUNG','H','4','I','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4320','Erlöse Beratung','A','40-44','I','AR_amount:IC_income');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4330','Erlöse Programmierung','A','40-44','I','AR_amount:IC_income');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4600','SONSTIGE ERLÖSE','H','4','I','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4630','Frachterlöse','A','46-49','I','IC_income');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('5000','WARENEINSATZ','H','5','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('5020','Wareneinsatz / Hardware','A','500-509','E','AP_amount:IC_cogs');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('5030','Wareneinsatz / Software','A','500-509','E','AP_amount:IC_cogs');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('5040','Wareneinsatz / Ersatzteile','A','520-529','E','AP_amount:IC_cogs');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('5600','VERBRAUCH BRENN- UND TREIBSTOFFEN, ENERGIE UND WASSER','H','5','I','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('5610','Energie, Wasser','A','560-569','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6000','LOHNAUFWAND','H','6','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6010','Lohn ','A','600-619','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6200','GEAHLTSAUFWAND','H','6','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6210','Gehalt ','A','620-639','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6500','GESETZLICHER SOZIALAUFWAND','H','6','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6510','Dienstgeberanteile','A','645-649','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6700','FREIWILLIGER SOZIALAUFWAND','H','6','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('6710','freiwilliger Sozialaufwand','A','660-665','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7000','ABSCHREIBUNGEN','H','7','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7010','Abschreibungen','A','700','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7020','geringwertige Wirtschaftsgüter','A','701-708','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7100','SONSTIGE STEUERN','H','71','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7110','Ertragssteuern','A','710-719','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7120','Grundsteuern','A','710-719','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7200','INSTANDHALTUNGSAUFWAND','H','7','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7210','Reparatur und Instandhaltung','A','720-729','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7300','TRANSPORTKOSTEN','H','73','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7310','Frachtaufwand','A','730-731','E','AP_amount:IC_expense');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7400','MIET-,PACHT-,LEASING-, LIZENZAUFWAND','H','74','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7410','Miete','A','740-743','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7411','Lizenzen','A','748-749','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7600','VERWALTUNGSKOSTEN','H','76','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7610','Beratungsaufwand','A','775-776','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7611','Büromaterialien','A','760','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7615','Werbung und Marketing','A','765-768','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7620','uneinbringliche Forderungen','A','799','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7630','Telephonkosten','A','738-739','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7631','Internetkosten','A','738-739','E','AP_amount:IC_expense');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7632','Reise- und Repräsentationsaufwand','A','734-735','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7634','Registrierungsgebühren','A','748-749','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7700','VERSICHERUNGEN','H','77-78','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('7710','Versicherung','A','770-774','E','AP_amount');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('8000','FINANZERTRÄGE UND FINANZAUFWENDUNGEN','H','8','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('8020','Bankzinsen und Gebühren','A','80-83','E','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('8100','BETEILIGUNGSERTRÄGE','H','8','I','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('8110','Erträge aus Beteiligungen','A','800-804','I','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9000','KAPITAL','H','9','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9010','Aktien, Geschäftsanteile','A','900-918','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9020','nicht einbezahltes Kapital','A','919','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9200','KAPITALRÜCKLAGEN','H','9','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9210','freie Rücklage','A','920-929','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9300','GEWINN','H','939','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9310','Gewinnvortrag Vorjahr','A','980','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9320','Jahresgewinn','A','985','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9400','RÜCKSTELLUNGEN','H','3','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9420','Abfertigungsrückstellung','A','300','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9430','Urlaubsrückstellung','A','304-309','L','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9700','EINLAGEN STILLER GESELLSCHAFTER','H','9','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('9800','EB,SB,G+V KONTEN','H','9','Q','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('4640','Devisengewinne','A','80-83','I','');
insert into chart (accno,description,charttype,gifi_accno,category,link) values ('8050','Devisenverluste','A','80-83','E','');
--
insert into tax (chart_id,rate) values ((select id from chart where accno = '3530'),0.00);
insert into tax (chart_id,rate) values ((select id from chart where accno = '3531'),0.10);
insert into tax (chart_id,rate) values ((select id from chart where accno = '3532'),0.20);
--
INSERT INTO defaults (setting_key, value) VALUES ('inventory_accno_id', (select id from chart where accno = '1520')); 
INSERT INTO defaults (setting_key, value) VALUES ('income_accno_id', (select id from chart where accno = '4020'));

 INSERT INTO defaults (setting_key, value) VALUES ('expense_accno_id', (select id from chart where accno = '7610'));

 INSERT INTO defaults (setting_key, value) VALUES ('fxgain_accno_id', (select id from chart where accno = '4640'));

 INSERT INTO defaults (setting_key, value) VALUES ('fxloss_accno_id', (select id from chart where accno = '8050'));

 INSERT INTO defaults (setting_key, value) VALUES ('curr', 'EUR:USD');

 INSERT INTO defaults (setting_key, value) VALUES ('weightunit', 'kg');
--
commit;