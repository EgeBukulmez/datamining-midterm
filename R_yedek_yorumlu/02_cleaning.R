# =============================================================================
# 02_cleaning.R
# Data Mining Midterm - Part 1.4: Data cleaning and preparation
#
# Decisions taken by the student (see notlar/02_temizleme.md):
#   - Variables kept : price (Y), accommodates, bedrooms, bathrooms (derived from
#                      bathrooms_text), number_of_reviews, availability_365,
#                      host_is_superhost, room_type (reference = "Entire home/apt")
#   - price outliers : drop listings outside the 1st - 99th percentile
#   - minimum_nights : drop listings with minimum_nights > 30, then drop the column
#   - review scores  : not used
#   - entry errors   : drop bedrooms > accommodates and Entire home/apt with 0 baths
#   - missing values : drop the few rows with missing bedrooms / bathrooms
#   - Y              : price in TL, no log transformation
#
# The raw file data/listings.csv.gz is NOT modified; all changes happen in R.
# The binary dependent variable (1.5) is NOT created here yet.
# =============================================================================

library(tidyverse)

raw <- read_csv("data/listings.csv.gz", guess_max = 30000, show_col_types = FALSE)

# Small helper: prints the number of rows before and after each step
# so that every cleaning decision can be reported with exact numbers.
step_log <- tibble(step = character(), rows_before = integer(),
                   rows_after = integer(), rows_removed = integer())

report_step <- function(step, before, after) {
  cat(sprintf("%-55s before: %6d | after: %6d | removed: %5d\n",
              step, nrow(before), nrow(after), nrow(before) - nrow(after)))
  step_log <<- add_row(step_log, step = step, rows_before = nrow(before),
                       rows_after = nrow(after),
                       rows_removed = nrow(before) - nrow(after))
}

cat("Raw data:", nrow(raw), "rows,", ncol(raw), "columns\n\n")


# -----------------------------------------------------------------------------
# STEP 1. Keep only the variables needed for the analysis
# -----------------------------------------------------------------------------
# Why: the raw data has 90 columns; most of them (URLs, texts, 13 completely
# empty columns, license, review sub-scores ...) are not used in any model.
# minimum_nights is kept TEMPORARILY because it is needed for the filter in Step 5.
# bathrooms_text is kept TEMPORARILY to derive the numeric bathrooms variable.
# Columns are removed, not rows -> row count does not change.

df <- raw %>%
  select(price, accommodates, bedrooms, bathrooms_text, number_of_reviews,
         availability_365, host_is_superhost, room_type, minimum_nights)

cat("Step 1 - columns kept:", ncol(df), "->", paste(names(df), collapse = ", "), "\n")
report_step("Step 1: select variables (columns only)", raw, df)


# -----------------------------------------------------------------------------
# STEP 2. Convert price from text to number
# -----------------------------------------------------------------------------
# Why: price is stored as text such as "$4,736.32". Calculations and regression
# need a numeric variable. parse_number() removes "$" and the thousands comma.
# Note: the "$" sign is only formatting; the values are Turkish Lira (TL).

cat("\nprice before conversion:", class(df$price), "| example:", df$price[2], "\n")
df <- df %>% mutate(price = parse_number(price))
cat("price after  conversion:", class(df$price), "| example:", df$price[2], "\n")


# -----------------------------------------------------------------------------
# STEP 3. Remove listings with missing price
# -----------------------------------------------------------------------------
# Why: price is the dependent variable. A listing without a price cannot be
# used in any regression model; imputing the dependent variable would create
# artificial data, so these rows are removed.

before <- df
df <- df %>% filter(!is.na(price))
report_step("Step 3: remove missing price", before, df)


# -----------------------------------------------------------------------------
# STEP 4. Remove price outliers (outside 1st - 99th percentile)
# -----------------------------------------------------------------------------
# Why: price is extremely right-skewed (max ~ 4.99 million TL). A few extreme
# values would pull the regression line strongly. The percentiles are computed
# AFTER removing missing prices (Step 3), as decided.

p01 <- quantile(df$price, 0.01)
p99 <- quantile(df$price, 0.99)
cat(sprintf("\nprice 1st percentile: %.2f TL | 99th percentile: %.2f TL\n", p01, p99))

before <- df
df <- df %>% filter(price >= p01, price <= p99)   # keep values inside the interval
report_step("Step 4: remove price outside 1%-99% percentiles", before, df)


# -----------------------------------------------------------------------------
# STEP 5. Remove long-term rentals (minimum_nights > 30), then drop the column
# -----------------------------------------------------------------------------
# Why: listings that require more than 30 nights are monthly / long-term rentals.
# Their "nightly" price is not comparable with short-stay listings.
# After the filter, minimum_nights is no longer needed and is removed.

