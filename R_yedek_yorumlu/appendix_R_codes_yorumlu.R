# #############################################################################
# APPENDIX - R CODES
# Data Mining Midterm Project - Istanbul Airbnb Listings (Inside Airbnb)
# Data: listings.csv.gz, data release 25 Sep 2026 (data collected 28-29 Sep 2026)
#
# All R code used in the project, in the order it was run:
#   Section 1  01_import_explore.R      -> Guideline 1.2, 1.3
#   Section 2  02_cleaning.R            -> Guideline 1.4, 1.5, 1.6 (+ 1.1 tables)
#   Section 3  03_simple_linear.R       -> Guideline 2.1
#   Section 4  04_multiple_linear.R     -> Guideline 2.2 (Step 1-3, Special Rule)
#   Section 5  05_logistic_models.R     -> Guideline 3.1, 3.2, 3.3, 3.4
#   Section 6  06_logistic_evaluation.R -> Guideline 4.1, 4.2, 4.3
#
# Working directory must be the project folder (paths such as
# "data/listings.csv.gz" are relative to it).
# Packages: tidyverse, car, ResourceSelection, DescTools
# #############################################################################


# #############################################################################
# SECTION 1 - 01_import_explore.R
# Guideline: 1.2 Importing the Dataset, 1.3 Initial Dataset Examination
# Covers: data import (read_csv), head/dim/str/summary, detection of data problems
# #############################################################################

# =============================================================================
# 01_import_explore.R
# Data Mining Midterm - Part 1: Data import (1.2) and initial examination (1.3)
# Dataset: Inside Airbnb - Istanbul, listings.csv.gz (data release: 25 Sep 2026; data collected: 28-29 Sep 2026)
#
# IMPORTANT: This script only DETECTS problems. Nothing is modified here.
#            All cleaning is done later in 02_cleaning.R (Guideline 1.4).
#
# How to run in RStudio: open the project folder as working directory
# (Session > Set Working Directory > To Project/Source File Location's parent)
# so that the relative path "data/listings.csv.gz" works, then Source the file.
# =============================================================================

library(tidyverse)   # readr (read_csv), dplyr, stringr, tibble

# Show more columns/rows when printing tibbles
options(width = 120, tibble.width = Inf)


# -----------------------------------------------------------------------------
# 1.2 IMPORTING THE DATASET
# -----------------------------------------------------------------------------
# Original file format: CSV (comma-separated values) compressed with gzip (.csv.gz)
# R function used     : readr::read_csv() - it reads .gz files directly,
#                       no need to unzip first.
# guess_max = 30000   : readr guesses column types from the first rows; we let it
#                       look at all rows so that the guesses are reliable.

file_path <- "data/listings.csv.gz"

listings <- read_csv(file_path, guess_max = 30000, show_col_types = FALSE)

# Any parsing problems while reading? (0 rows = file was read cleanly)
cat("Parsing problems while reading:", nrow(problems(listings)), "\n")

cat("\n===== 1.2 IMPORT REPORT =====\n")
cat("Original file format : CSV compressed with gzip (.csv.gz)\n")
cat("R function used      : readr::read_csv()\n")
cat("Number of observations (rows)   :", nrow(listings), "\n")
cat("Number of variables (columns)   :", ncol(listings), "\n")


# -----------------------------------------------------------------------------
# 1.3 INITIAL DATASET EXAMINATION - the four required functions
# -----------------------------------------------------------------------------

cat("\n===== head() : first 6 rows =====\n")
print(head(listings))

cat("\n===== dim() : rows and columns =====\n")
print(dim(listings))

cat("\n===== str() : type of every variable =====\n")
str(listings, give.attr = FALSE)

cat("\n===== summary() : summary statistics of every variable =====\n")
print(summary(listings))


# -----------------------------------------------------------------------------
# 1.3 PROBLEM DETECTION
# -----------------------------------------------------------------------------

# --- A) Incorrect variable types ---------------------------------------------

# Count of columns by type as read by R
col_types <- sapply(listings, function(x) class(x)[1])
cat("\n===== A) Column types =====\n")
print(table(col_types))

# price should be numeric but it is stored as text like "$4,736.32"
cat("\nClass of price:", class(listings$price), "\n")
cat("Example price values:\n")
print(head(na.omit(listings$price), 5))

# Columns that are completely empty. read_csv() cannot guess a type for them,
# so they appear as 'logical' with only NA values -> wrong / meaningless type.
empty_cols <- names(listings)[colSums(is.na(listings)) == nrow(listings)]
cat("\nCompletely empty columns (", length(empty_cols), "):\n", sep = "")
print(empty_cols)

# The number of bathrooms is not in a numeric column: 'bathrooms' is empty,
# the information is only in the text column 'bathrooms_text'.
cat("\nClass of bathrooms_text:", class(listings$bathrooms_text), "\n")
print(head(unique(listings$bathrooms_text), 8))

# Binary 't'/'f' columns: check that read_csv() converted them to logical.
cat("\nClass of host_is_superhost     :", class(listings$host_is_superhost), "\n")
cat("Class of host_identity_verified:", class(listings$host_identity_verified), "\n")


# --- B) Missing values --------------------------------------------------------

na_table <- tibble(
  variable  = names(listings),
  n_missing = colSums(is.na(listings)),
  pct       = round(100 * n_missing / nrow(listings), 1)
) %>%
  filter(n_missing > 0) %>%
  arrange(desc(n_missing))

cat("\n===== B) Variables with missing values =====\n")
print(na_table, n = Inf)

# Are the missing review scores the listings that never received a review?
cat("\nreview_scores_rating missing           :", sum(is.na(listings$review_scores_rating)), "\n")
cat("listings with number_of_reviews == 0   :", sum(listings$number_of_reviews == 0), "\n")
cat("missing rating AND reviews == 0 (both) :",
    sum(is.na(listings$review_scores_rating) & listings$number_of_reviews == 0), "\n")


# --- C) Incorrect or inconsistent categorical values ------------------------

cat("\n===== C) Categorical variables =====\n")

# room_type: check levels and their sizes (rare categories?)
cat("\nroom_type:\n")
print(table(listings$room_type, useNA = "ifany"))

# host_is_superhost: candidate binary variable
cat("\nhost_is_superhost:\n")
print(table(listings$host_is_superhost, useNA = "ifany"))

# neighbourhood_cleansed: number of districts and check for spelling/space problems
cat("\nneighbourhood_cleansed - number of districts:",
    n_distinct(listings$neighbourhood_cleansed), "\n")
cat("Values with extra spaces:",
    sum(listings$neighbourhood_cleansed != str_squish(listings$neighbourhood_cleansed)), "\n")
print(sort(table(listings$neighbourhood_cleansed), decreasing = TRUE))

# bathrooms_text: one text column mixes two pieces of information
# (number of baths + private/shared), and some values have no number at all
cat("\nbathrooms_text - number of different values:",
    n_distinct(listings$bathrooms_text), "\n")
bath_no_number <- listings %>%
  filter(!is.na(bathrooms_text), !str_detect(bathrooms_text, "[0-9]")) %>%
  count(bathrooms_text)
cat("bathrooms_text values without a number:\n")
print(bath_no_number)

