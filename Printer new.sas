*merge batch*;
libname Ani "C:\Users\aayom\OneDrive\Printers";
options fmtsearch=(Ani);
*import all 4 datasets - create permanent datasets*;
Proc import out=Batch1
datafile="C:\Users\aayom\OneDrive\Printers\Project_data_New"
dbms=xlsx replace;
getnames=yes;
sheet=Batch_1;
run;

Proc import out=Batch2
datafile="C:\Users\aayom\OneDrive\Printers\Project_data_New"
dbms=xlsx replace;
getnames=yes;
sheet=Batch_2;
run;

Proc import out=Batch3 
datafile="C:\Users\aayom\OneDrive\Printers\Project_data_New"
dbms=xlsx replace;
getnames=yes;
sheet=Batch_3;
range="A1:AT501";
run;

proc import out=Batch4
datafile="C:\Users\aayom\OneDrive\Printers\Project_data_New"
dbms=xlsx replace;
getnames=yes;
sheet=Batch_4;
range="A1:AT501";
run;

proc format library=Ani;
	value TF 1="True" 2="False";
	run;
	
*Rename variables in batch2;
data Batch2A;
length smoker $10 CA_type $80 A_type $470 device $1840 evidence_doctor $2340 features $120 evidence_test $2 job_title $110;
set Batch2;
Rename Death_Year=Death_Year2
proof=Proof2 
dust_visible=dust_visible2
Immune_test=Immune_test2
Coworkers=Coworkers2
Metal_exposure=Metal_exposure2
Hypersensitivity=Hypersensitivity2;
run;

*Rename variables in batch3;
data Batch3A;
length smoker $10 CA_type $80 A_type $470 device $1840 evidence_doctor $2340 features $120 evidence_test $2 job_title $110;
set Batch3;
Rename O_metals=O_metals3;
*hypersensitivity=hypersensitivity3*;
run;

*Rename variables in batch1+*;
data Batch1A;
length smoker $10 CA_type $80 A_type $470 device $1840 evidence_doctor $2340 job_title $110;
set Batch1;
*Rename Coworkers=Coworkers1
Hypersensitivity=Hypersensitivity1
dust_visible=dust_visible1
proof=proof1
Immune_test=Immune_test1*;
run;

*Rename variables in batch4;
data Batch4A;
length smoker $10 CA_type $80 A_type $470 device $1840 evidence_doctor $2340 features $120 evidence_test $2 job_title $110;
set Batch4;
Rename death_year=death_year4
MS__system=MS_system
proof=proof4
dust_visible=dust_visible4
Immune_test=Immune_test4
Coworkers=Coworkers4
Metal_exposure=Metal_exposure4
hypersensitivity=hypersensitivity4;
run;

*Merge datasets:4 batches=batch1A, batch2A, batch3A, batch4A*;
data Ani.print;
	set batch1A (in=batch1) batch2A (in=batch2) batch3A (in=batch3) batch4A (in=batch4);
	ID2 =_n_;
	if batch1 then batch=1;
		else if batch2 then batch=2;
		else if batch3 then batch=3;
		else if batch4 then batch=4;
run;

proc contents data=ani.print; run;

*format values YN and Location*;
proc format library=ani;
value YN 1="true"
 0="false";
 value location 0="None of the location"
  1="Police"
  2="service technician"
  3="Job center";
 run;
 
proc format library=ani;
value smoke 1="Non-smoker"
			2="Ex-smoker"
			3="Smoker" 
			9="Unknown";
run;

*Create array and label for health outcome variables*;
data Ani.printer3;
set Ani.print;
array SYMC [29] Resp_tract Asthma_COPD skin gi_tract eyes liver MS_system neurological uro_genital hormonal CVS fatigue 
                CA leukemia tissue_sample other_health allergy nickel cobalt O_metals  police service_technician
                Job_center proof dust_visible immune_test coworkers metal_exposure hypersensitivity ;
array SYMN [29] SYM_RT As_COPD SYM_Skin SYM_GT SYM_eyes SYM_liver SYM_MS SYM_neuro SYM_uro 
               SYM_Hor SYM_CVS SYM_fat SYM_CA SYM_leuk SYM_TS SYM_OH SYM_AL SYM_nic SYM_co SYM_OM Loc_pol Loc_ST Loc_JC 
               PR dust IT cowork M_expo hyper ;
do i=1 to 29;
if upcase(SYMC [i])="TRUE" then SYMN [i]=1;
else if upcase(SYMC [i])="FALSE" then SYMN [i]=0;
 end; 
