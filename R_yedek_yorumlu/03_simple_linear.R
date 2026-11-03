# =============================================================================
# 03_simple_linear.R
# Data Mining Midterm - Part 2.1: Simple Linear Regression
# Model: price = b0 + b1 * accommodates + error
# Data : data/clean_listings.csv (output of 02_cleaning.R)
# =============================================================================

library(tidyverse)

listings <- read_csv("data/clean_listings.csv", show_col_types = FALSE)
cat("Data:", nrow(listings), "rows,", ncol(listings), "columns\n")


# -----------------------------------------------------------------------------
# 2.1 Item 1 - Dependent and independent variables
# -----------------------------------------------------------------------------
# Dependent variable   (Y): price        - nightly price in TL (numerical)
# Independent variable (X): accommodates - maximum number of guests (numerical)
# (Item 2 - why these variables were selected - is explained in notlar/03_basit_regresyon.md)

cat("\nY = price (TL) | X = accommodates (number of guests)\n")
cat("Y mean:", round(mean(listings$price), 2), "| X mean:", round(mean(listings$accommodates), 2), "\n")

# -----------------------------------------------------------------------------
# 2.1 Item 2 - Support for the choice of X (descriptive)
# -----------------------------------------------------------------------------
# Pearson correlation between price and accommodates: strength/direction of
# the linear relationship (-1 ... +1)
r_xy <- cor(listings$price, listings$accommodates)
cat(sprintf("
Correlation between price and accommodates: r = %.4f\n", r_xy))

# Median price for each guest capacity: does price rise with capacity?
cat("Median price by accommodates:\n")
print(as.data.frame(listings %>% group_by(accommodates) %>%
                      summarise(n = n(), median_price = median(price))), row.names = FALSE)


# -----------------------------------------------------------------------------
# 2.1 Item 3 - Estimate the model with lm()
# -----------------------------------------------------------------------------
model_slr <- lm(price ~ accommodates, data = listings)

cat("\n===== Model summary =====\n")
print(summary(model_slr))

s <- summary(model_slr)   # summary object: contains coefficients, F, R2 ...


# -----------------------------------------------------------------------------
# 2.1 Item 4 - Overall model significance (F test)
# -----------------------------------------------------------------------------
# H0: the model has no explanatory power (b1 = 0)
# H1: the model explains price (b1 != 0)
f_stat <- s$fstatistic                       # F value, df1 (numerator), df2 (denominator)
f_p    <- pf(f_stat["value"], f_stat["numdf"], f_stat["dendf"], lower.tail = FALSE)

cat("\n===== Item 4: F test =====\n")
cat(sprintf("F(%d, %d) = %.2f, p-value = %s\n",
            f_stat["numdf"], f_stat["dendf"], f_stat["value"], format.pval(f_p, digits = 3)))
cat("Decision at alpha = 0.05:", ifelse(f_p < 0.05, "reject H0 -> model is significant",
                                        "do not reject H0 -> model is not significant"), "\n")


# -----------------------------------------------------------------------------
# 2.1 Item 5 - Significance of accommodates (t test)
# -----------------------------------------------------------------------------
# H0: b1 = 0 (accommodates has no effect on price), H1: b1 != 0
coefs <- s$coefficients                      # columns: Estimate, Std. Error, t value, Pr(>|t|)
b0 <- coefs["(Intercept)", "Estimate"]
b1 <- coefs["accommodates", "Estimate"]
t1 <- coefs["accommodates", "t value"]
p1 <- coefs["accommodates", "Pr(>|t|)"]

cat("\n===== Item 5: t test for accommodates =====\n")
cat(sprintf("B = %.2f, SE = %.2f, t = %.2f, p-value = %s\n",
            b1, coefs["accommodates", "Std. Error"], t1, format.pval(p1, digits = 3)))
cat("Decision at alpha = 0.05:", ifelse(p1 < 0.05, "accommodates is significant",
                                        "accommodates is not significant"), "\n")


# -----------------------------------------------------------------------------
# 2.1 Item 6 - Interpretation of B
# -----------------------------------------------------------------------------
cat("\n===== Item 6: coefficient interpretation =====\n")
cat(sprintf("Each additional guest capacity is associated with a %.2f TL change in the nightly price on average.\n", b1))
cat(sprintf("Intercept (B0) = %.2f TL: the predicted price when accommodates = 0 (no practical meaning, minimum is 1).\n", b0))


# -----------------------------------------------------------------------------
# 2.1 Item 7 - Estimated regression equation
# -----------------------------------------------------------------------------
cat("\n===== Item 7: estimated regression equation =====\n")
cat(sprintf("predicted price = %.2f %s %.2f * accommodates\n",
            b0, ifelse(b1 >= 0, "+", "-"), abs(b1)))


# -----------------------------------------------------------------------------
# 2.1 Item 8 - R-squared and adjusted R-squared
# -----------------------------------------------------------------------------
cat("\n===== Item 8: R-squared =====\n")
cat(sprintf("R2 = %.4f (%.1f%% of the variation in price is explained by accommodates)\n",
            s$r.squared, 100 * s$r.squared))
cat(sprintf("Adjusted R2 = %.4f\n", s$adj.r.squared))


# -----------------------------------------------------------------------------
# 2.1 Item 9 - Predicted values
# -----------------------------------------------------------------------------
# (a) Predicted value for every listing in the data (fitted values)
listings$predicted_price <- predict(model_slr)
cat("\n===== Item 9: predicted values =====\n")
cat("First 6 listings - actual vs predicted price:\n")
print(as.data.frame(head(select(listings, accommodates, price, predicted_price))), row.names = FALSE)

# (b) Example predictions for new listings with 2 and 4 guests
new_listings <- tibble(accommodates = c(2, 4))
new_listings$predicted_price <- predict(model_slr, newdata = new_listings)
cat("\nExample predictions:\n")
print(as.data.frame(new_listings), row.names = FALSE)
write_csv(new_listings, "output/tables/03_simple_linear_predictions.csv")


# -----------------------------------------------------------------------------
# Results table for the report (Required Reporting of 2.1)
# -----------------------------------------------------------------------------
# Rows 1-2: coefficients (B, SE, t, p). Rows 3-5: model statistics.
# For the F row, 'estimate' holds the F value and 'p_value' its p-value.
results_table <- tibble(
  term      = c("(Intercept)", "accommodates",
                sprintf("F-statistic (df = %d, %d)", f_stat["numdf"], f_stat["dendf"]),
                "R-squared", "Adjusted R-squared"),
  estimate  = c(b0, b1, f_stat["value"], s$r.squared, s$adj.r.squared),
  std_error = c(coefs[, "Std. Error"], NA, NA, NA),
  t_value   = c(coefs[, "t value"], NA, NA, NA),
  p_value   = c(coefs[, "Pr(>|t|)"], f_p, NA, NA)
) %>%
  # Rounded values for the report; p-values below 0.001 are written as "< 0.001"
  # (R shows extremely small p-values as 0, which must not be reported as exactly 0)
  mutate(estimate  = round(estimate, 4),
         std_error = round(std_error, 4),
         t_value   = round(t_value, 3),
         p_report  = case_when(is.na(p_value) ~ NA_character_,
                               p_value < 0.001 ~ "< 0.001",
                               TRUE            ~ sprintf("%.3f", p_value)))

cat("\n===== Regression results table =====\n")
print(as.data.frame(results_table), row.names = FALSE, digits = 6)
write_csv(results_table, "output/tables/03_simple_linear.csv")
cat("Saved: output/tables/03_simple_linear.csv\n")
# Note: a p-value printed as 0 (or < 2e-16) means it is smaller than the
# smallest number R can show; report it as "p < 0.001".
