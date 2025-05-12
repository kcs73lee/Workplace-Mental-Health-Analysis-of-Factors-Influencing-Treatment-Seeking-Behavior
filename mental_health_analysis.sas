*ods html file="~/mental_health_report.html" style=statistical;
*ods powerpoint file="~/mh_report.pptx" style=PowerPointLight;
ods pdf file="~/mental_health_analysis.pdf" style= Rtf
	notoc
	startpage= now;

options orientation=portrait
        leftmargin=1in rightmargin=1in;
        
ods escapechar='^';
title "Mental Health Analysis in Tech Industry";
title3 "^S={font_size=8pt}Author: Saelee, KC";
title4 "^S={font_size=8pt}Date: %sysfunc(today(),MMDDYY10.)";
footnote1 j=c "Page ^{thispage} of ^{lastpage}";

ods text = " ";
ods text="^S={font_weight=bold}Background:";
ods text = " ";
ods text= "Mental health issues in the tech industry are often overlooked due 
to stigma and high performance expectations. This dataset contains responses 
from a 2014 survey of tech employees about mental health awareness, 
support, and treatment in their workplaces.";
ods text= " ";

ods text= "^S={font_weight=bold}Project Goal:";
ods text = " ";
ods text= "The goal is to analyze trends and patterns in mental health disclosures, support 
availability, and openness among employees in the tech industry to identify 
areas for policy improvement.";
ods text= " ";

ods text= "^S={font_weight=bold}Objective:";
ods text = " ";
ods text= "Our objective is to determine what factors (age, gender, company size, awareness of benefits, etc.) 
are associated with whether an employee seeks mental health treatment";

ods text= " ";
ods text= "^S={font_weight=bold}Analysis:";
ods text = " ";
ods text= "First, let's load our data file";
filename mhdata '/home/u64224016/mh_in_tech_survey.csv';
proc import datafile= mhdata
    out= mhdat
    dbms= csv
    replace;
    getnames= yes;
*run;

ods text= "Then we'll look at a snapshot view of a few variables (columns) and observations (rows)";
proc print data= mhdat(obs=10);
var Age Gender Country Treatment no_employees;
run;

ods pdf startpage=now gtitle;
options orientation=portrait;
title1 ' ';

ods text= "We'll look into the data structure as well (variables, rows, datatypes, etc.) and use this
information to identify where data preprocessing and cleaning is needed.";
ods select Variables;
proc contents data= mhdat;
run;
ods select default;

ods text= "Before we go to the data analysis step, we need to check for missing rows in the 
data and return rows with at least 1 missing data. Depending on the what values are missing, we need to handle
them accordingly.";
data missrows;
set mhdat;
if cmiss(of _all_) >0;
run;

/*ods text= "Print to show the missing values by column"; 
proc print data= missrows;
run;*/
/*ods text= " ";
ods text= "Below are the tables showing any missing values in numeric columns";
proc means data=mhdat n nmiss;
run;

data missing_counts;
  set mhclean;
  missing_per_row = cmiss(of _all_);
run;

proc freq data=missing_counts;
  tables missing_per_row;
run;

ods text= " ";
ods text= "Show any missing values in numeric or character columns";
ods text= "There are a total of 1259 rows so we should be able to see how many missing values there are in the following table";
proc format;
    value $missfmt ' '='missing' other='not missing';
    value missfmt  . ='missing' other='not missing';
run;

proc freq data=mhdat;
    format _CHAR_ $missfmt. _NUMERIC_ missfmt.;
    tables _ALL_ / missing nocum nopercent;
run;*/

ods text= " ";
ods text= "Since the only missing value is only one record and it is in the comments column, we do not need to remove the record
or change it in any way and can proceed to the next data cleaning step.";

ods text= " ";
ods text= "All rows should be unique so we'll also remove duplicated rows and display the results";
proc sort data= mhdat noduprecs out= mhdat;
  by _all_;
run;

