**DATA MINING**

**MIDTERM PROJECT INSTRUCTIONS**

**1. Project Objective**

The purpose of this project is to apply data preprocessing, linear
regression, and binary logistic regression techniques using RStudio.

Students are expected to select a real-world dataset, identify and
resolve data quality problems, develop regression models, evaluate their
results, and prepare a structured analytical report.

The project consists of three main parts:

1.  Data Import, Exploration, and Preprocessing

2.  Simple and Multiple Linear Regression

3.  Binary Logistic Regression

**Important:** The same dataset and the same underlying dependent
variable must be used throughout the project.

For linear regression, the dependent variable must be numerical. For
logistic regression, students must transform this numerical dependent
variable into a binary categorical variable using an appropriate and
justified classification rule.

All analyses must be performed using RStudio.

**PART 1. DATA IMPORT, EXPLORATION, AND PREPROCESSING**

**1.1. Dataset Selection**

Select a real-world dataset containing:

- At least 100 observations (larger datasets are recommended).

- At least 4 numerical variables.

- At least 3 categorical variables.

- At least one binary categorical independent variable.

- At least one categorical independent variable with three or more
  categories.

- One numerical dependent variable suitable for linear regression.

The selected numerical dependent variable must also be suitable for
conversion into a binary variable for logistic regression.

**Example**

Suppose the original dataset contains a numerical variable representing
customer spending.

**Original numerical dependent variable:**

Customer_Spending

This variable can be used for linear regression.

For logistic regression, a new binary variable can be created:

High_Spending

- 0 = Low spending

- 1 = High spending

The classification threshold may be based on a meaningful value, a
theoretically justified criterion, or the median of the original
variable.

Students must explain why the selected threshold is appropriate.

**Important:** The original numerical dependent variable must be
retained for linear regression. The newly created binary variable will
be used for logistic regression.

The original numerical dependent variable must not be used as an
independent variable to predict its own binary transformation.

**Required Reporting**

Provide:

- Dataset name and source.

- Number of observations and variables.

- Description of numerical and categorical variables.

- Identification of the numerical dependent variable.

- Explanation of how the binary dependent variable was created.

- Justification of the selected classification threshold.

Prepare a variable description table.

**1.2. Importing the Dataset into RStudio**

Import the dataset using an appropriate R function.

Report:

- Original file format.

- R function used.

- Number of observations.

- Number of variables.

Include the relevant R code.

**1.3. Initial Dataset Examination**

Examine the dataset using:

- head()

- dim()

- str()

- summary()

Identify:

- Incorrect variable types.

- Missing values.

- Incorrect or inconsistent categorical values.

- Unusual numerical values.

- Potential data entry errors.

Explain the identified problems.

**1.4. Data Cleaning and Preparation**

Apply appropriate procedures to resolve the identified problems.

Possible procedures include:

- Correcting incorrect values.

- Recoding categorical variables.

- Converting variables into appropriate data types.

- Creating new variables.

- Removing missing observations when justified.

- Replacing missing values using appropriate methods.

- Correcting problems in the original Excel file or directly in R.

Every modification must be explained. Include the relevant R codes.

**1.5. Creating the Binary Dependent Variable**

Transform the selected numerical dependent variable into a binary
categorical variable.

The new variable must contain exactly two categories:

- 0 = Reference outcome

- 1 = Target outcome

Students must:

1.  Identify the original numerical dependent variable.

2.  Determine an appropriate classification threshold.

3.  Explain the reason for selecting this threshold.

4.  Create the binary variable using R.

5.  Report the number and percentage of observations in each category.

6.  Verify that the new variable was created correctly.

**Important:** The binary variable must be derived from the numerical
dependent variable used in linear regression.

**1.6. Final Dataset Verification**

After completing data cleaning and variable creation, examine the
dataset again using:

- str()

- summary()

- dim()

Report the final number of observations and variables.

Explain whether the dataset is ready for regression analyses.

**PART 2. LINEAR REGRESSION ANALYSIS**

Students must perform two types of linear regression:

1.  Simple Linear Regression

2.  Multiple Linear Regression with Mixed Independent Variables

Both models must use the same numerical dependent variable.

**2.1. Simple Linear Regression**

Develop a simple linear regression model using:

- One numerical dependent variable (Y).

- One numerical independent variable (X).

The model is:

**Y = β₀ + β₁X + ε**

**Required Analyses**

1.  Identify the dependent and independent variables.

2.  Explain why the variables were selected.

3.  Estimate the regression model using R.

4.  Evaluate the overall model significance.