if substr(smoker,1,3) in ("non") then smok=1;
else if smoker in ("Ex-smoker", "ex-smoker") then smok=2;
else if smoker in ("smoker") then smok=3;
else if smok=. then smok=9;
if batch=3 then do; SYM_OM=O_metals3; end;
else if batch=2 then do; cowork=coworkers2; M_expo=Metal_exposure2; IT=Immune_test2; hyper=hypersensitivity2; dust=dust_visible2;PR=proof2;
end;
else if batch=4 then do; cowork=coworkers4; M_expo=Metal_exposure4; IT=Immune_test4; hyper=hypersensitivity4; 
dust=dust_visible4; PR=proof4;end;
if Loc_pol=1 then Location=1;
else if Loc_pol=0 then do;
if Loc_ST=1 then Location=2;
else if Loc_ST=0 then do;
if Loc_JC=1 then Location=3;
else if Loc_JC=0 then Location=0;
end;
end;
label SYM_RT="Respiratory tract symptoms"
As_COPD="Symptoms of Asthma/COPD"
SYM_Skin="skin symptoms"
SYM_GT="Gastrointestinal tract symptoms"
SYM_eyes="eyes Symptoms" 
SYM_liver="liver symptoms"
SYM_MS="Musculoskeletal system symptoms"
SYM_neuro="Neurological symptoms"
SYM_uro="Urogenital symptoms"
SYM_Hor="Hormonal symptoms"
SYM_CVS="Cardiovascular symptoms"
SYM_fat="Fatigue symptoms"
SYM_CA="Cancer symptoms"
SYM_leuk="Leukemia symptoms"
SYM_TS="Tissue sample symptoms"
SYM_OH="Other Health symptoms"
SYM_AL="Allergy symptoms"
SYM_nic="Nickel allergy symptoms"
SYM_co="Cobalt allergy symptoms"
SYM_OM="other metals allergy symptoms"
Loc_pol="Police station"
Loc_ST="service technician" 
Loc_JC="Job center" 
PR="Proof of allergy"
dust="dust allergy"
IT="Immune test"
cowork="Coworkers" 
M_expo="Metal exposure"
hyper="hypersensitivity"
smok="smoking status";
      
format SYM_RT As_COPD SYM_Skin SYM_GT SYM_eyes SYM_liver SYM_MS SYM_neuro SYM_uro 
              SYM_Hor SYM_CVS SYM_fat SYM_CA SYM_leuk SYM_TS SYM_OH SYM_AL SYM_nic SYM_co SYM_OM Loc_pol Loc_ST Loc_JC PR 
dust IT cowork M_expo hyper YN. Location Location. smok smoke.;
drop Resp_tract Asthma_COPD skin gi_tract eyes liver MS_system neurological uro_genital hormonal CVS fatigue  
                CA leukemia tissue_sample other_health allergy nickel cobalt evidence_test O_metals Immune_test hypersensitivity 
Metal_exposure;
run;

*frequency table for the variables*;
proc freq data=Ani.printer3;
tables Batch*(SYM_RT As_COPD SYM_Skin SYM_GT SYM_eyes SYM_liver SYM_MS SYM_neuro SYM_uro 
              SYM_Hor SYM_CVS SYM_fat SYM_CA SYM_leuk SYM_TS SYM_OH SYM_AL SYM_nic SYM_co SYM_OM 
Loc_pol Loc_ST Loc_JC PR dust IT cowork M_expo hyper smok);
run;

proc freq data=Ani.printer3; tables smok; 
run;

*Create yes and no format for device type and brand;
proc format library=ani;
value YNN 1="Yes"
 0="No"; run;
 *Create a dataset to differentiate Device type and brand, and label it*;
data Ani.printer4;
set Ani.printer3;
*scanner, copier, printer variables*;
	if find(UPCASE(device), 'COPIER', 1) >0 then type_copier=1; 
	if find(UPCASE(device), 'SCANN', 1)>0 then type_scanner=1; 
	if find(UPCASE(device), 'FAX', 1) >0 then type_fax=1; 
	if find(UPCASE(device), 'PRINTER', 1) >0 then type_printer=1; 
	*sounds like*;
  	if find(SOUNDEX(UPCASE(device)), SOUNDEX('PRINTER'), 1) >0 then type_printer=1; 
  	if find(SOUNDEX(UPCASE(device)), SOUNDEX('COPIER'), 1) >0 then type_copier=1; 
  	if find(SOUNDEX(UPCASE(device)), SOUNDEX('FAX'), 1) >0 then type_fax=1; 
   *inkjet, laser printers*; 
		if find(UPCASE(device), 'LASER', 1)>0 then type_printer=1; 
		if find(UPCASE(device), 'TONER', 1)>0 then type_printer=1; 
	*inkjet, laser printers alone;
		if find(UPCASE(device), 'INK', 1) >0 then type_inkjet=1; 
		if find(UPCASE(device), 'LASER', 1)>0 then type_laser=1; 
		if find(UPCASE(device), 'TONER', 1)>0 then type_laser=1; 
	*brand*;
		if find(UPCASE(device), 'XER', 1) >0 then brand_xerox=1; 
			else if find(UPCASE(device), 'ROX', 1) >0 then brand_xerox=1; 
		if find(UPCASE(device), 'KYO', 1) >0 then brand_kyo=1; *Kyocera mita*;
			else if find(UPCASE(device), 'MITA', 1) >0 then brand_kyo=1; *Kyocera mita*;
		if find(UPCASE(device), 'HP', 1) >0 then brand_HP=1; *Hewklett Packard*;
			else if find(UPCASE(device), 'H-P', 1) >0 then brand_HP=1; *Hewklett Packard*;
			else if find(UPCASE(device), 'PACKA', 1) >0 then brand_HP=1; *Hewklett Packard*;
		if find(UPCASE(device), 'CANON', 1) >0 then brand_Canon=1; *Canon*;
			else if find(UPCASE(device), 'CANNON', 1) >0 then brand_Canon=1; *Canon*;
		if find(UPCASE(device), 'SIEM', 1) >0 then brand_Siemens=1; *Siemens*;
         if find(UPCASE(device), 'EPSO', 1) >0 then brand_Epson=1; *Epson*;
		       if find(UPCASE(device), 'SONIC', 1) >0 then brand_Panasonic=1; *Panasonic*;
		if find(UPCASE(device), 'KOD', 1) >0 then brand_kodak=1; *KOD*;
		     if find(UPCASE(device), 'BROTHER', 1) >0 then brand_Brother=1; *Brother*;
		       if find(UPCASE(device), 'NEC', 1) >0 then brand_NEC=1; *NEC*;
        if find(UPCASE(device), 'APPLE', 1) >0 then brand_Apple=1; *Apple*;
		     if find(UPCASE(device), 'KONI', 1) >0 then brand_Konica=1; *Konica*;
		   else if find(UPCASE(device), 'MINO', 1) >0 then brand_Konica=1; *Konica*;
		     else if find(UPCASE(device), 'KM', 1) >0 then brand_Konica=1; *Konica*;
		if find(UPCASE(device), 'ALCA', 1) >0 then brand_Alcatel=1; *Alcatel*;  
		 if find(UPCASE(device), 'RICOH', 1) >0 then brand_Ricoh=1; *Ricoh*;
		 if find(UPCASE(device), 'LEXM', 1) >0 then brand_Lexmark=1; *Lexmark*;
		if find(UPCASE(device), 'SHARP', 1) >0 then brand_Sharp=1; *Sharp*;
		if find(UPCASE(device), 'TOSH', 1) >0 then brand_Toshiba=1; *Toshiba*;
		if find(UPCASE(device), 'FUJI', 1) >0 then brand_Fuji=1; *Fuji*;
		if find(UPCASE(device), 'TRIUMPH', 1) >0 then brand_Triumph=1; *Triumph*;
			else if find(UPCASE(device), 'ADLER', 1) >0 then brand_Triumph=1; *Triumph*;
		if find(UPCASE(device), 'BOSC', 1) >0 then brand_Bosch=1; *Bosch*;
			if find(UPCASE(device), 'OKI', 1) >0 then brand_OKI=1; *OKI*;
			if find(UPCASE(device), 'MURAT', 1) >0 then brand_Muratec=1; *Muratec*;
		if find(UPCASE(device), 'LANIER', 1) >0 then brand_Lanier=1; *Lanier*;
			if find(UPCASE(device), 'OCE', 1) >0 then brand_OCE=1; *OCE*;
		if find(UPCASE(device), 'JETF', 1) >0 then brand_Jetfax=1; *Jetfax*;