ods text= " ";
ods text= "Now we'll check the 'Gender' column and see whether we need to do any data cleaning there.";

proc freq data=mhdat noprint;
  tables Gender / out=gender_counts;
run;

proc sgplot data=gender_counts;
  vbar Gender / response=COUNT datalabel;
  yaxis label="Count";
  xaxis label="Gender";
  title "Count of Each Gender Category";
run;

ods text= " ";
ods text= "We notice from the data that there are many different values in the 'Gender' column.
For example, there are values such as 'm', 'woman' and 'transgender'. Since the other variables represent 
such as small size compared to 'Male' and 'Female' we will  do our best in classifying the gender column 
so all words starting with the letter 'm' is 'Male' amd letter 'f' is 'female'. 
For the sake of simpifying the analysis, everything else will be classfied as 'Other'. However, we should be respectful 
of cognizant of people's view on gender and not marginalize it.";

data mhclean;
    set mhdat;
    if upcase(substr(Gender, 1, 1)) = "M" then Gender = "Male";
    else if upcase(substr(Gender, 1, 1)) = "F" then Gender = "Female";
    else Gender = "Other";
run;

ods text= " ";
ods text= "Next, we'll look into the 'Age' column. The table is showing that there are negative ages and ages 
as high as 9 million! Since age can only start at 0 years old and no human in recorded history has live past age 130, 
we need to filter out appropriate ages";

proc means data=mhdat min max;
  var Age;
run;

ods text= " ";
ods text= "Here we  filter out odd ages such 
as negative numbers and very high unlrealistic numbers";

data mhclean;
    set mhclean;
    where Gender in ('Male', 'Female');
    if Age > 17 and Age < 73;
run;

proc means data=mhclean min max;
  var Age;
run;

ods text= " ";
ods text= "There are many ages and it is a numeric variable. To answer the question of whether there are
significant differences in ages, one approach to answer this question is to bin the ages into categorical groups";

data mhclean;
  set mhclean;
  length Age_Group $12;
  if Age < 20 then Age_Group = '<20';
  else if Age < 30 then Age_Group = '20-29';
  else if Age < 40 then Age_Group = '30-39';
  else if Age < 50 then Age_Group = '40-49';
  else if Age < 60 then Age_Group = '50-59';
  else Age_Group = '60+';
run;

ods text= " ";
ods text= "Now we visualize the Age groups to see how it looks";
proc freq data=mhclean noprint;
  tables Age_Group / out=age_counts;
run;

proc sgplot data=age_counts;
  vbar Age_Group / response=COUNT datalabel;
  yaxis label="Count";
  xaxis label="Age Group";
  title "Distribution of Respondents by Age Group";
run;


*proc print data= mhclean;
*run;

/*ods text= "Let's view some distributiosn of the demographics we have in this survey including
age range and gender. This would give us an idea of what we're looking";*/

/*proc sgplot data=mhclean;
    histogram Age/ binwidth=1 binstart=18;
    xaxis label="Age (Years)";
    title "Age Distribution of Survey Respondents";
run;


proc sgplot data= mhclean;
    vbar Gender;
    title "Gender Distribution of Survey Respondents";
run;*/

/*proc sgplot data= mhclean;
    vbar Country;
    title "Country Distribution of Survey Respondents";
run;*/

ods text =" ";
ods text= "Now that are dataset is cleaned, we are ready to proceed with the analysis";
/*ods text= "Let's graph the overall number of employees who are aware of mental health resources from the company";

proc freq data=mhclean;
    tables  Benefits / out=benefits_freq;
run;

proc sgplot data= benefits_freq;
    vbar Benefits / response=COUNT datalabel;
    title "Awareness of Mental Health Benefits";
run;

ods text =" ";
ods text= "Next, let's display number of employees reported to recieve treatment to
get an idea of who are actually recieving treatment";

proc sgplot data=mhclean;
    vbar treatment / datalabel;
    title "Employees Who Received Mental Health Treatment";
run;

ods text =" ";
ods text= "Finally we'll see if there are percieved consequences of discussing mental health.
This could be an important factor for an employee's decision whether to seek treatment especially if there
are negative repercussions such as how the employee is viewed in a negative manner";

proc sgplot data=mhclean;
    vbar mental_health_consequence / datalabel;
    title "Perceived Consequences of Discussing Mental Health";
    title;
run;

ods text = "Just check to see treatment and benefite";
proc freq data=mhclean;
    tables (treatment*Benefits) / chisq;
run;*/