# property_type: very many levels, many of them very small
pt_counts <- count(listings, property_type, sort = TRUE)
cat("\nproperty_type - number of levels:", nrow(pt_counts),
    "| levels with fewer than 30 listings:", sum(pt_counts$n < 30), "\n")

# license: free text, many different formats
cat("\nlicense - number of different values:", n_distinct(listings$license), "\n")
print(head(count(listings, license, sort = TRUE), 8))


# --- D) Unusual numerical values ---------------------------------------------

# Temporary numeric version of price ONLY for inspection (not saved, data unchanged)
price_num <- parse_number(listings$price)

cat("\n===== D) Unusual numerical values =====\n")
cat("\nprice (as number) percentiles:\n")
print(quantile(price_num, c(0, .01, .05, .25, .5, .75, .95, .99, 1), na.rm = TRUE))

# Classic boxplot (1.5 x IQR) rule just to COUNT extreme values
q1  <- quantile(price_num, .25, na.rm = TRUE)
q3  <- quantile(price_num, .75, na.rm = TRUE)
upper_fence <- q3 + 1.5 * (q3 - q1)
cat("price upper fence (Q3 + 1.5*IQR):", round(upper_fence, 2),
    "| listings above it:", sum(price_num > upper_fence, na.rm = TRUE), "\n")
cat("price above 100,000:", sum(price_num > 100000, na.rm = TRUE), "\n")

# Min / median / max of the main numeric candidates
num_vars <- c("accommodates", "bedrooms", "beds", "minimum_nights", "maximum_nights",
              "number_of_reviews", "review_scores_rating", "availability_365",
              "reviews_per_month")
num_overview <- listings %>%
  select(all_of(num_vars)) %>%
  pivot_longer(everything(), names_to = "variable") %>%
  group_by(variable) %>%
  summarise(min    = min(value, na.rm = TRUE),
            p01    = quantile(value, .01, na.rm = TRUE),
            median = median(value, na.rm = TRUE),
            p99    = quantile(value, .99, na.rm = TRUE),
            max    = max(value, na.rm = TRUE))
cat("\nNumeric candidates (min, 1%, median, 99%, max):\n")
print(num_overview)

# minimum_nights: the value 100 is surprisingly frequent
cat("\nMost frequent minimum_nights values:\n")
print(head(sort(table(listings$minimum_nights), decreasing = TRUE), 8))


# --- E) Potential data entry errors -----------------------------------------

cat("\n===== E) Potential data entry errors =====\n")
# Airbnb review scores are on a 1-5 scale; 0 is not a valid score
cat("review_scores_rating == 0       :", sum(listings$review_scores_rating == 0, na.rm = TRUE), "\n")
# More bedrooms than guests is implausible
cat("bedrooms > accommodates         :", sum(listings$bedrooms > listings$accommodates, na.rm = TRUE), "\n")
# More than two beds per guest is implausible
cat("beds > 2 * accommodates         :", sum(listings$beds > 2 * listings$accommodates, na.rm = TRUE), "\n")
# Airbnb's maximum for maximum_nights is 1125
cat("maximum_nights > 1125           :", sum(listings$maximum_nights > 1125), "\n")
# A whole home/apartment with 0 bathrooms is implausible
cat("Entire home/apt with '0 baths'  :",
    sum(listings$room_type == "Entire home/apt" &
          listings$bathrooms_text %in% c("0 baths", "0 shared baths"), na.rm = TRUE), "\n")
# Duplicated listing ids
cat("Duplicated id                   :", sum(duplicated(listings$id)), "\n")


# -----------------------------------------------------------------------------
# PROBLEM SUMMARY TABLE (problem, variable, number of rows, example)
# -----------------------------------------------------------------------------
# Helper: first example value of a variable for the rows matching a condition
ex <- function(x, cond) as.character(x[which(cond)[1]])

L <- listings   # short name to keep the table code readable

problem_summary <- tribble(
  ~problem, ~variable, ~n_rows, ~example,

  # A) Incorrect types
  "Incorrect type: number stored as text ($ and comma)", "price",
  sum(!is.na(L$price)), ex(L$price, !is.na(L$price)),

  "Incorrect type: completely empty column (read as logical, all NA)",
  paste(length(empty_cols), "columns, e.g. bathrooms, instant_bookable, host_since"),
  nrow(L), "(all values empty)",

  "Incorrect type: number of baths only inside text", "bathrooms_text",
  sum(!is.na(L$bathrooms_text)), ex(L$bathrooms_text, L$bathrooms_text == "1.5 shared baths"),

  # B) Missing values
  "Missing value", "price", sum(is.na(L$price)), "(empty cell)",
  "Missing value (listings with 0 reviews)", "review_scores_rating", sum(is.na(L$review_scores_rating)), "(empty cell)",
  "Missing value (listings with 0 reviews)", "reviews_per_month", sum(is.na(L$reviews_per_month)), "(empty cell)",
  "Missing value", "beds", sum(is.na(L$beds)), "(empty cell)",
  "Missing value", "bathrooms_text", sum(is.na(L$bathrooms_text)), "(empty cell)",
  "Missing value", "bedrooms", sum(is.na(L$bedrooms)), "(empty cell)",

  # C) Inconsistent categorical values
  "Inconsistent category: bath text without a number", "bathrooms_text",
  sum(bath_no_number$n), paste(bath_no_number$bathrooms_text, collapse = " / "),

  "Rare categories", "room_type",
  sum(L$room_type %in% c("Hotel room", "Shared room")), "Hotel room (272), Shared room (158)",

  "Too many categories (39 districts)", "neighbourhood_cleansed",
  nrow(L), "Beyoglu 7447 ... smallest districts < 20",

  "Too many / very small categories", "property_type",
  sum(L$property_type %in% pt_counts$property_type[pt_counts$n < 30]),
  paste(nrow(pt_counts), "levels"),

  "Mixed free-text formats", "license",
  sum(!is.na(L$license)), "34-1476 / Exempt / Non-real estate listing",

  # D) Unusual numerical values
  "Extreme value (above Q3 + 1.5*IQR)", "price",
  sum(price_num > upper_fence, na.rm = TRUE), as.character(max(price_num, na.rm = TRUE)),

  "Suspicious frequent value (likely monthly rentals)", "minimum_nights",
  sum(L$minimum_nights == 100), "100",

  "Extreme value (more than 365 nights)", "minimum_nights",
  sum(L$minimum_nights > 365), as.character(max(L$minimum_nights)),

  "Extreme value", "bedrooms / beds",
  sum(L$bedrooms >= 20 | L$beds >= 30, na.rm = TRUE),
  paste0("bedrooms max ", max(L$bedrooms, na.rm = TRUE), ", beds max ", max(L$beds, na.rm = TRUE)),

  # E) Potential data entry errors
  "Invalid value (scale is 1-5)", "review_scores_rating",
  sum(L$review_scores_rating == 0, na.rm = TRUE), "0",

  "Implausible: more bedrooms than guests", "bedrooms vs accommodates",
  sum(L$bedrooms > L$accommodates, na.rm = TRUE),
  with(L[which(L$bedrooms > L$accommodates)[1], ], paste0(bedrooms, " bedrooms, ", accommodates, " guests")),

  "Implausible: more than 2 beds per guest", "beds vs accommodates",
  sum(L$beds > 2 * L$accommodates, na.rm = TRUE),
  with(L[which(L$beds > 2 * L$accommodates)[1], ], paste0(beds, " beds, ", accommodates, " guests")),

  "Above Airbnb limit (1125)", "maximum_nights",
  sum(L$maximum_nights > 1125), as.character(max(L$maximum_nights)),

  "Implausible: entire home with 0 baths", "bathrooms_text",
  sum(L$room_type == "Entire home/apt" & L$bathrooms_text %in% c("0 baths", "0 shared baths"), na.rm = TRUE),
  "Entire home/apt, 0 baths"
)