before <- df
df <- df %>% filter(minimum_nights <= 30) %>% select(-minimum_nights)
report_step("Step 5: remove minimum_nights > 30", before, df)


# -----------------------------------------------------------------------------
# STEP 6. Create numeric 'bathrooms' from 'bathrooms_text'
# -----------------------------------------------------------------------------
# Why: the raw 'bathrooms' column is completely empty; the number of baths only
# exists inside text such as "1.5 shared baths". We extract the number.
# Rules:
#   - text contains a number          -> that number ("1.5 baths" -> 1.5)
#   - "Half-bath", "Private half-bath",
#     "Shared half-bath" (no number)   -> 0.5 (student decision)
#   - "No bathroom"                    -> 0   (the text literally means zero)
#   - NA                               -> stays NA (handled in Step 8)

df <- df %>%
  mutate(bathrooms = case_when(
    # str_extract() takes the first number in the text ("1.5 shared baths" -> "1.5");
    # for texts without a number it returns NA silently (no warning)
    str_detect(bathrooms_text, "[0-9]")                 ~ as.numeric(str_extract(bathrooms_text, "[0-9.]+")),
    str_detect(str_to_lower(bathrooms_text), "half-bath") ~ 0.5,
    bathrooms_text == "No bathroom"                     ~ 0,
    TRUE                                                ~ NA_real_
  ))

# Create the binary categorical variable 'shared_bath' from the same text.
# Why: Guideline 1.1 requires at least 3 categorical variables; this is the 3rd one
# (student decision). Rule: text contains "shared" -> "Yes", otherwise -> "No".
# Missing text stays NA (these rows are removed in Step 8 together with missing bathrooms).
df <- df %>%
  mutate(shared_bath = case_when(
    is.na(bathrooms_text)                                 ~ NA_character_,
    str_detect(str_to_lower(bathrooms_text), "shared")    ~ "Yes",
    TRUE                                                  ~ "No"
  ))

# Check: every text value and the number / shared flag it was converted to
cat("\nbathrooms_text -> bathrooms, shared_bath (conversion check):\n")
print(as.data.frame(count(df, bathrooms_text, bathrooms, shared_bath)), row.names = FALSE)

# bathrooms_text is no longer needed
df <- df %>% select(-bathrooms_text)


# -----------------------------------------------------------------------------
# STEP 7. Remove data entry errors
# -----------------------------------------------------------------------------
# 7a. More bedrooms than guests (e.g. 5 bedrooms for 2 guests) is implausible.
#     Rows with missing bedrooms are NOT removed here (handled in Step 8).
before <- df
df <- df %>% filter(is.na(bedrooms) | bedrooms <= accommodates)
report_step("Step 7a: remove bedrooms > accommodates", before, df)

# 7b. An entire home/apartment with 0 bathrooms is implausible (entry error).
#     Room listings (Private / Shared / Hotel room) with 0 bathrooms are KEPT:
#     there 0 means the room has no own bathroom and a shared one is used -
#     this is not a data error (student decision).
before <- df
df <- df %>% filter(!(room_type == "Entire home/apt" & !is.na(bathrooms) & bathrooms == 0))
report_step("Step 7b: remove Entire home/apt with 0 bathrooms", before, df)

# 7c. More bathrooms than guests (e.g. 34 baths in a 2-guest private room) is
#     implausible - same logic as 7a. These are most likely the total number of
#     baths of a whole hotel/hostel building entered for a single listing.
#     Rows with missing bathrooms are NOT removed here (handled in Step 8).
before <- df
df <- df %>% filter(is.na(bathrooms) | bathrooms <= accommodates)
report_step("Step 7c: remove bathrooms > accommodates", before, df)


# -----------------------------------------------------------------------------
# STEP 8. Remove the few rows with missing bedrooms or bathrooms
# -----------------------------------------------------------------------------
# Why: only a very small number of rows; removing them is simpler and more
# honest than inventing values, and it hardly changes the sample size.

cat("\nMissing values before Step 8:\n")
print(colSums(is.na(df)))

before <- df
df <- df %>% filter(!is.na(bedrooms), !is.na(bathrooms))
report_step("Step 8: remove missing bedrooms / bathrooms", before, df)


# -----------------------------------------------------------------------------
# STEP 9. Convert categorical variables into factors (recoding)
# -----------------------------------------------------------------------------
# host_is_superhost: read as logical TRUE/FALSE -> factor "No"/"Yes".
#   Reference category = "No" (not a superhost), the first level.
# room_type: text -> factor with 4 levels.
#   Reference category = "Entire home/apt" (student decision, the largest group).