ods text = " ";
ods text= "We will test to see if there are statistically 
significant differences between treatment and other catergorial variables such as Age Group, Gender, Number of employees
in the company and Benefits (whether company provides benefits)";

ods text= " ";
ods text= "Age Group vs Treatment";

proc freq data=mhclean;
    tables Age_Group*treatment / chisq;
run;

ods text= " ";
ods text= "Gender vs Treatment";

proc freq data=mhclean;
    tables Gender*treatment / chisq;
run;

ods text= " ";
ods text= "Number of employees vs Treatment";

proc freq data=mhclean;
    tables no_employees*treatment / chisq;
run;


ods text= " ";
ods text= "Benefits vs Treatment";

proc freq data=mhclean;
    tables Benefits*treatment / chisq;
run;

ods text= " ";
ods text= "We can see from the tests that Age group and Number of employees were not stasttically significant at seeking treatment
but gender and awarenss of benefits are (p < 0.05)";

ods text =" ";
ods text= "Next, we'll run the data in a logistic regression model and see which variables are
the most important predictors. Since we have many variables that could be correlated, we'll 
use a stepwise approach to select for variables in the model to include until the fit is appropriate";

proc logistic data=mhclean descending;
    class Age_Group (ref='<20') Gender(ref='Male') 
    Benefits(ref='No') no_employees(ref='6-25') family_history(ref='No')
    remote_work(ref= 'No') / param=ref;
    model Treatment(event='Yes') = Age_Group Gender Benefits no_employees 
    family_history remote_work 
    / selection=stepwise slentry=0.05 slstay=0.05;
run;

data odds_ratios;
   infile datalines dlm=' ' dsd truncover;
   input Effect :$30. Point_Estimate Lower_CI Upper_CI;
datalines;
"Female vs Male" 2.235 1.608 3.108
"Benefits ? vs No" 0.555 0.405 0.761
"Benefits Yes vs No" 1.493 1.100 2.027
"Family_history Yes vs No" 4.901 3.770 6.372
;
run;

ods text = " ";
ods text= "Here is the odds ratio (point estimate) of each of the significant factor levels";

proc sgplot data=odds_ratios;
    vbarparm category= Effect response= Point_Estimate / 
     limitlower= lower_CI limitupper= upper_CI;
   xaxis label="Effect";
   yaxis label="Odds Ratio (Point Estimate)";
   title "Odds Ratios with 95% Confidence Intervals";
run;

ods text = " ";
ods text = "Here are the results from the model:";
ods text = "1. Women have 2.24 times higher odds seeking treatment compared men.";
ods text = "2. Those who answered 'Don't know' have lower odds (by ~45%) compared to those who answered 'No'";
ods text = "3. Those who answered 'Yes' have 1.49 times higher odds of seeking treatment than those who answered 'No'";
ods text = "4. Those with a family history have 4.9 times higher odds of seeking treatment.";
ods text = "All effects were statsitically signifcant (p < 0.05).";

ods text = " ";
ods text= "Finally, we will validate the dataset using cross validation to see how well the dataset generalizes on unseen data.
To do this, we'll implement a macros doing 20 k-fold cross validation were k-1 folds will be used for training and the remianing
1 fold is used for testing and validation. Metrics such as accuracy, specificity, sensitivity, precision, recall and f1 will be returned.
The metrics will be represented as the average of the folds.";

