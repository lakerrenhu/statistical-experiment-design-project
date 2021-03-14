*problem 1;
data sim;
input patient week treat$ mqs;
datalines;
1 1 B 2.92
1 2 E 2.43
1 3 A 2.19
1 4 C 2.71
1 5 D 2.71
2 1 D 2.86
2 2 A 1.64
2 3 E 3.02
2 4 B 3.03
2 5 C 3.03
3 1 E 1.97
3 2 B 2.50
3 3 C 2.47
3 4 D 2.65
3 5 A 1.89
4 1 A 1.99
4 2 C 2.39
4 3 D 2.37
4 4 E 2.33
4 5 B 2.71
5 1 C 2.64
5 2 D 2.31
5 3 B 2.44
5 4 A 1.89
5 5 E 2.78
;
*ods graphics on/imagefmt=png border=off width =4.0 in height =3.0 in;
ods graphics on;
proc glm plots=diagnostics(unpack);
class patient week treat;
model mqs=patient week treat;
estimate 'A vs Others' treat -4 1 1 1 1;
means treat/snk;
lsmeans treat / pdiff adjust = tukey;
run;
ods graphics off;

*problem 2;
* Create 2^(4 -1) design in standard order ;
data design ;
do x3 = -1 to 1 by 2;
   do x2 = -1 to 1 by 2;
      do x1 = -1 to 1 by 2;
      A= x1 ; B= x2 ; C= x3 ; D= A*B*C;
      output ;
      end ;
   end ;
end ;
keep A B C D  ;
*proc print ; *run ;

data process ;
input s @@;
datalines;
4.70 14.67 1.71 3.73 9.47 7.61 .15 4.78
run;
data yeast; merge design process;
proc glm data=yeast;
model s = A B C D A*B A*C A*D;
ods output ParameterEstimates=sol;
run;
data nplot ; set sol ;
estimate = estimate ;
if _n_ >1; drop StdErr tValue Probt ;
* proc rank calculates normal scores for parameter estimates ;
proc rank data = nplot out = nplots normal = blom ; var estimate ;
ranks zscore ;
data nplots ; set nplots ;
if abs ( zscore ) < =1.2 then parameter = '';
run ;
ods graphics on ;
proc sgplot data = nplots ;
scatter x= zscore y = estimate / datalabel = parameter ;
xaxis label = 'Normal Scores';
yaxis label = 'Regression Coefficient';
run ;
ods graphics off ;

proc glm data=yeast;
model s = A B D A*C;
run;


proc glm data=yeast ;
model s = A B D B*D;
run;


proc format;
value blevs -1='20' 1='30';
value dlevs -1='50 RPM' 1='100 RPM';
proc sort data=yeast; by B D;
proc means data=yeast noprint;
by B D;
var s;
output out=bdmeans mean=pmean;
run;
ods graphics on/imagefmt=png border=off width =4in height =3in;;
proc sgplot data =bdmeans;
series x=B y= pmean/ group = D markers;
xaxis type=discrete label='Temperature(B)';
format B blevs. D dlevs. ;
keylegend/ title='Agitation(D)';
yaxis label ='Dry Weight of Levan';
run ;
ods graphics off;