array BRDO [39] COPIER SCANN FAX PRINTER INKJET LASER XER ROX KYO MITA HP H_P PACKA CANON CANNON SIEM EPSO SONIC KOD BROTHER NEC APPLE KONI MINO KM ALCA RICOH LEXM SHARP 
                TOSH FUJI TRIUMPH ADLER BOSC OKI MURAT LANIER OCE JETF;

array BRDN [31] type_copier type_scanner type_fax type_printer type_inkjet type_laser brand_xerox brand_kyo  brand_HP  brand_canon  brand_Siemens  brand_epson brand_panasonic 
              brand_kodak brand_brother brand_NEC brand_Apple brand_Konica  brand_Alcatel brand_Ricoh brand_Lexmark brand_sharp brand_Toshiba brand_Fuji 
         brand_Triumph  brand_Bosch brand_OKI brand_Muratec brand_lanier brand_OCE brand_jetfax;
do i=1 to 39;
if upcase(BRDO [i])="YES" then BRDN [i]=1;
else if upcase(BRDO [i])="NO" then BRDN [i]=0; end;

label type_copier="Copier"
type_scanner="Scanner"
type_fax="Fax"
type_printer="Printer"
type_inkjet="Inkjet"
type_laser="Laser"
brand_xerox="Device Brand Xerox"
brand_kyo="Device Brand Kyocer Mita"
brand_HP="Device Brand HP"
brand_canon="Device Brand Canon"
brand_Siemens="Device Brand Siemens"
brand_epson="Device Brand Epson"
brand_panasonic="Device Brand Panasonic"
brand_kodak="Device Brand Kodak"
brand_brother="Device Brand brother"
brand_NEC="Device Brand NEC"
brand_Apple="Device Brand Apple"
brand_Konica="Device Brand Konica"
brand_Alcatel="Device Brand Alcatel"
brand_Ricoh="Device Brand Ricoh"
brand_Lexmark="Device Brand Lexmark"
brand_sharp="Device Brand Sharp"
brand_Toshiba="Device Brand Toshiba"
brand_Fuji="Device Brand Fuji"
brand_Triumph="Device Brand Triumph"
brand_Bosch="Device Brand Bosch"
brand_OKI="Device Brand OKI"
brand_Muratec="Device Brand Muratec"
brand_lanier="Device Brand Lanier"
brand_OCE="Device Brand OCE"
brand_jetfax="Device Brand Jetfax";
format  type_copier type_scanner type_fax type_printer type_inkjet type_laser brand_xerox brand_kyo brand_HP brand_canon brand_Siemens brand_epson brand_panasonic 
              brand_kodak brand_brother brand_NEC brand_Apple brand_Konica brand_Konica brand_Alcatel brand_Ricoh brand_Lexmark brand_sharp brand_Toshiba brand_Fuji 
         brand_Triumph brand_Bosch brand_OKI brand_Muratec brand_lanier brand_OCE brand_jetfax YNN.; 
