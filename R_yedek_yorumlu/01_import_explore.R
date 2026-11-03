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