cat("\n===== PROBLEM SUMMARY =====\n")
print(as.data.frame(problem_summary), right = FALSE)   # data.frame prints long text on one line

# Save the summary table for the report (data itself is NOT changed)
write_csv(problem_summary, "output/tables/01_problem_summary.csv")
cat("\nSaved: output/tables/01_problem_summary.csv\n")


# #############################################################################
# SECTION 2 - 02_cleaning.R
# Guideline: 1.4 Data Cleaning, 1.5 Binary Dependent Variable, 1.6 Final Verification, 1.1 tables
# Covers: cleaning steps, variable creation (bathrooms, shared_bath, high_price), str/summary/dim, requirements check, variable description table
# #############################################################################

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


# #############################################################################
# SECTION 3 - 03_simple_linear.R
# Guideline: 2.1 Simple Linear Regression
# Covers: price ~ accommodates, correlation, F and t tests, equation, R2, predictions
# #############################################################################

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


# #############################################################################
# SECTION 4 - 04_multiple_linear.R
# Guideline: 2.2 Multiple Linear Regression (Step 1, Step 2, Step 3, Special Rule)
# Covers: initial model, car::Anova for room_type, backward elimination, final model, Table 1 and Table 2 (with note)
# #############################################################################

# =============================================================================
# 04_multiple_linear.R
# Data Mining Midterm - Part 2.2: Multiple Linear Regression (mixed predictors)
# Y = price (TL)
# Data: data/clean_listings.csv (output of 02_cleaning.R)
# =============================================================================

library(tidyverse)
library(car)       # Anova(): significance of a categorical variable AS A WHOLE

listings <- read_csv("data/clean_listings.csv", show_col_types = FALSE)
cat("Data:", nrow(listings), "rows,", ncol(listings), "columns\n")


# =============================================================================
# STEP 1 - INITIAL MODEL
# =============================================================================

# --- 1. Dependent and independent variables ---------------------------------
# Y : price (nightly price, TL)
# Numerical X  : accommodates, bedrooms, bathrooms, number_of_reviews, availability_365
# Binary X     : host_is_superhost, shared_bath
# 3+ category X: room_type (4 categories)

# --- 2-3. Convert categorical variables into factors, set reference categories
# A CSV file does not store factor levels, so they are set again here.
# The FIRST level is the reference category.
#   host_is_superhost: "No" (= FALSE, not a superhost) -> reference
#   shared_bath      : "No" (= Hayir, private bathroom) -> reference
#   room_type        : "Entire home/apt"                -> reference
listings <- listings %>%
  mutate(
    host_is_superhost = factor(host_is_superhost, levels = c("No", "Yes")),
    shared_bath       = factor(shared_bath,       levels = c("No", "Yes")),
    room_type         = factor(room_type, levels = c("Entire home/apt", "Private room",
                                                     "Hotel room", "Shared room"))
  )

cat("\n===== Reference categories =====\n")
cat("host_is_superhost :", levels(listings$host_is_superhost)[1], "(= FALSE, not a superhost)\n")
cat("shared_bath       :", levels(listings$shared_bath)[1], "(= private bathroom)\n")
cat("room_type         :", levels(listings$room_type)[1], "\n")

# --- 4. Estimate the initial model ------------------------------------------
initial_formula <- price ~ accommodates + bedrooms + bathrooms + number_of_reviews +
  availability_365 + host_is_superhost + shared_bath + room_type

model_initial <- lm(initial_formula, data = listings)

cat("\n===== STEP 1: INITIAL MODEL =====\n")
print(summary(model_initial))

# --- Helper functions used for both the initial and the final model ---------

# Overall F test of a model: F value, degrees of freedom and p-value
overall_f <- function(model) {
  f <- summary(model)$fstatistic
  tibble(F = unname(f["value"]), df1 = unname(f["numdf"]), df2 = unname(f["dendf"]),
         p = pf(f["value"], f["numdf"], f["dendf"], lower.tail = FALSE))
}

# Significance of each VARIABLE (not each dummy) with car::Anova (Type II).
# For a 1-df variable this p-value is identical to the t-test p-value;
# for room_type (3 dummies) it tests all categories together (partial F test).
variable_tests <- function(model) {
  a <- Anova(model, type = 2)
  tibble(variable = rownames(a), df = a$Df, F_value = a$`F value`, p_value = a$`Pr(>F)`) %>%
    filter(variable != "Residuals") %>%
    mutate(significant = p_value < 0.05)
}

# p-value written for the report (very small p-values are shown as "< 0.001")
p_txt <- function(p) ifelse(p < 0.001, "< 0.001", sprintf("%.3f", p))

# --- 5. Overall significance (F test) ---------------------------------------
f_initial <- overall_f(model_initial)
cat("\n----- Overall F test (initial model) -----\n")
cat(sprintf("F(%d, %d) = %.2f, p = %s -> %s\n", f_initial$df1, f_initial$df2, f_initial$F,
            p_txt(f_initial$p),
            ifelse(f_initial$p < 0.05, "model is significant", "model is not significant")))

# --- 6. Significance of each independent variable ---------------------------
cat("\n----- p-value of every coefficient (t tests) -----\n")
print(round(summary(model_initial)$coefficients, 4))

# Variable-level p-values (used for the significant / nonsignificant lists and
# for Step 2). Only room_type is printed: for the 1-df variables the Anova
# p-value is identical to the t-test p-value printed above.
tests_initial <- variable_tests(model_initial)

# room_type as a whole (3 dummy variables tested together, car::Anova partial F test)
cat("\n----- room_type as a whole (car::Anova, Type II) -----\n")
rt <- filter(tests_initial, variable == "room_type")
cat(sprintf("\nroom_type as a whole: F(%d, %d) = %.2f, p = %s -> %s\n",
            rt$df, f_initial$df2, rt$F_value, p_txt(rt$p_value),
            ifelse(rt$significant, "significant", "not significant")))

# --- 7. Significant and nonsignificant predictors ---------------------------
cat("\nSignificant predictors (p < 0.05)    :",
    paste(tests_initial$variable[tests_initial$significant], collapse = ", "), "\n")
cat("Nonsignificant predictors (p >= 0.05):",
    ifelse(any(!tests_initial$significant),
           paste(tests_initial$variable[!tests_initial$significant], collapse = ", "),
           "none"), "\n")
# (8. Interpretation of the coefficients -> notlar/04_coklu_regresyon.md)


# =============================================================================
# STEP 2 - MODEL REVISION (backward elimination, one variable at a time)
# =============================================================================
# Rule: if any variable has p >= 0.05, remove the ONE with the highest p-value,
# re-estimate the model and check again. Repeat until all variables are significant.
# The p-values come from car::Anova so that room_type is judged as a whole.

cat("\n===== STEP 2: MODEL REVISION =====\n")

