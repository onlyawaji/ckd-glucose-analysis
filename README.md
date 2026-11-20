# Blood glucose, diabetes and chronic kidney disease: an SQL analysis

## Question 
Within patients with chronic kidney disease and patients without chronic kidney disease, is average random blood glucose higher in patients with diabetes mellitus than in patients without diabetes mellitus?

## Data
- Source: 'Chronic Kidney Disease' dataset, UCI Machine Learning Repository (400 patients, 25 columns): https://archive.ics.uci.edu/dataset/336/chronic+kidney+disease

- License: CC BY 4.0

- Citation: Rubini, L., Soundarapandian, P., & Eswaran, P. (2015). Chronic Kidney Disease [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5G020.

- The raw data is not included in this repository. Download it from the link above.

- Columns used: `class` (ckd or notckd), `dm` (diabetes mellitus, yes or no), `bgr` (random blood glucose).

## Method

Tool: DB Browser for SQLite. All queries, in the order they were run, are in `queries.sql`.

1. Converted the `.arff` file into csv (Stripped the multi-line metadata tags at the top of the file and replaced them with a single row of column names) and imported it into SQLite as the table `ckd_full_kidney`.

2. Removed 1 empty row created during import (401 rows to 400 rows)

    ```sql
    DELETE FROM ckd_full_kidney WHERE class IS NULL;
    ```

3. Missing values marked `?` in the file were replaced with `NULL` in `bgr` (44 missing values) and `dm` (2 missing values) so that averages ignore them.

    ```sql
    UPDATE ckd_full_kidney SET bgr = NULL WHERE bgr = '?';
    UPDATE ckd_full_kidney SET dm = NULL WHERE dm = '?';
    ```

4. One record had a malformed line in the source file (an extra empty field shifted its columns, so its `class` read `no`). I did not alter it. The analysis query excludes it.

5. Excluded 3 patients with unknown diabetes status: 2 recorded as `?` and 1 malformed record in the source file (an extra empty field shifted it's columns). **397 patients were analyzed.**

6. Grouped by `class` and `dm`, then counted patients, counted patients with a glucose value, and averaged glucose.

    ```sql
    SELECT class, dm,
        COUNT(*) AS patients,
        COUNT(bgr) AS with_glucose,
        ROUND(AVG(bgr), 1) AS average_random_glucose
    FROM ckd_full_kidney
    WHERE class IN ('ckd', 'notckd')
    AND dm IN ('yes', 'no')
    GROUP BY class, dm
    ORDER BY average_random_glucose DESC;
    ```

## Results

| Class | Diabetes | Patients | With a glucose value | Average random glucose |
|---|---|---|---|---|
| ckd | yes | 137 | 125 | 204.8 |
| ckd | no | 113 | 87 | 133.2 |
| notckd | no | 147 | 141 | 107.9 |
| notckd | yes | 0 | none | none |

No non-CKD patient in this sample has diabetes, so that group has no row in the query output.

## Findings

In this sample of 397 patients, among ckd patients with diabetes, the average random glucose level is 204.8, which is higher than ckd patients without diabetes at 133.2, a difference of about 72. Among notckd patients with diabetes there is no value, as no patient in this category has diabetes. Notckd patients without diabetes have an average random blood glucose level of 107.9.

Among the ckd patients with diabetes, 137 patients were in this category but only 125 had a value for random blood glucose, so the average is that of 125 patients. The category of ckd patients without diabetes had 26 missing values, so its average was based on 87 patients.

## Limitations

- **Uneven missing glucose values:** 26 of 113 (23%) for ckd without diabetes, 12 of 137 (9%) for ckd with diabetes, and 6 of 147 (4%) for notckd without diabetes. If the patients who were not tested were different from those who were tested, it could have affected the averages by being higher or lower especially for the ckd patients without diabetes which had an average of 133.2.

- **No notckd patient has diabetes.** Every diabetic patient in this sample has ckd. So this data cannot separate the effect of CKD from the effect of diabetes on glucose and there can be no diabetes comparison within the non-ckd group (has diabetes and no diabetes).

- Glucose is a random measurement, not a fasting one.

- This is a hospital sample, not the general population, and averages hide the spread of values.

- Two groups can have the same averages but with different ranges

- 1 malformed record was excluded (see Method).

## Files

- `queries.sql`: the SQL queries used in this analysis, with a comment above each one saying what it does.

- `README.md`: this file, describing the question, data, method, results and limitations.