df <- df %>%
  mutate(
    host_is_superhost = factor(if_else(host_is_superhost, "Yes", "No"),
                               levels = c("No", "Yes")),
    room_type = factor(room_type,
                       levels = c("Entire home/apt", "Private room",
                                  "Hotel room", "Shared room")),
    # shared_bath: "No"/"Yes" text -> factor. Reference = "No" (private bathroom).
    shared_bath = factor(shared_bath, levels = c("No", "Yes"))
  )

cat("\nhost_is_superhost levels (first = reference):", levels(df$host_is_superhost), "\n")
print(table(df$host_is_superhost, useNA = "ifany"))
cat("\nshared_bath levels (first = reference):", levels(df$shared_bath), "\n")
print(table(df$shared_bath, useNA = "ifany"))
cat("\nroom_type levels (first = reference):", levels(df$room_type), "\n")
print(table(df$room_type, useNA = "ifany"))


# -----------------------------------------------------------------------------
# Final order of columns and cleaning log
# -----------------------------------------------------------------------------
df <- df %>%
  select(price, accommodates, bedrooms, bathrooms, number_of_reviews,
         availability_365, host_is_superhost, room_type, shared_bath)

cat("\n===== CLEANING LOG =====\n")
print(as.data.frame(step_log), row.names = FALSE)

cat("\nRows: raw", nrow(raw), "-> clean", nrow(df),
    sprintf("(%.1f%% of raw data kept)\n", 100 * nrow(df) / nrow(raw)))
cat("Columns: raw", ncol(raw), "-> clean", ncol(df), "\n")
cat("Remaining missing values in total:", sum(is.na(df)), "\n")

write_csv(step_log, "output/tables/02_cleaning_log.csv")
cat("Saved: output/tables/02_cleaning_log.csv\n")


# =============================================================================
# 1.5 CREATING THE BINARY DEPENDENT VARIABLE
# =============================================================================
# 1. Original numerical dependent variable: price (nightly price, TL)
# 2. Threshold: the MEDIAN of price in the cleaned data (student decision)
# 3. Reason   : the median splits the listings into two (almost) equal groups
#               -> balanced classes; it is a data-driven, objective cut point that
#               does not depend on arbitrary TL values. Guideline 1.1 explicitly
#               lists the median as an acceptable threshold.
# 4. Rule     : high_price = 1 if price > median  (target outcome: high price)
#               high_price = 0 if price <= median (reference outcome: low/medium price)
# The median is computed on the FINAL cleaned data (after all filters above).

price_median <- median(df$price)
cat("\n===== 1.5 BINARY DEPENDENT VARIABLE =====\n")
cat("Threshold = median of price in the cleaned data:", price_median, "TL\n")

df <- df %>% mutate(high_price = if_else(price > price_median, 1L, 0L))

# 5. Number and percentage of observations in each category
class_table <- df %>%
  count(high_price) %>%
  mutate(label   = if_else(high_price == 1, "1 = High price (target)",
                                            "0 = Low/medium price (reference)"),
         percent = round(100 * n / sum(n), 2)) %>%
  select(high_price, label, n, percent)
print(as.data.frame(class_table), row.names = FALSE)
write_csv(class_table, "output/tables/02_high_price_distribution.csv")

# Listings exactly AT the median go to group 0 (rule is "> median").
# This is why the groups are not exactly 50/50.
cat("Listings with price exactly equal to the median:", sum(df$price == price_median), "\n")

# 6. Verification that the variable was created correctly
cat("\nVerification - price range in each group:\n")
verify <- df %>%
  group_by(high_price) %>%
  summarise(n = n(), min_price = min(price), max_price = max(price))
print(as.data.frame(verify), row.names = FALSE)
# Group 0 max must be <= median and group 1 min must be > median:
cat("Group 0 max <= median :", max(df$price[df$high_price == 0]) <= price_median, "\n")
cat("Group 1 min >  median :", min(df$price[df$high_price == 1]) >  price_median, "\n")
cat("Only values 0 and 1   :", all(df$high_price %in% c(0, 1)), "\n")
cat("No missing values     :", !anyNA(df$high_price), "\n")
# Recompute the rule independently and compare with the created variable
cat("Matches (price > median) for every row:",
    all(df$high_price == as.integer(df$price > price_median)), "\n")


# =============================================================================
# 1.6 FINAL DATASET VERIFICATION
# =============================================================================
cat("\n===== 1.6 FINAL DATASET VERIFICATION =====\n")
cat("\n--- str() ---\n")
str(df, give.attr = FALSE)
cat("\n--- summary() ---\n")
print(summary(df))
cat("\n--- dim() ---\n")
print(dim(df))
cat("Final number of observations:", nrow(df), "| final number of variables:", ncol(df), "\n")
cat("Missing values in the final data:", sum(is.na(df)), "\n")