current_model <- model_initial
revision_log  <- tibble(step = integer(), removed_variable = character(),
                        p_value = numeric(), r2 = numeric(), adj_r2 = numeric())
models <- list(step0_initial = model_initial)   # every model is stored here
step <- 0

repeat {
  tests <- variable_tests(current_model)
  worst <- tests %>% slice_max(p_value, n = 1)          # variable with the highest p

  if (worst$p_value < 0.05) break                        # all significant -> stop

  step <- step + 1
  cat(sprintf("Step %d: remove '%s' (p = %.4f) and re-estimate\n",
              step, worst$variable, worst$p_value))

  # update(): same model without the removed variable
  current_model <- update(current_model, as.formula(paste(". ~ . -", worst$variable)))
  models[[paste0("step", step, "_without_", worst$variable)]] <- current_model

  revision_log <- add_row(revision_log, step = step, removed_variable = worst$variable,
                          p_value = worst$p_value,
                          r2 = summary(current_model)$r.squared,
                          adj_r2 = summary(current_model)$adj.r.squared)
}

if (step == 0) {
  cat("All variables in the initial model are significant (p < 0.05).\n")
  cat("No variable is removed -> the FINAL model is the SAME as the initial model.\n")
} else {
  cat("\nRevision log:\n")
  print(as.data.frame(revision_log), row.names = FALSE)
}
write_csv(revision_log, "output/tables/04_revision_log.csv")

model_final <- current_model


# =============================================================================
# STEP 3 - FINAL MODEL
# =============================================================================
cat("\n===== STEP 3: FINAL MODEL =====\n")
print(summary(model_final))

# 1-2. Overall significance
f_final <- overall_f(model_final)
cat(sprintf("Overall F test: F(%d, %d) = %.2f, p = %s\n",
            f_final$df1, f_final$df2, f_final$F, p_txt(f_final$p)))

tests_final <- variable_tests(model_final)
# Only room_type is printed (1-df variables: same p-values as the t tests in the summary above)
rt_final <- filter(tests_final, variable == "room_type")
if (nrow(rt_final) == 1) {
  cat(sprintf("room_type as a whole (car::Anova): F(%d, %d) = %.2f, p = %s\n",
              rt_final$df, f_final$df2, rt_final$F_value, p_txt(rt_final$p_value)))
}

# Mean price by room type (descriptive) - helps to interpret the room_type
# coefficients: the raw differences are much larger than the adjusted ones
# because private/shared rooms also have fewer bedrooms, baths and guests.
cat("\nMean price and mean bedrooms by room type (descriptive):\n")
print(as.data.frame(listings %>% group_by(room_type) %>%
                      summarise(n = n(), mean_price = round(mean(price), 2),
                                mean_bedrooms = round(mean(bedrooms), 2))),
      row.names = FALSE)

# 4. Final estimated regression equation
b <- coef(model_final)
eq_terms <- sprintf("%s %.2f*%s", ifelse(b[-1] >= 0, "+", "-"), abs(b[-1]), names(b)[-1])
cat("\nFinal estimated regression equation:\n")
cat(sprintf("predicted price = %.2f %s\n", b[1], paste(eq_terms, collapse = " ")))
cat("(Dummy variables are 1 for that category and 0 otherwise.)\n")

# 5-6. R2, adjusted R2 and comparison with the initial model
comparison <- tibble(
  model        = c("Initial", "Final"),
  n_variables  = c(nrow(tests_initial), nrow(tests_final)),
  n_coefs      = c(length(coef(model_initial)), length(coef(model_final))),
  F            = c(f_initial$F, f_final$F),
  r2           = c(summary(model_initial)$r.squared, summary(model_final)$r.squared),
  adj_r2       = c(summary(model_initial)$adj.r.squared, summary(model_final)$adj.r.squared)
)
cat("\nInitial vs final model:\n")
print(as.data.frame(comparison), row.names = FALSE, digits = 6)
cat(sprintf("R2 of simple linear model (accommodates only, 2.1) for reference: %.4f\n",
            summary(lm(price ~ accommodates, data = listings))$r.squared))
write_csv(comparison, "output/tables/04_model_comparison.csv")


# -----------------------------------------------------------------------------
# SPECIAL RULE - does the final model contain both numerical and categorical X?
# -----------------------------------------------------------------------------
numeric_x     <- c("accommodates", "bedrooms", "bathrooms", "number_of_reviews", "availability_365")
categorical_x <- c("host_is_superhost", "shared_bath", "room_type")
final_vars    <- tests_final$variable

has_num <- any(final_vars %in% numeric_x)
has_cat <- any(final_vars %in% categorical_x)

cat("\n===== SPECIAL RULE CHECK =====\n")
cat("Numerical variables in final model  :", paste(intersect(final_vars, numeric_x), collapse = ", "), "\n")
cat("Categorical variables in final model:", paste(intersect(final_vars, categorical_x), collapse = ", "), "\n")
if (has_num && has_cat) {
  cat("Both types are present -> interpret at least one numerical and one categorical coefficient\n")
  cat("from the FINAL model.\n")
} else if (has_num) {
  cat("Only numerical variables remain -> a categorical coefficient from the INITIAL model\n")
  cat("must also be interpreted and stated as NOT significant.\n")
} else {
  cat("Only categorical variables remain -> a numerical coefficient from the INITIAL model\n")
  cat("must also be interpreted and stated as NOT significant.\n")
}


# -----------------------------------------------------------------------------
# TABLE 1 (initial model) and TABLE 2 (final model)
# -----------------------------------------------------------------------------
# Coefficient rows: B, SE, t, p. Bottom rows: model statistics.
# For 'room_type (as a whole)' and 'F-statistic' rows, 'estimate' holds the F value.
make_table <- function(model, tests) {
  co <- summary(model)$coefficients
  f  <- overall_f(model)
  s  <- summary(model)
  rt <- filter(tests, variable == "room_type")

  coef_rows <- tibble(term = rownames(co), estimate = co[, 1], std_error = co[, 2],
                      t_value = co[, 3], p_value = co[, 4])
  extra_rows <- tibble(
    term      = c(if (nrow(rt) == 1) sprintf("room_type as a whole (Anova F, df = %d)", rt$df),
                  sprintf("F-statistic (df = %d, %d)", f$df1, f$df2),
                  "R-squared", "Adjusted R-squared", "Number of observations"),
    estimate  = c(if (nrow(rt) == 1) rt$F_value, f$F, s$r.squared, s$adj.r.squared, nobs(model)),
    std_error = NA, t_value = NA,
    p_value   = c(if (nrow(rt) == 1) rt$p_value, f$p, NA, NA, NA)
  )
  bind_rows(coef_rows, extra_rows) %>%
    mutate(estimate = round(estimate, 4), std_error = round(std_error, 4),
           t_value = round(t_value, 3),
           significance = case_when(is.na(p_value) ~ NA_character_,
                                    p_value < 0.05 ~ "significant", TRUE ~ "not significant"),
           p_report = ifelse(is.na(p_value), NA, p_txt(p_value)))
}

table1 <- make_table(model_initial, tests_initial)
table2 <- make_table(model_final, tests_final)

