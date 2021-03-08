Applying data specifications contained in rows of a table

    Five Solutions

        a. Call execute (fastest)
           Bartosz Jablonski yabwon@gmail.com
        b. do_over datastep  (equally fast?)
        c. do_over sql array (equally fast?)
        d. dosubl (allows error checking)
        e. posters solution (slow)
           https://communities.sas.com/t5/user/viewprofilepage/user-id/173881


I think this is important because configuration and meta tables play an important
role in building databases.

I am not a fan of 'call execute' because it reminds me of missing datastep
symbolic processing. Shared storage with other processes (dosubl, Pyrhon and R)
is the correct answer?

github
https://tinyurl.com/72ewpxds
https://github.com/rogerjdeangelis/utl-applying-data-specifications-contained-in-rows-of-a-table

inspred by
https://tinyurl.com/jc7c38yp
https://communities.sas.com/t5/SAS-Programming/Iterating-Specific-Rows-in-CALL-EXECUTE/m-p/724353

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
      input name $;
cards;
Jack
James
John
;
run;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
           _ _
  ___ __ _| | | __  _____  __ _
 / __/ _` | | | \ \/ / _ \/ _` |
| (_| (_| | | |  >  <  __/ (_| |
 \___\__,_|_|_| /_/\_\___|\__, |
                             |_|
;

data want;
run;

data _null_;
  call execute('data want; set want;');
  do until(eof);
    set have end=eof;
    call execute(cats(name,'=1;'));
  end;
  call execute('run;');
  stop;
run;quit;


Up to 40 obs WORK.WANT total obs=1

Obs    JACK    JAMES    JOHN

 1       1       1        1

*    _                               _        _     _
  __| | ___     _____   _____ _ __  | |_ __ _| |__ | | ___
 / _` |/ _ \   / _ \ \ / / _ \ '__| | __/ _` | '_ \| |/ _ \
| (_| | (_) | | (_) \ V /  __/ |    | || (_| | |_) | |  __/
 \__,_|\___/___\___/ \_/ \___|_|     \__\__,_|_.__/|_|\___|
          |_____|
;

proc datasets lib=work nolist;
  delete want;
run;quit;

%array(nms,data=have,var=name);

data want;
  %do_over(nms,phrase=%str(
      ?=1;));
run;quit;

/*
Up to 40 obs WORK.WANT total obs=1

Obs    JACK    JAMES    JOHN

 1       1       1        1
*/

*    _                                         _
  __| | ___     _____   _____ _ __   ___  __ _| |
 / _` |/ _ \   / _ \ \ / / _ \ '__| / __|/ _` | |
| (_| | (_) | | (_) \ V /  __/ |    \__ \ (_| | |
 \__,_|\___/___\___/ \_/ \___|_|    |___/\__, |_|
          |_____|                           |_|
;

proc datasets lib=work nolist;
  delete want;
run;quit;

%array(nms,data=have,var=name);

proc sql;
  create
     table want as
  select
     %do_over(nms,phrase=
       1 as ?, between=comma)
  from
     sashelp.class(obs=1)
;quit;

*    _                 _     _
  __| | ___  ___ _   _| |__ | |
 / _` |/ _ \/ __| | | | '_ \| |
| (_| | (_) \__ \ |_| | |_) | |
 \__,_|\___/|___/\__,_|_.__/|_|

;

proc datasets lib=work nolist;
  delete want;
run;quit;

data want;
run;quit;

data log;
  set have;
  call symputx('nam',name);
  rc=dosubl('
     data want;
        set want;
        &nam = 1;
     run;quit;
     %let cc=&syserr;
     %let retnam=&nam;
  ');
   retname=symget('retnam');
   if symgetn('cc')=0 then status = catx(" ","**** variable",name,"added to want  ****");
   else status=catx(" ","**** variable",name,"not added to want  ****");
   output;
run;quit;


/*
Up to 40 obs WORK.LOG total obs=3

Obs    NAME     RC    RETNAME                    STATUS

 1     Jack      0     Jack      **** variable Jack added to want  ****
 2     James     0     James     **** variable James added to want  ****
 3     John      0     John      **** variable John added to want  ****


Up to 40 obs WORK.WANT total obs=1

Obs    JACK    JAMES    JOHN

 1       1       1        1
*/

*                         _
  ___     _ __   ___  ___| |_ ___ _ __ ___
 / _ \   | '_ \ / _ \/ __| __/ _ \ '__/ __|
|  __/_  | |_) | (_) \__ \ ||  __/ |  \__ \
 \___(_) | .__/ \___/|___/\__\___|_|  |___/
         |_|
;
data _null_;
      set have;
      call execute("data want;set want;"||name||"=1;run;");
run;

Up to 40 obs from WANT total obs=1

Obs    JACK    JAMES    JOHN

 1       1       1        1

*               _
  ___ _ __   __| |
 / _ \ '_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

;