run;
*Create a fregquency tables for device types and brands;
proc freq data=Ani.printer4;
tables type_copier type_scanner type_fax type_printer type_inkjet type_laser brand_xerox brand_kyo brand_HP brand_canon brand_Siemens brand_epson brand_panasonic 
              brand_kodak brand_brother brand_NEC brand_Apple brand_Konica brand_Konica brand_Alcatel brand_Ricoh brand_Lexmark brand_sharp brand_Toshiba brand_Fuji 
        brand_Triumph brand_Bosch brand_OKI brand_Muratec brand_lanier brand_OCE brand_jetfax; 
run;
*main one;
Data newprinters;
set Ani.printer4;
	if type_copier=1 then final_copier=1; 
	if final_copier=. then final_copier=0;
	if type_scanner=1 then other_printers=1; 
	if type_fax=1 then other_printers=1; 
	if type_inkjet=1 then other_printers=1;
	if other_printers=. then other_printers=0; 
	if type_printer=1 then laser_printer=1;
	if type_laser=1 then laser_printer=1;
	if laser_printer=. then laser_printer=0;
format final_copier other_printers laser_printer YNN.;
run;
proc freq data=newprinters;
tables final_copier other_printers laser_printer;
run;
Proc freq data=newprinters;
tables other_printers*final_copier*laser_printer/missing norow nocol nopercent;
run;
/*import test word bag - dust*/
proc import out=dust
datafile = "C:\Users\aayom\OneDrive\Printers\Situation_variable_codes.xlsx"
dbms=xlsx replace; 
getnames=yes;
sheet="dust";
run;
/*import test wordbag- space*/
proc import out=space
datafile = "C:\Users\aayom\OneDrive\Printers\Situation_variable_codes.xlsx"
dbms=xlsx replace; 
getnames=yes;
sheet="space";
run;
proc sql noprint;
select WordBag  /*taking from  Wordbag column in Excel (variable in our space dataset)*/
   into :spacebag separated by '*' /*put those values in a macro variable called spacebag*/
   from space; /*use this dataset (just imported)*/
quit;
proc sql noprint;
select WordBag  /*taking from  Wordbag column in Excel (variable in our dusr dataset)*/
   into :dustbag separated by '*' /*put those values in a macro variable called dustbag*/
   from dust; /*use this dataset (just imported)*/
quit;
%put &spacebag;
*%put %scan(&spacebag, 1, *);
%macro WordBag;
data space1;
set newprinters;
	*test space macro*;
	%let i=1;
	%do %while (%scan(&spacebag, &i, *) ne );
	*spaceWordBag=UPCASE("%scan(&spacebag, &i, *)");
	if find(UPCASE(situation), UPCASE("%scan(&spacebag, &i, *)"), 1) >0 then String_space=1; 
	if find(UPCASE(device), UPCASE("%scan(&spacebag, &i, *)"), 1) >0 then String_space=1; 
	%let i = %eval(&i + 1);
	%end;
run;
%mend WordBag;
%WordBag;

*defect*ventilation*space*time*change*resp*cardio*neurologic*GI*allergy*skin*headache*autoimmune*otherpeople*eyes;
/*expand the macro for all sheets in the situation variable file*/;
%let BagName=dust*defect*ventilation*space*time*change*resp*cardio*neurologic*GI*allergy*skin*headache*autoimmune*otherpeople*eyes;
%macro WordBag;
	%let bag=bag;
	%let j=1;
	%do %while (%scan(&BagName, &j, *) ne );
		%let topic=%scan(&BagName, &j, *);	
proc import out=&topic
			datafile = "C:\Users\aayom\OneDrive\Printers\Situation_variable_codes.xlsx"
			dbms=xlsx replace; 		getnames=yes;		sheet="&topic";
		run;
		proc format library=ani;
        value YNN 1="Yes"
        0="No"; run;
		proc sql noprint;
			select WordBag  /*taking from  Wordbag column in Excel (variable in our space dataset)*/
   			into : &bag&j  separated by '*' /*put those values in a macro variable called spacebag*/
   			from &topic; /*use this dataset (just imported)*/
		quit;
		%put &topic;
		%put &&bag&j;
	%let j= %eval(&j + 1);
	%end;
	data ani.devicea;
	set newprinters;
		%let j=1;
		%do %while (%scan(&BagName, &j, *) ne );
			%let topic= %scan(&BagName, &j, *);	
			%put TOPIC   &topic;
			%let i=1;
			%do %while (%scan(&&bag&j, &i, *) ne );
			if find(UPCASE(device), UPCASE("%scan(&&bag&j, &i, *)"), 1) >0 then String_&topic=1; 
			if find(UPCASE(situation), UPCASE("%scan(&&bag&j, &i, *)"), 1) >0 then String_&topic=1;
			if find(UPCASE(evidence_Doctor), UPCASE("%scan(&&bag&j, &i, *)"), 1) >0 then String_&topic=1;
			if find(UPCASE(other_Situation), UPCASE("%scan(&&bag&j, &i, *)"), 1) >0 then String_&topic=1;
			%put %scan(&&bag&j, &i, *);
			%let i = %eval(&i + 1);
			%end;
		%let j= %eval(&j + 1);
		%end;
			
		array dev [47] type_copier type_scanner type_fax type_printer type_inkjet type_laser brand_xerox brand_kyo brand_HP brand_canon brand_Siemens brand_epson brand_panasonic 
              brand_kodak brand_brother brand_NEC brand_Apple brand_Konica brand_Alcatel brand_Ricoh brand_Lexmark brand_sharp brand_Toshiba brand_Fuji 
         brand_Triumph brand_Bosch brand_OKI brand_Muratec brand_lanier brand_OCE brand_jetfax String_GI String_allergy String_autoimmune  String_cardio  String_change String_defect  String_dust  String_eyes   String_headache   String_neurologic      String_otherpeople        