# Note under Table 2: why room_type stays although two of its dummies are not
# significant on their own (Guideline 2.2 Step 2: judge the variable as a whole)
if (nrow(rt_final) == 1) {
  ns_dummies <- table2$term[startsWith(table2$term, "room_type") &
                              !is.na(table2$significance) & table2$significance == "not significant"]
  table2_note <- sprintf(paste0(
    "Note: room_type is significant as a whole (car::Anova partial F test: F(%d, %d) = %.2f, p %s). ",
    "%s %s not significant on %s own, but a multicategory variable is judged as a whole ",
    "(Guideline 2.2 Step 2), so room_type is kept with all its categories."),
    rt_final$df, f_final$df2, rt_final$F_value,
    ifelse(rt_final$p_value < 0.001, "< 0.001", paste("=", sprintf("%.3f", rt_final$p_value))),
    paste(sub("room_type", "", ns_dummies), collapse = " and "),
    ifelse(length(ns_dummies) > 1, "are", "is"), ifelse(length(ns_dummies) > 1, "their", "its"))
  if (length(ns_dummies) > 0) {
    table2 <- add_row(table2, term = table2_note)
  }
}

cat("\n===== TABLE 1. Initial Multiple Linear Regression Model =====\n")
print(as.data.frame(table1), row.names = FALSE)
cat("\n===== TABLE 2. Final Multiple Linear Regression Model =====\n")
print(as.data.frame(filter(table2, !startsWith(term, "Note:"))), row.names = FALSE)
if (exists("table2_note") && any(startsWith(table2$term, "Note:"))) cat(strwrap(table2_note, 110), sep = "\n")

write_csv(table1, "output/tables/04_table1_initial_model.csv")
write_csv(table2, "output/tables/04_table2_final_model.csv")
cat("\nSaved: output/tables/04_table1_initial_model.csv, 04_table2_final_model.csv,",
    "04_revision_log.csv, 04_model_comparison.csv\n")


# #############################################################################
# SECTION 5 - 05_logistic_models.R
# Guideline: 3.1 Model 1, 3.2 Model 2, 3.3 Model 3, 3.4 Model 4
# Covers: four binary logistic regression models, B, SE, z, p, Exp(B), predicted probabilities
# #############################################################################

# =============================================================================
# 05_logistic_models.R
# Data Mining Midterm - Part 3: Binary Logistic Regression (Models 1-4)
# Dependent variable: high_price (1 = price > median 4457.5 TL, 0 = otherwise)
# Data: data/clean_listings.csv (output of 02_cleaning.R)
#
# IMPORTANT: price itself is NEVER used as an independent variable
#            (high_price is derived from it - Guideline 1.1).
# Goodness of fit (Hosmer-Lemeshow, pseudo R2), confusion matrices / accuracy
# and probability curves are done in 06_logistic_evaluation.R (Part 4).
# =============================================================================

library(tidyverse)
library(car)       # Anova(): significance of room_type as a whole

listings <- read_csv("data/clean_listings.csv", show_col_types = FALSE)

# Reference categories = first factor level (same as in the linear models)
listings <- listings %>%
  mutate(
    host_is_superhost = factor(host_is_superhost, levels = c("No", "Yes")),
    shared_bath       = factor(shared_bath,       levels = c("No", "Yes")),
    room_type         = factor(room_type, levels = c("Entire home/apt", "Private room",
                                                     "Hotel room", "Shared room"))
  )

cat("Data:", nrow(listings), "rows\n")
cat("high_price distribution:\n")
print(table(listings$high_price))

# logit(p) = ln[p / (1 - p)] = b0 + b1*X1 + ... ; Exp(B) = odds ratio


# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------
p_txt <- function(p) ifelse(p < 0.001, "< 0.001", sprintf("%.3f", p))

# Coefficient table: B, standard error, z (Wald), p, Exp(B)
coef_table <- function(model) {
  co <- summary(model)$coefficients
  tibble(term      = rownames(co),
         B         = round(co[, "Estimate"], 6),
         std_error = round(co[, "Std. Error"], 6),
         z_value   = round(co[, "z value"], 3),
         p_value   = co[, "Pr(>|z|)"],
         exp_B     = round(exp(co[, "Estimate"]), 4),
         p_report  = p_txt(co[, "Pr(>|z|)"]),
         significance = ifelse(co[, "Pr(>|z|)"] < 0.05, "significant", "not significant"))
}

show_model <- function(model, name, file) {
  cat("\n=====================================================================\n")
  cat(name, "\n")
  cat("=====================================================================\n")
  print(summary(model))
  tab <- coef_table(model)
  cat("Coefficient table with Exp(B):\n")
  print(as.data.frame(tab), row.names = FALSE)
  write_csv(tab, file)
  cat("Saved:", file, "\n")
  invisible(tab)
}


# =============================================================================
# 3.1 MODEL 1 - Numerical independent variable: accommodates
# =============================================================================
# 1. Estimate the model
model1 <- glm(high_price ~ accommodates, data = listings, family = binomial)
tab1 <- show_model(model1, "MODEL 1: high_price ~ accommodates",
                   "output/tables/05_model1.csv")

b0 <- coef(model1)[1]; b1 <- coef(model1)[2]

# 2. Significance of accommodates (Wald z test)
cat(sprintf("\nItem 2: z = %.2f, p = %s -> accommodates is %s\n",
            tab1$z_value[2], tab1$p_report[2],
            ifelse(tab1$p_value[2] < 0.05, "significant", "not significant")))

# 3-4. B and Exp(B)
cat(sprintf("Item 3: B = %.4f -> each extra guest increases the LOG-ODDS of high price by %.4f\n", b1, b1))
cat(sprintf("Item 4: Exp(B) = %.4f -> each extra guest multiplies the ODDS of high price by %.4f (%+.1f%%)\n",
            exp(b1), exp(b1), 100 * (exp(b1) - 1)))

# 5. Estimated logistic regression equation
cat("\nItem 5: estimated logistic regression equation\n")
cat(sprintf("logit(p) = ln[p/(1-p)] = %.4f %s %.4f * accommodates\n",
            b0, ifelse(b1 >= 0, "+", "-"), abs(b1)))
cat(sprintf("p = 1 / (1 + exp(-(%.4f + %.4f * accommodates)))\n", b0, b1))

# 6. Predicted probabilities for example listings (2, 4 and 6 guests)
examples <- tibble(accommodates = c(2, 4, 6)) %>%
  mutate(logit      = b0 + b1 * accommodates,                  # linear predictor
         odds       = exp(logit),                              # odds = p / (1 - p)
         probability = predict(model1, newdata = tibble(accommodates), type = "response"))
cat("\nItem 6: predicted probabilities of high price\n")
print(as.data.frame(examples), row.names = FALSE, digits = 4)
write_csv(examples, "output/tables/05_model1_predicted_probabilities.csv")

# Predicted probability for every listing (used again in Part 4)
listings$prob_model1 <- predict(model1, type = "response")
cat("Predicted probabilities for all listings - summary:\n")
print(summary(listings$prob_model1))


# =============================================================================
# 3.2 MODEL 2 - Binary categorical independent variable: host_is_superhost
# =============================================================================
# 1. Reference category
cat("\n\nMODEL 2 reference category of host_is_superhost:", levels(listings$host_is_superhost)[1],
    "(not a superhost)\n")

# 2. Estimate the model
model2 <- glm(high_price ~ host_is_superhost, data = listings, family = binomial)
tab2 <- show_model(model2, "MODEL 2: high_price ~ host_is_superhost",
                   "output/tables/05_model2.csv")