data mh_model;
  set mhclean;
  if treatment = "Yes" then treat_bin = 1;
  else if treatment = "No" then treat_bin = 0;
run;

*Assign fold 1-20;
data mh_model_cv;
  set mh_model;
  fold = mod(floor(ranuni(9999)*20), 20) + 1; 
run;

* Run cross valldation Macros;
%macro cross_validate;

%let nfolds = 20;
data results;
  length Fold 8 Accuracy Sensitivity Specificity Precision Recall F1 8.;
  stop;
run;

%do i = 1 %to &nfolds;

  data train test;
    set mh_model_cv;
    if fold ne &i then output train;
    else output test;
  run;

  *Train model on relevant parameters selected from first log model;
  proc logistic data=train outmodel=log_model noprint;
    class gender(ref='Male') benefits(ref='No') family_history(ref='No') / param=ref;
    model treat_bin(event='1') = gender benefits family_history;
  run;

  *Score test data;
  proc logistic inmodel=log_model;
    score data=test out=preds(rename=(P_1=prob)) outroc=roc_&i;
  run;

  data preds;
    set preds;
    pred_label = (prob >= 0.5);
  run;

  proc freq data=preds noprint;
    tables treat_bin*pred_label / out=cm_&i;
  run;

  *Confusion matrix to metrics;
  proc sql noprint;
    select 
      sum(case when treat_bin=1 and pred_label=1 then 1 else 0 end) as TP,
      sum(case when treat_bin=0 and pred_label=1 then 1 else 0 end) as FP,
      sum(case when treat_bin=1 and pred_label=0 then 1 else 0 end) as FN,
      sum(case when treat_bin=0 and pred_label=0 then 1 else 0 end) as TN
    into :TP, :FP, :FN, :TN
    from preds;

    %let Accuracy = %sysevalf((&TP + &TN) / (&TP + &FP + &FN + &TN));
    %let Sensitivity = %sysevalf((&TP) / (&TP + &FN));
    %let Specificity = %sysevalf((&TN) / (&TN + &FP));
    %let Precision = %sysevalf((&TP) / (&TP + &FP));
    %let Recall = &Sensitivity;
    %let F1 = %sysevalf(2 * &Precision * &Recall / (&Precision + &Recall));

    insert into results
    set Fold = &i, 
        Accuracy = &Accuracy, 
        Sensitivity = &Sensitivity, 
        Specificity = &Specificity,
        Precision = &Precision,
        Recall = &Recall,
        F1 = &F1;
  quit;

%end;

%mend;

%cross_validate;

ods text = " ";
ods text = "Below are the results for the corss validation,";
proc print data=results label;
  title "Cross-Validation Metrics by Fold";
  var Fold Accuracy Sensitivity Specificity Precision Recall F1;
run;

ods text = " ";
ods text = "Plot the Metrics. This visualization shows the accuracy, sensitivity, specificity, etc.
for each fold";
proc sgplot data=results;
  title "Model Performance Metrics Across Folds";
  series x=Fold y=Accuracy / markers lineattrs=(color=blue);
  series x=Fold y=Sensitivity / markers lineattrs=(color=green);
  series x=Fold y=Specificity / markers lineattrs=(color=red);
  series x=Fold y=F1 / markers lineattrs=(color=purple);
  yaxis label="Metric Value";
run;

*prep for plotting;
proc means data=results noprint;
    var Accuracy Sensitivity Specificity Precision Recall F1;
    output out=summary_results mean= std= / autoname;
run;

*transpose to tidy format;
data tidy_summary;
    set summary_results;
    length Metric $15.;
    Metric = "Accuracy";    Mean = Accuracy_Mean;    StdDev = Accuracy_StdDev;    output;
    Metric = "Sensitivity"; Mean = Sensitivity_Mean; StdDev = Sensitivity_StdDev; output;
    Metric = "Specificity"; Mean = Specificity_Mean; StdDev = Specificity_StdDev; output;
    Metric = "Precision";   Mean = Precision_Mean;   StdDev = Precision_StdDev;   output;
    Metric = "Recall";   Mean = Recall_Mean;   StdDev = Recall_StdDev;   output;
    Metric = "F1";    Mean = F1_Mean;    StdDev = F1_StdDev;    output;
    keep Metric Mean StdDev;