String_resp     String_skin  String_space String_time  String_ventilation;
		do i=1 to 47;
        if dev [i]=. then dev [i]=0;
end;
label String_GI="Gastro intestinal words"
String_allergy="allergy related words"
String_autoimmune="Autoimmune related words"
String_cardio="Cardiovascular words"
String_change="Change in situation related words"
String_defect="defect related words"
String_dust="dust words"
String_eyes="eyes related words"
String_headache="headache related words"
String_neurologic="neurologic words"
  String_otherpeople="otherpeople words"
String_resp="respiratory words"
String_skin="skin related woprds"
String_space="space words"
String_time="time related words"
String_ventilation="ventilation words";
  format String_GI String_allergy String_autoimmune String_cardio String_change String_defect String_dust String_eyes  String_headache String_neurologic 
  String_otherpeople String_resp  String_skin  String_space String_time String_toner  String_ventilation YNN.;
run;
	proc freq data=ani.devicea;
		tables 		%let j=1;		
		%do %while (%scan(&BagName, &j, *) ne );
			%let topic=%scan(&BagName, &j, *);			String_&topic
		%let j= %eval(&j + 1); %end; ;
	run;
%mend WordBag;
%WordBag;
proc contents data=ani.devicea; run;
*Tabulate symptoms in the table*;
PROC TABULATE data=ani.devicea;
 class SYM_RT As_COPD SYM_Skin SYM_GT SYM_eyes SYM_liver SYM_MS SYM_neuro SYM_uro 
               SYM_Hor SYM_CVS SYM_fat SYM_CA SYM_TS SYM_OH SYM_AL SYM_nic SYM_co SYM_OM Loc_pol Loc_ST Loc_JC 
               PR dust IT cowork M_expo hyper/ missing;
 table SYM_RT As_COPD SYM_Skin SYM_GT SYM_eyes SYM_liver SYM_MS SYM_neuro SYM_uro 
               SYM_Hor SYM_CVS SYM_fat SYM_CA SYM_TS SYM_OH SYM_AL SYM_nic SYM_co SYM_OM Loc_pol Loc_ST Loc_JC 
               PR dust IT cowork M_expo hyper, all*n all*ColPctn;
run; 

PROC TABULATE DATA=Ani.devicea;
 class type_copier type_scanner type_fax type_printer type_inkjet type_laser brand_xerox brand_kyo brand_HP brand_canon brand_Siemens brand_epson brand_panasonic 
              brand_kodak brand_brother brand_NEC brand_Apple brand_Konica brand_Alcatel brand_Ricoh brand_Lexmark brand_sharp brand_Toshiba brand_Fuji 
         brand_Triumph brand_Bosch brand_OKI brand_Muratec brand_lanier brand_OCE brand_jetfax;
 TABLE type_copier type_scanner type_fax type_printer type_inkjet type_laser brand_xerox brand_kyo brand_HP brand_canon brand_Siemens brand_epson brand_panasonic 
              brand_kodak brand_brother brand_NEC brand_Apple brand_Konica brand_Alcatel brand_Ricoh brand_Lexmark brand_sharp brand_Toshiba brand_Fuji 
         brand_Triumph brand_Bosch brand_OKI brand_Muratec brand_lanier brand_OCE brand_jetfax, all*n all*ColPctn;
RUN; 
proc tabulate data=ani.devicea;
class String_GI String_allergy String_autoimmune String_cardio String_change String_defect String_dust  String_eyes   String_headache  
String_neurologic String_otherpeople String_resp  String_skin  String_space String_time String_toner  String_ventilation/ missing; 
table String_GI String_allergy String_autoimmune  String_cardio String_change String_defect  String_dust  String_eyes   String_headache   String_neurologic      String_otherpeople        
String_resp String_skin  String_space String_time String_toner String_ventilation, all*n all*ColPctn;
run; 
proc freq data=ani.devicea;
tables String_resp*SYM_RT/ missing Nocol Nopercent Norow ; run;
proc freq data=ani.devicea;
tables String_GI*SYM_GT/ missing Nocol Nopercent Norow ; run;
proc freq data=ani.devicea;
tables String_cardio*SYM_CVS/ missing Nocol Nopercent Norow ; run;
proc freq data=ani.devicea;
tables String_eyes*SYM_eyes/ missing Nocol Nopercent Norow ; run;
proc freq data=ani.devicea;
tables String_neurologic*SYM_neuro/ missing Nocol Nopercent Norow ; run;
proc freq data=ani.devicea;
tables String_skin*SYM_skin/ missing Nocol Nopercent Norow ; run;
proc freq data=ani.devicea;
tables String_allergy*SYM_AL/ missing Nocol Nopercent Norow ; run;
proc freq data=ani.devicea;
tables String_dust*dust/ missing Nocol Nopercent Norow ; 
format dust;
run;
proc freq data=ani.devicea;
tables String_otherpeople*cowork/ missing Nocol Nopercent Norow ; run;
*code to extract information from ID number*; 
proc format;
value status 
1="Alive"
2="Deceased"
9="Unknown";
*output for profession, age, and vital status;
Data ID;
set Ani.devicea;
*year- 2nd word, seperated by-*;
Survey_year=input(scan(ID,2,"-"), 4.0);
*profession-5th word, seperated by-*;
profession=scan(ID,5,"-");
if profession="xxx" then profession="";
if profession not in ("OFF", "POL", "JOB", "SVT", "IT", "PRW", "COP", "PED", "MED", "OTH", "PEN", "IT", "OFFO", "OFFC", "OFFM", "POLO", 
	"POLM", "JOBC", "JOBM", "SVTC", "SVTM", "ITC", "PRWC", "COPC", "PEDO", "PEDM", "MEDC", "MEDM", "OTHC", "OTHM", "PENC", "PROF", "ITC") then prof_flag=l;