# -----------------------------------------------------------------------------
# Save the cleaned dataset (used by ALL later scripts)
# -----------------------------------------------------------------------------
# Note: CSV does not store factor levels. Later scripts must set the reference
# categories again (No / Entire home/apt / No) after reading this file.
write_csv(df, "data/clean_listings.csv")
cat("\nSaved: data/clean_listings.csv\n")


# =============================================================================
# 1.1 REQUIREMENTS CHECK
# =============================================================================
num_vars <- names(df)[sapply(df, is.numeric) & names(df) != "high_price"]
cat_vars <- names(df)[sapply(df, is.factor)]
binary_iv <- cat_vars[sapply(df[cat_vars], nlevels) == 2]
multi_iv  <- cat_vars[sapply(df[cat_vars], nlevels) >= 3]

req_check <- tibble(
  requirement = c("At least 100 observations",
                  "At least 4 numerical variables",
                  "At least 3 categorical variables",
                  "At least one binary categorical independent variable",
                  "At least one categorical independent variable with 3+ categories",
                  "One numerical dependent variable",
                  "Binary dependent variable derived from it"),
  found = c(format(nrow(df), big.mark = ","),
            paste0(length(num_vars), " (", paste(num_vars, collapse = ", "), ")"),
            paste0(length(cat_vars), " (", paste(cat_vars, collapse = ", "), ")"),
            paste(binary_iv, collapse = ", "),
            paste0(paste(multi_iv, collapse = ", "), " (", nlevels(df$room_type), " levels)"),
            "price",
            "high_price (0/1, threshold = median)"),
  met = c(nrow(df) >= 100,
          length(num_vars) >= 4,
          length(cat_vars) >= 3,
          length(binary_iv) >= 1,
          length(multi_iv) >= 1,
          is.numeric(df$price),
          all(df$high_price %in% c(0, 1)))
)
cat("\n===== 1.1 REQUIREMENTS CHECK =====\n")
print(as.data.frame(req_check), right = FALSE, row.names = FALSE)
# Note: high_price is also categorical but it is the dependent variable,
# so it is NOT counted among the 3 categorical variables above.


# =============================================================================
# 1.1 VARIABLE DESCRIPTION TABLE
# =============================================================================
# Range / levels are computed from the data so the table always matches it.
rng <- function(x) paste0(format(min(x), big.mark = ","), " - ", format(max(x), big.mark = ","))
lvl <- function(x) paste0(levels(x), " (", table(x), ")", collapse = "; ")

var_desc <- tribble(
  ~variable, ~type, ~role, ~description, ~source,
  "price", "Numerical (continuous)", "Dependent variable (linear regression)",
    "Nightly price of the listing in Turkish Lira (TL)", "Raw 'price' converted from text",
  "high_price", "Categorical (binary, 0/1)", "Dependent variable (logistic regression)",
    paste0("1 = price > median (", price_median, " TL), 0 = price <= median"), "Derived from price",
  "accommodates", "Numerical (discrete)", "Independent",
    "Maximum number of guests", "Raw",
  "bedrooms", "Numerical (discrete)", "Independent",
    "Number of bedrooms", "Raw",
  "bathrooms", "Numerical", "Independent",
    "Number of bathrooms (half-bath = 0.5)", "Derived from 'bathrooms_text'",
  "number_of_reviews", "Numerical (discrete)", "Independent",
    "Total number of reviews received", "Raw",
  "availability_365", "Numerical (discrete)", "Independent",
    "Number of days the listing is available in the next 365 days", "Raw",
  "host_is_superhost", "Categorical (binary)", "Independent",
    "Whether the host has Airbnb Superhost status (reference: No)", "Raw (t/f) recoded to No/Yes",
  "room_type", "Categorical (4 categories)", "Independent",
    "Type of the rented space (reference: Entire home/apt)", "Raw",
  "shared_bath", "Categorical (binary)", "Independent",
    "Whether the bathroom is shared (reference: No)", "Derived from 'bathrooms_text'"
)

var_desc$range_or_levels <- sapply(var_desc$variable, function(v) {
  x <- df[[v]]
  if (is.factor(x)) lvl(x)
  else if (v == "high_price") paste0("0 (", sum(x == 0), "); 1 (", sum(x == 1), ")")
  else rng(x)
})

cat("\n===== 1.1 VARIABLE DESCRIPTION TABLE =====\n")
print(as.data.frame(var_desc), right = FALSE, row.names = FALSE)
write_csv(var_desc, "output/tables/variable_description.csv")
cat("Saved: output/tables/variable_description.csv\n")