5.  Examine the significance of the independent variable.

6.  Interpret the regression coefficient (B).

7.  Write the estimated regression equation.

8.  Evaluate R² and adjusted R².

9.  Generate predicted values.

10. Interpret the findings.

**Required Reporting**

Present a regression results table containing:

- B coefficients

- Standard errors

- t-values

- p-values

- F-statistic and its p-value

- R²

- Adjusted R²

Write and interpret the estimated regression equation.

Provide at least one example of a predicted value.

**2.2. Multiple Linear Regression – Mixed Independent Variables**

Develop multiple linear regression model containing:

- One numerical dependent variable.

- At least two numerical independent variables.

- At least one binary categorical independent variable.

- At least one categorical independent variable with three or more
  categories.

The general model is:

**Y = β₀ + β₁X₁ + β₂X₂ + ... + βₖXₖ + ε**

**Step 1. Initial Model**

Estimate a multiple linear regression model including both numerical and
categorical independent variables.

Students must:

1.  Identify the dependent and independent variables.

2.  Convert categorical variables into factors when necessary.

3.  Identify the reference categories.

4.  Estimate the regression model.

5.  Evaluate the overall significance of the model using the F-test.

6.  Examine the statistical significance of the independent variables.

7.  Identify significant and nonsignificant predictors.

8.  Interpret numerical and categorical regression coefficients.

**Step 2. Model Revision**

If the initial model contains nonsignificant independent variables,
remove them and estimate the model again.

Continue revising the model until the final model contains only
statistically significant independent variables.

When evaluating a categorical predictor with more than two categories,
consider the significance of the categorical variable as a whole, rather
than relying exclusively on the significance of individual category
coefficients.

**Step 3. Interpretation of the Final Model**

Students must:

1.  Present the final regression model.

2.  Evaluate its overall statistical significance.

3.  Interpret the significant regression coefficients.

4.  Write the final estimated regression equation.

5.  Evaluate R² and adjusted R².

6.  Explain how the final model differs from the initial model.

**Special Rule: Numerical and Categorical Variables**

The initial model must contain both numerical and categorical
independent variables.

However, after removing nonsignificant variables, the final model may
contain:

- Only numerical independent variables.

- Only categorical independent variables.

- Both numerical and categorical independent variables.

If the final model contains both types, interpret at least one numerical
and one categorical coefficient.

If the final model contains only numerical independent variables,
students must also select at least one categorical coefficient from the
initial model and explain how it would be interpreted, while clearly
stating that it was not statistically significant.

Similarly, if the final model contains only categorical independent
variables, students must select at least one numerical coefficient from
the initial model and explain its interpretation, while clearly stating
that it was not statistically significant.

This requirement ensures that students demonstrate their ability to
interpret both numerical and categorical regression coefficients.

**Required Reporting**

Present:

**Table 1. Initial Multiple Linear Regression Model**

Include all independent variables, regression coefficients, and
statistical significance results.

**Table 2. Final Multiple Linear Regression Model**

Include only the statistically significant independent variables.

Explain:

- Which variables were removed.

- Why they were removed.

- Which variables remained statistically significant.

- How numerical and categorical coefficients are interpreted.

- How the model's explanatory power changed.

**PART 3. BINARY LOGISTIC REGRESSION**

In this section, students must use the binary dependent variable created
from the original numerical dependent variable in Part 1.

The binary dependent variable must be used in all four logistic
regression models.

The general logistic regression model is:

**logit(p) = ln\[p / (1 − p)\] = β₀ + β₁X₁ + ... + βₖXₖ**

Students must interpret logistic regression coefficients using:

**Odds Ratio = Exp(B)**

Four logistic regression models are required.

**3.1. Model 1 – Numerical Independent Variable**

Develop a binary logistic regression model using:

- The binary dependent variable.

- One numerical independent variable.

**Required Analyses**

1.  Estimate the logistic regression model.

2.  Examine the statistical significance of the independent variable.

3.  Interpret the coefficient (B).

4.  Calculate and interpret Exp(B).

5.  Write the estimated logistic regression equation.

6.  Calculate predicted probabilities.

7.  Evaluate model goodness of fit.

8.  Calculate classification accuracy.

9.  Create a logistic regression probability curve.

10. Interpret the results.

**3.2. Model 2 – Binary Categorical Independent Variable**

Develop a binary logistic regression model using:

- The binary dependent variable.

- One binary categorical independent variable.

**Required Analyses**

1.  Identify the reference category.

2.  Estimate the logistic regression model.

3.  Examine the statistical significance of the independent variable.