*country - 6th word, seperated by -*;
country=scan(ID,6,"-");
*vital status - 7th word, seperated by -*;
if scan(ID,7,"-")="A" then vital_status=1;
else if scan(ID,7,"-")="D" then vital_status=2;
else if scan(ID,7,"-")="N" then vital_status=9;
format Vital_status status.;
Age=Survey_year-Birth_year;
run;
proc freq data=ID;
tables profession survey_year country;
run;
%let Profession= OFF*POL*JOB*SVT*ITC*PRW*COP*PED*MED*OTH*PEN*PRT*STUD;
Data Profess;
set ID;*use substr function to extract 1st 3 letters - profession without level)*;
Professionexp= substr(Profession,1, 3);
run;
proc freq data=Profess;
tables professionexp;
run;
%let Profession= OFFC*JOBC*SVTC*ITC*PRWC*COPC*MEDC*OTHC*PENC*PEDC*POLC*PRTC;
*categorizing profession into clerks, Service&copy tech, and others;
Data clerks;
set Profess;
if scan(ID,5,"-")="OFFC" then clerical_officers=1;
if scan(ID,5,"-")="JOBC" then clerical_officers=1;
if scan(ID,5,"-")="ITC" then clerical_officers=1;
if scan(ID,5,"-")="MEDC" then clerical_officers=1;
if scan(ID,5,"-")="OTHC" then clerical_officers=1;
if scan(ID,5,"-")="PENC" then clerical_officers=1;
if scan(ID,5,"-")="PEDC" then clerical_officers=1;
if scan(ID,5,"-")="POLC" then clerical_officers=1;
if scan(ID,5,"-")="PRTC" then clerical_officers=1;
if clerical_officers=. then clerical_officers=0;
if scan(ID,5,"-")="SVTC" then service_tech=1;
if scan(ID,5,"-")="PRWC" then service_tech=1;
if scan(ID,5,"-")="COPC" then service_tech=1;
if scan(ID,5,"-")="TONER" then service_tech=1;
if service_tech=. then service_tech=0;
if scan(ID,5,"-") in ("OFF", "POL", "JOB", "SVT", "IT", "PRW", "COP", "PED", "MED", "OTH", "PEN", "IT", "OFFO", "OFFM", "POLO", 
	"POLM", "JOBM", "JOBO", "SVTM", "PEDO", "PEDM", "MEDM", "OTHM", "OTHC", "PROF", "STUD", "PENO", "OTHO", "PENx", "COPM", "PENM", "offC", 
	"offO", "PEDx", "STUDC", "MEDx", "OTHx", "OTHX", "PENM", "PRWM", "PENX", "JUDG", "COPX", "OffO", "OffC", "MEDO", "POLx", "OFFx", "OFFX") then other_officers=1;
if other_officers=. then other_officers=0;
format clerical_officers service_tech other_officers YN.;
run;
proc freq data=clerks;
tables clerical_officers service_tech other_officers;
run;
proc format;
value Profess
1="other officers"
2="service technicians"
3="clerks";
run;
Data newProfess;
set clerks;
if other_officers=1 then Profession_1=1;
if service_tech=1 then Profession_1=2;
if clerical_officers=1 then Profession_1=3;
FORMAT profession_1 profess.;
run;
proc print data=newProfess;
var ID; 
where Profession_1=.;
run;
proc freq data=newProfess;
tables Profession_1;
run;
*Sample of how to Generate the final output for only dust*;
Data final;
set ani.devicea;
if string_dust=1 then final_dust=1;
if dust=1 then final_dust=1;
if final_dust= . then final_dust=0;
format final_dust YNN.;
run;
proc freq data=final;
tables final_dust; 
run;
proc univariate data=ID;
var Age; run;
*Categorize age*;
proc format;
value Age_cat
1="15 to 45 years old"
2="46 to 65 yeasrs old"
3="66 years old and over";
run;
proc format;
value Age_catt
1="15 to 49 years old"
2="50 and older";
run;
*for raw p-value, delete after;
data Age1;
set clerks;
Age_cat1=put(Age, Age_cat.);
run;
*main code;
data Age1;
set newProfess;
Age_cat1=put(Age, Age_catt.);
run;
data Ani_age;
set Age1;
if 15<=Age_cat1<=45 then Age_cat=1;
else if 46<=Age_cat1<=65 then Age_cat=2;
else if Age_cat1=>66 then Age_cat=3;
label Age_cat="categorical Age";
format Age_cat Age_cat.;
run;
proc freq data=Ani_age;
tables Age_cat; run;
*new age category, combining 46 years with 66 and older;
data Ani_age2;
set Ani_age;
if 15<=Age_cat1<=49 then Age_catty=1;
if 50<=Age_cat1<=65 then Age_catty=2;
if Age_cat1=>66 then Age_catty=2;
label Age_catty="new age category";
format Age_catty Age_catt.;
run;
proc freq data=Ani_age2;
tables Age_catty; run;
proc freq data=ani.devicea;
tables sex;
run;
Proc format;
value sexes
0="Female"
1="Male";
run;
Data Sexs;
set Ani_age2;
if sex="m" then gender=1;
else if sex="f" then gender=0;
format gender sexes.;
run;
Proc freq data=Sexs;
tables gender;
run;
*change the set after use, back to ani_age2;