# 3-4. Significance, B and Exp(B)
cat(sprintf("\nSuperhost = Yes: B = %.4f, z = %.2f, p = %s, Exp(B) = %.4f\n",
            tab2$B[2], tab2$z_value[2], tab2$p_report[2], tab2$exp_B[2]))

# Probability and odds in each group (helps to understand what Exp(B) means)
grp2 <- tibble(host_is_superhost = factor(c("No", "Yes"), levels = c("No", "Yes"))) %>%
  mutate(probability = predict(model2, newdata = ., type = "response"),
         odds        = probability / (1 - probability))
cat("Predicted probability and odds of high price per group:\n")
print(as.data.frame(grp2), row.names = FALSE, digits = 4)
# (5-6: goodness of fit and accuracy -> Part 4)


# =============================================================================
# 3.3 MODEL 3 - Multicategory independent variable: room_type
# =============================================================================
# 1. room_type was converted into a factor at the top of the script
cat("\n\nMODEL 3: room_type is a factor:", is.factor(listings$room_type), "\n")
# 2. Reference category
cat("Reference category of room_type:", levels(listings$room_type)[1], "\n")

# 3. Estimate the model
model3 <- glm(high_price ~ room_type, data = listings, family = binomial)
# 4-5. Coefficients and Exp(B)
tab3 <- show_model(model3, "MODEL 3: high_price ~ room_type",
                   "output/tables/05_model3.csv")

# room_type as a whole (likelihood-ratio chi-square test of all 3 dummies together)
cat("\nroom_type as a whole (car::Anova, likelihood-ratio test):\n")
a3 <- Anova(model3, type = 2)
print(a3)

# How the odds of each category differ from the reference
cat("\nOdds of each category compared with Entire home/apt:\n")
for (i in 2:nrow(tab3)) {
  cat(sprintf("  %-22s Exp(B) = %.4f -> odds are %.1f%% %s than Entire home/apt (p = %s)\n",
              sub("room_type", "", tab3$term[i]), tab3$exp_B[i],
              abs(100 * (tab3$exp_B[i] - 1)), ifelse(tab3$exp_B[i] > 1, "higher", "lower"),
              tab3$p_report[i]))
}

# Probability and odds in each category
grp3 <- tibble(room_type = factor(levels(listings$room_type), levels = levels(listings$room_type))) %>%
  mutate(n           = as.vector(table(listings$room_type)),
         probability = predict(model3, newdata = ., type = "response"),
         odds        = probability / (1 - probability),
         odds_ratio_vs_ref = odds / odds[1])
cat("\nPredicted probability, odds and odds ratio per category:\n")
print(as.data.frame(grp3), row.names = FALSE, digits = 4)
# (6-7: goodness of fit and accuracy -> Part 4)


# =============================================================================
# 3.4 MODEL 4 - Multiple logistic regression with mixed predictors
# =============================================================================
# 1. Independent variables
#    Numerical  : accommodates, bedrooms, bathrooms, number_of_reviews, availability_365
#    Categorical: host_is_superhost (ref No), shared_bath (ref No), room_type (ref Entire home/apt)
cat("\n\nMODEL 4 independent variables:\n")
cat("  Numerical  : accommodates, bedrooms, bathrooms, number_of_reviews, availability_365\n")
cat("  Categorical: host_is_superhost (ref = No), shared_bath (ref = No),",
    "room_type (ref = Entire home/apt)\n")

# 2. Estimate the model
model4 <- glm(high_price ~ accommodates + bedrooms + bathrooms + number_of_reviews +
                availability_365 + host_is_superhost + shared_bath + room_type,
              data = listings, family = binomial)
tab4 <- show_model(model4, "MODEL 4: mixed predictors",
                   "output/tables/05_model4.csv")

# 3. Significance of predictors; room_type is judged as a whole (same logic as in 2.2)
# Only room_type is tested as a whole (3 dummies together, likelihood-ratio test);
# the other predictors have 1 df and their z tests above are sufficient.
a4 <- Anova(model4, type = 2)
cat(sprintf("\nroom_type as a whole (car::Anova, likelihood-ratio test): Chi-square(%d) = %.2f, p = %s\n",
            a4["room_type", "Df"], a4["room_type", "LR Chisq"], p_txt(a4["room_type", "Pr(>Chisq)"])))

# 4-6. Numerical and categorical coefficients with Exp(B)
num_terms <- c("accommodates", "bedrooms", "bathrooms", "number_of_reviews", "availability_365")
cat("\nNumerical coefficients (effect of +1 unit, other variables held constant):\n")
print(as.data.frame(tab4 %>% filter(term %in% num_terms) %>%
                      mutate(odds_change_pct = round(100 * (exp_B - 1), 2)) %>%
                      select(term, B, exp_B, odds_change_pct, p_report)), row.names = FALSE)

# number_of_reviews and availability_365 have very small units; the odds ratio
# for a 100-unit increase (100 reviews / 100 days) is easier to interpret: exp(100 * B)
cat("\nOdds ratio for +100 units (exp(100 * B)):\n")
print(as.data.frame(tab4 %>% filter(term %in% c("number_of_reviews", "availability_365")) %>%
                      transmute(term, odds_ratio_100 = round(exp(100 * B), 4),
                                odds_change_pct_100 = round(100 * (exp(100 * B) - 1), 2))),
      row.names = FALSE)

cat("\nCategorical coefficients (vs reference category, other variables held constant):\n")
print(as.data.frame(tab4 %>% filter(!term %in% c("(Intercept)", num_terms)) %>%
                      mutate(odds_change_pct = round(100 * (exp_B - 1), 2)) %>%
                      select(term, B, exp_B, odds_change_pct, p_report)), row.names = FALSE)
# (7-8: goodness of fit and accuracy -> Part 4)


# Save the four models so that 06_logistic_evaluation.R can reuse them
saveRDS(list(model1 = model1, model2 = model2, model3 = model3, model4 = model4),
        "output/05_logistic_models.rds")
cat("\nSaved: output/05_logistic_models.rds\n")


# #############################################################################
# SECTION 6 - 06_logistic_evaluation.R
# Guideline: 4.1 Goodness of Fit, 4.2 Classification Accuracy, 4.3 Logistic Regression Graph
# Covers: Hosmer-Lemeshow, pseudo R2 (+ Cox & Snell maximum), confusion matrices, accuracy, probability graphs
# #############################################################################

# =============================================================================
# 06_logistic_evaluation.R
# Data Mining Midterm - Part 4: Logistic regression model evaluation
#   4.1 Goodness of fit  : Hosmer-Lemeshow test, McFadden / Cox & Snell / Nagelkerke pseudo R2
#   4.2 Classification   : threshold 0.50, confusion matrix, accuracy
#   4.3 Probability graphs for Models 1-4
# Models come from 05_logistic_models.R (output/05_logistic_models.rds).
# =============================================================================

library(tidyverse)
library(ResourceSelection)   # hoslem.test()
library(DescTools)           # PseudoR2()

models <- readRDS("output/05_logistic_models.rds")   # model1 ... model4