run;

data tsum;
set tidy_summary;
lstd= Mean - StdDev;
ustd= Mean + StdDev;
run;

ods text = " ";
ods text = "Lastly, below is the overall average of the metrics from the cross validation.";
proc sgplot data=tsum;
    vbarparm category=Metric response=Mean / 
        datalabel=Mean 
        DATALABELPOS= TOP
        barwidth=0.6
        datalabelattrs=(weight=bold)
        fillattrs=(color=steelblue)
                limitlower= lstd
        limitupper= ustd ;
    
    yaxis label="Mean Metric Value" values=(0 to 0.8 by 0.1);
    xaxis label="Metric";
    title "Cross-Validation Metrics (Mean of 20 Folds ± StdDev)";
run;

ods text = " ";
ods text = "The model produced the following:";
ods text = "1. Accuracy: The model had an overall 70% of the predictions that were correctly classfied. This is misleading 
however because there are some imbalances in the dataset classes";
ods text = "2. Sensitivty (Recall) is the true positive rate. 66% of people who sought treatment were correctly classified";
ods text = "3. Specificity is also known as the true negative rate. 76% of people who didn't seek treatment were correctly identified";
ods text = "4. Precision is the true predictive value. 73% of those flagged for needing treatment were correct.";
ods text = "5. F1 Score is the balance between Precision and Recall. So 69% were correctly idenfied as treatment 
seekers and with the same rate of false alarms";

ods text = " ";
ods text= "^S={font_weight=bold}Results Review";
ods text= " ";
ods text= "1. Chi-square tests showed a significant association between 
benefits awareness and seeking treatment (p < 0.05).";
ods text = " ";
ods text= "2. Logistic regression found gender, awareness of benefits, and family history 
to be significant predictors (p < 0.05). Employees aware of benefits were 
1.49 times more likely to seek treatment. Additionally, employees with a family hisotry of mental health issues 
were 4.9 times more likely to seek treatment";
ods text = " ";
ods text= "3. Age group, number of employees and remote work were dropped from the stepwise variable selection in the 
model meaning that they are likely not as highly associated with seeking treatment than factors 
including gender, awareness of benefits and family history";
ods text = " ";
ods text= "4. Using k-folds cross validation, the model does a decent job in predicting those that sought treatment at 66% tru postive rate, 
and those that did not seek treatment at 76% true negative rate";

ods text= " ";
ods text= "^S={font_weight=bold}Conclusion";
ods text= " ";
ods text= "These results show that promoting awareness of benefits is key to increasing mental health treatment uptake. 
Employees who were aware of benefits provided by the company were 1.49 times likely to seek treatment. Additionally, those with family 
history of mental health issues seem to be more aware of the issues and are even more likely (4.9x) to seek treatment";
ods text = " ";
ods text= "Gender-specific approaches may also improve outreach effectiveness. Women were 2.2x more likely to seek treatment. 
This shows that societal norms play a large part in how men and women percieve and act around mental health. 
It seems that there could be more in the data that shows us why men seem to not seek treatment.";
ods text = " ";
ods text= "Number of Employees did not significantly predict treatment behavior in this sample nor did age group but there 
may be more insight to be gathered from the data especially if we look at each category more granularly";

ods text= " ";
ods text= "^S={font_weight=bold}Recommendations/Next Steps";
ods text= " ";
ods text= "Encourage HR transparency on available mental health benefits.";
ods text= "Tailor mental health communication efforts to different demographic groups.";

*ods html close;
*ods powerpoint close;
ods pdf close;