*creating array for the final output;
data finaloutput;
set Sexs;
*output for respiratory*;
	if String_resp=1 then final_resp=1;
	if SYM_RT=1 then final_resp=1;
	if final_resp= . then final_resp=0;
*output for GI tract*;
	if String_GI=1  then final_GI=1; 
	if SYM_GT=1 then final_GI=1; 
	if final_GI= . then final_GI=0; 
   *cardiovascular*;
		if String_cardio=1 then final_cardio=1; 
		if SYM_CVS=1 then final_cardio=1; 
		if final_cardio= . then final_cardio=0; 
	*EYES;
		if String_eyes=1 then final_eyes=1; 
		if SYM_eyes=1 then final_eyes=1; 
		if final_eyes= . then final_eyes=0; 
	*neurologic*;
		if String_neurologic=1 then final_neuro=1; 
		if SYM_neuro=1 then final_neuro=1; 
		if final_neuro= . then final_neuro=0; 
	*skin;
		if String_skin=1 then final_skin=1; 
		if SYM_skin=1 then final_skin=1; 
		if final_skin= . then final_skin=0; 
	*allergy;
		if String_allergy=1 then final_allergy=1; 
		if SYM_AL=1 then final_allergy=1; 
		if final_allergy= . then final_allergy=0; 
	*dust visible;
		if string_dust=1 then final_dust=1;
		if dust=1 then final_dust=1;
		if final_dust= . then final_dust=0;
	*Fatigue;
		if SYM_fat=1 then final_fat=1;
		if final_fat= . then final_fat=0;
	*Cancer;
		if SYM_CA=1 then final_CA=1;
		if final_CA= . then final_CA=0;

	array HEALT [18] String_resp SYM_RT String_GI SYM_GT String_cardio SYM_CVS String_eyes SYM_eyes String_neurologic SYM_neuro String_skin SYM_skin
					String_allergy SYM_AL SYM_CA SYM_fat string_dust dust;
	array COMP [10] final_resp final_GI final_cardio final_eyes final_neuro final_skin final_allergy final_dust final_fat final_CA;
	do i=1 to 18;
end;
format final_resp final_GI final_cardio final_eyes final_neuro final_skin final_allergy final_dust final_fat final_CA YNN.;
run;
proc freq data=finaloutput; *print out the final output table;
tables final_resp final_GI final_cardio final_allergy final_fat final_eyes final_skin final_CA final_neuro As_COPD SYM_liver SYM_uro SYM_Hor hyper SYM_nic SYM_co ; 
run;
proc freq data=finaloutput; *print out the final output table;
tables final_dust Profession_1 laser_printer final_copier other_printers Age_catty sex smok vital_status country string_defect string_ventilation; 
run;
proc print data=ani.devicea; var device situation; where string_dust=1 and dust=0; run;
*sample calculating odds ratio;
proc freq data=finaloutput;
tables final_GI*final_dust/nocum nopercent cmh chisq;
run;
*sample calculating odds ratio;
proc freq data=finaloutput;
tables Age_cat*final_resp/nocum nopercent cmh chisq;
run;
*example proc logistic;
proc logistic data=finaloutput desc;
class laser_printer (ref=first) final_dust (ref=first) smok (ref="Non-smoker");
model final_resp=laser_printer final_dust smok;
run;
proc logistic data=finaloutput desc;
class final_dust(ref=first);
model final_resp=final_dust;
run;
*trying out proc logistic
proc logistic data=finaloutput desc;
*class clerical_officers(ref=first);
*model final_resp=clerical_officers other_officers;
*run;
proc freq data=finaloutput;
tables final_CA*Age_cat/ missing Nocol Nopercent Norow ; run;



%let HealthA=final_resp*final_GI*final_cardio*final_eyes*final_neuro*final_skin*final_allergy*As_COPD*SYM_liver*SYM_uro*SYM_Hor*final_fat*final_CA*SYM_nic*SYM_co*hyper;
%let Exp=final_dust*Age_catty*sex;
%macro HealthEff;
%do i=1 %to 16;
%do j=1 %to 3;
proc logistic data=finaloutput desc;
class %scan (&Exp, &j, *)(ref=first);
model %scan(&HealthA, &i, *)= %scan (&Exp, &j, *);
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;