# Same cleaned data with the same reference categories (needed for Model 4 graph)
listings <- read_csv("data/clean_listings.csv", show_col_types = FALSE) %>%
  mutate(
    host_is_superhost = factor(host_is_superhost, levels = c("No", "Yes")),
    shared_bath       = factor(shared_bath,       levels = c("No", "Yes")),
    room_type         = factor(room_type, levels = c("Entire home/apt", "Private room",
                                                     "Hotel room", "Shared room"))
  )

model_names <- c(model1 = "Model 1: accommodates",
                 model2 = "Model 2: host_is_superhost",
                 model3 = "Model 3: room_type",
                 model4 = "Model 4: mixed predictors")

p_txt <- function(p) ifelse(is.na(p), NA, ifelse(p < 0.001, "< 0.001", sprintf("%.3f", p)))


# =============================================================================
# 4.1 GOODNESS OF FIT
# =============================================================================

# --- Hosmer-Lemeshow test ----------------------------------------------------
# H0: the model fits the data well (observed and predicted frequencies agree)
# p > 0.05 -> H0 not rejected -> no evidence of poor fit (good fit)
#
# The test sorts listings by predicted probability into g = 10 groups (deciles)
# and compares observed vs expected numbers of 1s in each group.
# It needs MANY different predicted probabilities. If a model contains only
# categorical predictors, every listing in the same category gets the SAME
# probability (Model 2: 2 values, Model 3: 4 values). Such a model reproduces
# the observed proportion of each category exactly (saturated), so:
#   - 10 groups cannot be formed (only 2 or 4 distinct values exist), and
#   - observed = expected in every category by construction -> the statistic
#     is 0 and carries no information about fit.
# Therefore the test is NOT applied to these models (reported as not applicable).
hl_test <- function(model, g = 10) {
  y        <- model$y
  fit      <- fitted(model)
  n_unique <- length(unique(round(fit, 10)))
  n_coef   <- length(coef(model))

  if (n_unique <= n_coef) {
    # Number of distinct probabilities = number of parameters -> saturated model
    return(tibble(n_distinct_prob = n_unique, groups_used = NA_integer_,
                  HL_chisq = NA_real_, HL_df = NA_real_, HL_p = NA_real_,
                  HL_note = sprintf(paste0("Not applicable: only %d distinct predicted probabilities ",
                                           "(categorical predictor only, saturated model); %d groups ",
                                           "cannot be formed and observed = expected by construction"),
                                    n_unique, g)))
  }

  # Run the test and catch the warning issued when fewer than g groups can be formed
  warn_msg <- NULL
  res <- withCallingHandlers(hoslem.test(y, fit, g = g),
                             warning = function(w) { warn_msg <<- conditionMessage(w)
                                                     invokeRestart("muffleWarning") })
  groups_used <- unname(res$parameter) + 2          # df = groups - 2
  note <- if (is.null(warn_msg)) sprintf("%d groups formed as requested", groups_used) else
    sprintf("Only %d of %d groups could be formed (ties in predicted probabilities); df = %d",
            groups_used, g, unname(res$parameter))

  tibble(n_distinct_prob = n_unique, groups_used = as.integer(groups_used),
         HL_chisq = unname(res$statistic), HL_df = unname(res$parameter),
         HL_p = res$p.value, HL_note = note)
}

# --- Pseudo R2 -----------------------------------------------------------------
pseudo_r2 <- function(model) {
  r <- PseudoR2(model, which = c("McFadden", "CoxSnell", "Nagelkerke"))
  tibble(McFadden = unname(r["McFadden"]), CoxSnell = unname(r["CoxSnell"]),
         Nagelkerke = unname(r["Nagelkerke"]))
}

cat("===== 4.1 GOODNESS OF FIT =====\n")
fit_results <- map_dfr(names(models), function(m) {
  bind_cols(tibble(model = model_names[[m]]), hl_test(models[[m]]), pseudo_r2(models[[m]]))
})
for (i in seq_len(nrow(fit_results))) {
  r <- fit_results[i, ]
  cat("\n", r$model, "\n", sep = "")
  cat("  Distinct predicted probabilities:", r$n_distinct_prob, "\n")
  if (is.na(r$HL_chisq)) {
    cat("  Hosmer-Lemeshow: ", r$HL_note, "\n", sep = "")
  } else {
    cat(sprintf("  Hosmer-Lemeshow: X2 = %.3f, df = %d, p = %s -> %s\n", r$HL_chisq, r$HL_df,
                p_txt(r$HL_p), ifelse(r$HL_p > 0.05, "good fit (H0 not rejected)",
                                      "poor fit (H0 rejected)")))
    cat("  Note:", r$HL_note, "\n")
  }
  cat(sprintf("  McFadden = %.4f | Cox & Snell = %.4f | Nagelkerke = %.4f\n",
              r$McFadden, r$CoxSnell, r$Nagelkerke))
}


# Why only 6 of 10 HL groups for Model 1: accommodates has few distinct values and
# many listings share the same value, so the decile cut points coincide.
cat("\nModel 1 - distribution of accommodates (explains the tied HL groups):\n")
acc_dist <- listings %>% count(accommodates) %>% mutate(percent = round(100 * n / sum(n), 2))
print(as.data.frame(acc_dist), row.names = FALSE)

# Maximum possible value of Cox & Snell R2 for this dependent variable:
# max = 1 - exp(2 * logLik(null model) / n). It is below 1 for a binary Y, which is
# why Nagelkerke divides Cox & Snell by this maximum (rescaling to 0-1).
null_model <- glm(high_price ~ 1, data = listings, family = binomial)
cs_max <- 1 - exp(2 * as.numeric(logLik(null_model)) / nobs(null_model))
cat(sprintf("\nMaximum attainable Cox & Snell R2 for high_price: %.4f\n", cs_max))


# =============================================================================
# 4.2 CLASSIFICATION ACCURACY
# =============================================================================
cat("\n\n===== 4.2 CLASSIFICATION ACCURACY =====\n")

# Distribution of the dependent variable (base rate)
class_dist <- listings %>% count(high_price) %>% mutate(percent = round(100 * n / sum(n), 2))
cat("Distribution of high_price:\n")
print(as.data.frame(class_dist), row.names = FALSE)
base_rate <- max(class_dist$n) / sum(class_dist$n)
cat(sprintf("Base rate (always predicting the larger class '0'): %.2f%%\n", 100 * base_rate))

threshold <- 0.50

classify <- function(model) {
  actual    <- factor(model$y, levels = c(0, 1))
  # predicted class: 1 if predicted probability >= 0.50, otherwise 0
  predicted <- factor(ifelse(fitted(model) >= threshold, 1, 0), levels = c(0, 1))
  cm <- table(Actual = actual, Predicted = predicted)    # rows = actual, columns = predicted
  TN <- cm["0", "0"]; FP <- cm["0", "1"]; FN <- cm["1", "0"]; TP <- cm["1", "1"]
  list(cm = cm, TN = TN, FP = FP, FN = FN, TP = TP,
       accuracy = (TP + TN) / (TP + TN + FP + FN))
}

