# Workplace-Mental-Health-Analysis-of-Factors-Influencing-Treatment-Seeking-Behavior
This project analyzes survey data on mental health in the workplace using SAS. It explores demographic and organizational factors associated with whether individuals seek mental health treatment, including statistical modeling, hypothesis testing, and report generation.

## Dataset
Source: Kaggle - [Mental Health in Tech Survey](https://www.kaggle.com/datasets/osmi/mental-health-in-tech-survey)

Target: treatment — whether an individual has sought mental health treatment

Size: ~1,200 observations, multiple categorical and numeric variables

## Key Questions
1. What factors (age, gender, family history, company size, benefits) are associated with seeking treatment?
2. Are there significant differences in age or gender among those who seek treatment?
3. Can we predict treatment using logistic regression?

## Methods
- Data cleaning and transformation in SAS
- Descriptive statistics and frequency tables\
- Inferential statistics: chi-square tests
- Logistic regression with stepwise selection
- Odds ratio interpretation
- 20-fold cross-validation using SAS macro
- Performance metrics: Accuracy, Sensitivity, Specificity, Precision, F1 Score
- Visualizations using PROC SGPLOT and VBarParm

## Highlighted Results
- Family history increased odds of seeking treatment by ~5x.
- Gender and awareness of benefits were also significant predictors.
- Logistic model validated with cross-validation: Average Accuracy: ~75%, balanced Sensitivity and Specificity
- Final bar plot shows model performance metrics.

## Visualizations

- Bar charts (gender distribution, treatment counts)
- Histograms (age distribution)
- Odds ratios and confidence intervals table
- Bar plot of cross-validation metrics with error bars and mean labels

## Software used and procedures used
- SAS 9.4 / SAS OnDemand for Academics
- PROC FREQ, PROC MEANS, PROC TTEST, PROC LOGISTIC, PROC SGPLOT, ODS PDF