4.  Interpret B and Exp(B).

5.  Evaluate model goodness of fit.

6.  Calculate classification accuracy.

7.  Interpret the findings.

**3.3. Model 3 – Multicategory Independent Variable**

Develop a binary logistic regression model using:

- The binary dependent variable.

- One categorical independent variable containing at least three
  categories.

**Required Analyses**

1.  Convert the independent variable into a factor.

2.  Identify the reference category.

3.  Estimate the logistic regression model.

4.  Examine the regression coefficients.

5.  Interpret Exp(B) for the relevant categories.

6.  Evaluate model goodness of fit.

7.  Calculate classification accuracy.

8.  Interpret the findings.

Students must explain how the odds of the target outcome differ between
each category and the reference category.

**3.4. Model 4 – Multiple Logistic Regression with Mixed Predictors**

Develop a multiple binary logistic regression model using:

- The binary dependent variable.

- At least one numerical independent variable.

- At least one categorical independent variable.

**Required Analyses**

1.  Identify the independent variables.

2.  Estimate the logistic regression model.

3.  Examine the statistical significance of the predictors.

4.  Interpret numerical coefficients.

5.  Interpret categorical coefficients.

6.  Calculate and interpret Exp(B).

7.  Evaluate model goodness of fit.

8.  Calculate classification accuracy.

9.  Interpret the overall findings.

**PART 4. LOGISTIC REGRESSION MODEL EVALUATION**

For each of the four logistic regression models, students must report
the following statistics.

**4.1. Goodness of Fit**

- Hosmer–Lemeshow test

- McFadden's Pseudo R²

- Cox & Snell Pseudo R²

- Nagelkerke Pseudo R²

Students must explain the meaning of the reported values.

Pseudo R² statistics must not be interpreted in exactly the same way as
R² in linear regression.

**4.2. Classification Accuracy**

Calculate predicted probabilities using the estimated logistic
regression models.

Use a classification threshold of:

**0.50**

Create a confusion matrix.

|               | **Predicted: 0** | **Predicted: 1** |
|---------------|------------------|------------------|
| **Actual: 0** | True Negative    | False Positive   |
| **Actual: 1** | False Negative   | True Positive    |

Calculate:

**Accuracy = (TP + TN) / (TP + TN + FP + FN)**

Report and interpret classification accuracy for each logistic
regression model.

Consider the distribution of the dependent variable when interpreting
classification performance.

**4.3. Logistic Regression Graph**

For 4 different Models, create a logistic regression probability curve.

The graph must include:

- Numerical independent variable(s) on the X-axis.

- Predicted probability on the Y-axis.

- Estimated logistic regression curve.

Interpret how the predicted probability changes as the numerical
independent variable(s) increases/decreases or categorical independent
variable(s) change from reference category to other category(ies).

**PART 5. FINAL REPORT STRUCTURE**

The final report must include the following sections.

**1. Introduction**

Briefly describe the dataset and the purpose of the project.

**2. Dataset Description**

Present:

- Dataset source.

- Number of observations.

- Number of variables.

- Variable description table.

- Selected numerical dependent variable.

- Binary dependent variable creation procedure.

**3. Data Exploration and Preprocessing**

Present:

- Initial dataset examination.

- Identified data problems.

- Data cleaning procedures.

- Variable transformations.

- Final dataset verification.

**4. Linear Regression Results**

**4.1. Simple Linear Regression**

Present the model results, regression equation, predicted values, and
interpretations.

**4.2. Multiple Linear Regression**

Present:

- Initial mixed regression model.

- Statistical significance results.

- Model revision procedures.

- Final regression model.

- Interpretation of numerical and categorical predictors.

- R² and adjusted R².

**5. Binary Logistic Regression Results**

Present the results of all four models:

- Model 1: Numerical predictor.

- Model 2: Binary categorical predictor.

- Model 3: Multicategory predictor.

- Model 4: Mixed predictors.

For each model, report:

- Regression coefficients.

- Statistical significance.

- Odds ratios.

- Goodness-of-fit statistics.

- Confusion matrix.

- Classification accuracy.

- Interpretation.

Include the logistic regression probability curve for Models.

**6. Conclusion**

Summarize:

- The main findings of linear regression.

- The main findings of logistic regression.

- The statistically significant independent variables.

- The overall interpretation of the results.

**7. Appendix – R Codes**

Include all R codes used for:

- Data import.

- Data exploration.

- Data cleaning.

- Variable creation.

- Linear regression.

- Logistic regression.

- Model evaluation.

- Predictions.

- Graphical visualization.