class_results <- map_dfr(names(models), function(m) {
  cl <- classify(models[[m]])
  cat("\n", model_names[[m]], " - confusion matrix (threshold = 0.50)\n", sep = "")
  # Same layout as in the guideline: rows = actual 0/1, columns = predicted 0/1
  cm_labelled <- matrix(c(sprintf("TN = %d", cl$TN), sprintf("FP = %d", cl$FP),
                          sprintf("FN = %d", cl$FN), sprintf("TP = %d", cl$TP)),
                        nrow = 2, byrow = TRUE,
                        dimnames = list(c("Actual: 0", "Actual: 1"),
                                        c("Predicted: 0", "Predicted: 1")))
  print(noquote(cm_labelled))
  cat(sprintf("Accuracy = (TP + TN) / total = (%d + %d) / %d = %.4f (%.2f%%) | vs base rate %.2f%%: %+.2f points\n",
              cl$TP, cl$TN, sum(cl$cm), cl$accuracy, 100 * cl$accuracy, 100 * base_rate,
              100 * (cl$accuracy - base_rate)))
  tibble(model = model_names[[m]], TN = cl$TN, FP = cl$FP, FN = cl$FN, TP = cl$TP,
         accuracy = cl$accuracy)
})


# =============================================================================
# SUMMARY TABLE
# =============================================================================
summary_table <- fit_results %>%
  select(model, HL_chisq, HL_df, HL_p, HL_note, McFadden, CoxSnell, Nagelkerke) %>%
  left_join(class_results, by = "model") %>%
  mutate(across(c(HL_chisq, McFadden, CoxSnell, Nagelkerke, accuracy), ~ round(.x, 4)),
         HL_p_report = p_txt(HL_p))

cat("\n\n===== SUMMARY TABLE =====\n")
print(as.data.frame(select(summary_table, -HL_note)), row.names = FALSE)
write_csv(summary_table, "output/tables/06_logistic_summary.csv")
cat("Saved: output/tables/06_logistic_summary.csv\n")


# =============================================================================
# 4.3 LOGISTIC REGRESSION PROBABILITY GRAPHS
# =============================================================================
cat("\n===== 4.3 PROBABILITY GRAPHS =====\n")
theme_set(theme_minimal(base_size = 12))

# --- Model 1: logistic curve over accommodates ------------------------------
grid1 <- tibble(accommodates = seq(1, 16, by = 0.1))
grid1$prob <- predict(models$model1, newdata = grid1, type = "response")
pts1 <- tibble(accommodates = c(2, 4, 6))
pts1$prob <- predict(models$model1, newdata = pts1, type = "response")

g1 <- ggplot(grid1, aes(accommodates, prob)) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey50") +
  geom_line(linewidth = 1.1, colour = "#2C7FB8") +
  geom_point(data = pts1, size = 3, colour = "#2C7FB8") +
  geom_text(data = pts1, aes(label = sprintf("%.3f", prob)), vjust = -1, size = 3.8) +
  scale_x_continuous(breaks = 1:16) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
  labs(title = "Model 1: Predicted probability of high price by guest capacity",
       subtitle = "logit(p) = -2.3503 + 0.6782 x accommodates; dashed line = 0.50 threshold",
       x = "accommodates (number of guests)", y = "Predicted probability of high price")
ggsave("output/figures/06_model1_probability_curve.png", g1, width = 8, height = 5, dpi = 300)

# --- Model 2: predicted probability per superhost category -------------------
grid2 <- tibble(host_is_superhost = factor(c("No", "Yes"), levels = c("No", "Yes")))
grid2$prob <- predict(models$model2, newdata = grid2, type = "response")

g2 <- ggplot(grid2, aes(host_is_superhost, prob, group = 1)) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey50") +
  geom_line(colour = "grey60") +
  geom_point(size = 4, colour = "#2C7FB8") +
  geom_text(aes(label = sprintf("%.3f", prob)), vjust = -1.2, size = 4) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
  labs(title = "Model 2: Predicted probability of high price by Superhost status",
       subtitle = "Reference category: No (not a superhost); dashed line = 0.50 threshold",
       x = "host_is_superhost", y = "Predicted probability of high price")
ggsave("output/figures/06_model2_probability.png", g2, width = 7, height = 5, dpi = 300)

# --- Model 3: predicted probability per room type ----------------------------
grid3 <- tibble(room_type = factor(levels(listings$room_type), levels = levels(listings$room_type)))
grid3$prob <- predict(models$model3, newdata = grid3, type = "response")

g3 <- ggplot(grid3, aes(room_type, prob)) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey50") +
  geom_point(size = 4, colour = "#2C7FB8") +
  geom_text(aes(label = sprintf("%.3f", prob)), vjust = -1.2, size = 4) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
  labs(title = "Model 3: Predicted probability of high price by room type",
       subtitle = "Reference category: Entire home/apt; dashed line = 0.50 threshold",
       x = "room_type", y = "Predicted probability of high price")
ggsave("output/figures/06_model3_probability.png", g3, width = 8, height = 5, dpi = 300)

# --- Model 4: curves over accommodates, one per room type --------------------
# Other numerical variables fixed at their MEDIAN, other categorical variables
# fixed at their REFERENCE category.
fixed <- list(bedrooms          = median(listings$bedrooms),
              bathrooms         = median(listings$bathrooms),
              number_of_reviews = median(listings$number_of_reviews),
              availability_365  = median(listings$availability_365))
cat("Model 4 graph - fixed values:",
    paste(names(fixed), unlist(fixed), sep = " = ", collapse = ", "),
    ", host_is_superhost = No, shared_bath = No\n")

grid4 <- expand_grid(accommodates = seq(1, 16, by = 0.1),
                     room_type = factor(levels(listings$room_type), levels = levels(listings$room_type))) %>%
  mutate(bedrooms = fixed$bedrooms, bathrooms = fixed$bathrooms,
         number_of_reviews = fixed$number_of_reviews, availability_365 = fixed$availability_365,
         host_is_superhost = factor("No", levels = c("No", "Yes")),
         shared_bath       = factor("No", levels = c("No", "Yes")))
grid4$prob <- predict(models$model4, newdata = grid4, type = "response")

g4 <- ggplot(grid4, aes(accommodates, prob, colour = room_type)) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey50") +
  geom_line(linewidth = 1.1) +
  scale_x_continuous(breaks = 1:16) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
  scale_colour_manual(values = c("#2C7FB8", "#D95F0E", "#1B9E77", "#7570B3")) +
  labs(title = "Model 4: Predicted probability of high price by guest capacity and room type",
       subtitle = sprintf(paste0("Other variables fixed: bedrooms = %g, bathrooms = %g, number_of_reviews = %g,\n",
                                 "availability_365 = %g (medians); host_is_superhost = No, shared_bath = No (reference)"),
                          fixed$bedrooms, fixed$bathrooms, fixed$number_of_reviews, fixed$availability_365),
       x = "accommodates (number of guests)", y = "Predicted probability of high price",
       colour = "room_type") +
  theme(legend.position = "bottom", plot.subtitle = element_text(size = 9))
ggsave("output/figures/06_model4_probability_curves.png", g4, width = 9, height = 6, dpi = 300)

# Values at selected capacities, used in the interpretation notes
cat("\nModel 4 - predicted probabilities at selected capacities:\n")
print(as.data.frame(grid4 %>% filter(accommodates %in% c(2, 4, 6)) %>%
                      select(accommodates, room_type, prob) %>%
                      pivot_wider(names_from = room_type, values_from = prob)),
      row.names = FALSE, digits = 3)

cat("\nSaved figures: output/figures/06_model1_probability_curve.png, 06_model2_probability.png,",
    "06_model3_probability.png, 06_model4_probability_curves.png\n")