#only defect
%let HealthA=final_resp*final_GI*final_cardio*final_eyes*final_neuro*final_skin*final_allergy*As_COPD*SYM_liver*SYM_uro*SYM_Hor*final_fat*final_CA*SYM_nic*SYM_co*hyper;
%let Exp=string_defect;
%macro HealthEff;
%do i=1 %to 16;
%do j=1 %to 1;
proc logistic data=finaloutput desc;
class %scan (&Exp, &j, *)(ref=first);
model %scan(&HealthA, &i, *)= %scan (&Exp, &j, *);
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;



*unadjusted OR ratio for profession;
%let HealthA=final_resp*final_GI*final_cardio*final_eyes*final_neuro*final_skin*final_allergy*As_COPD*SYM_liver*SYM_uro*SYM_Hor*final_fat*final_CA*SYM_nic*SYM_co*hyper;
%let Exp=Profession_1;
%macro HealthEff;
%do i=1 %to 16;
%do j=1 %to 1;
proc logistic data=finaloutput desc;
class Profession_1 (ref="other officers");
model %scan(&HealthA, &i, *)= Profession_1;
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;

*unadjusted OR for smoking;
%let HealthA=final_resp*final_GI*final_cardio*final_eyes*final_neuro*final_skin*final_allergy*As_COPD*SYM_liver*SYM_uro*SYM_Hor*final_fat*final_CA*SYM_nic*SYM_co*hyper;
%let Exp=smok;
%macro HealthEff;
%do i=1 %to 16;
%do j=1 %to 1;
proc logistic data=finaloutput desc;
class smok(ref="Non-smoker");
model %scan(&HealthA, &i, *)= smok;
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;

*Adjusted OR for device type and dust;
%let HealthA=final_resp*As_COPD*final_allergy*SYM_nic*SYM_co*final_fat*final_eyes*final_skin*final_CA*final_cardio*final_GI*final_neuro*SYM_liver*SYM_uro*SYM_Hor*hyper;
%let Exp=final_dust*string_defect;
%macro HealthEff;
%do i=1 %to 16;
%do j=1 %to 2;
proc logistic data=finaloutput desc;
class %scan (&Exp, &j, *)(ref=first) Age_catty (ref=first) sex (ref=first) smok (ref="Non-smoker");
model %scan(&HealthA, &i, *)= %scan (&Exp, &j, *) Age_catty sex smok;
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;

*adjusted odds ratio for profession exposure for the health outcomes;
ods output "Odds Ratios"=ORCI;
%let HealthA=final_resp*As_COPD*final_allergy*SYM_nic*SYM_co*final_fat*final_eyes*final_skin*final_CA*final_cardio*final_GI*final_neuro*SYM_liver*SYM_uro*SYM_Hor*hyper;
%let Exp=Profession_1;
%macro HealthEff;
%do i=1 %to 16;
%do j=1 %to 1;
proc logistic data=finaloutput desc;
class %scan (&Exp, &j, *)(ref="other officers") Age_catty (ref=first) sex (ref=first) smok (ref="Non-smoker");
model %scan(&HealthA, &i, *)= %scan (&Exp, &j, *) Age_catty sex smok;
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;
data ORCI;set ORCI; 
effect=upcase(effect); 
run;
proc freq data=ORCI;
run;

ods output "odds ratios"=ORCi;
proc logistic data=finaloutput desc;
model final_resp=final_dust string_defect Profession_1;
run;
proc freq data=ORCi;
run;

ods output "Odds Ratios"=ORCIII; 
proc logistic data=finaloutput descending;
model final_resp=Profession_1 final_dust string_defect smok Age_catty;
run;


Proc contents data=finaloutput;
run;

*using macro for odds ratio for all exposures and symptoms without adjusting for confounders; 
%let HealthA=final_resp*final_GI*final_cardio*final_eyes*final_neuro*final_skin*final_allergy*As_COPD*SYM_liver*SYM_uro*SYM_Hor*final_fat*final_CA*SYM_OH*SYM_nic*SYM_co*SYM_OM*hyper;
%let Exp=final_dust*String_defect*String_ventilation*service_tech*clerical_officers*copy_tech*other_officers*final_copier*other_printers*laser_printer;
%macro HealthEff;
%do i=1 %to 18;
%do j=1 %to 10;
proc logistic data=finaloutput desc;
class %scan (&Exp, &j, *)(ref=first);
model %scan(&HealthA, &i, *)= %scan (&Exp, &j, *) Age_catty sex smok;
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;


*odds ratio without adjustment: for dust exposure and 6 dependent variables;
%let HealthA=final_resp*final_GI*final_cardio*final_allergy*SYM_fat*SYM_CA;
%let Exp=final_dust;
%macro HealthEff;
%do i=1 %to 6;
%do j=1 %to 1;
proc logistic data=finaloutput desc;
class %scan (&Exp, &j, *)(ref=first);
model %scan(&HealthA, &i, *)= %scan (&Exp, &j, *);
run; quit;
%end;
%end;
%mend HealthEff;
%HealthEff;

*3 Device variables*;
%let HealthA=final_resp*final_GI*final_cardio*final_allergy*final_fat*final_CA;
%let Exp=other_printers*final_copier*laser_printer;
%macro HealthEff;
%do i=1 %to 6;
proc logistic data=finaloutput desc;
class laser_printer (ref=first) final_copier (ref=first) other_printers (ref=first) Age_catty (ref=first) sex (ref=last) smok (ref="Non-smoker");
model %scan(&HealthA, &i, *)= laser_printer final_copier other_printers Age_catty sex smok;
run; quit;
%end;
%mend HealthEff;
%HealthEff;
