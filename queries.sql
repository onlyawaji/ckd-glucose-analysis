-- Table ckd_full_kidney was created by importing the converted CSV ( see README, Method step 1)

-- Removed 1 empty row created during import (401 rows to 400 rows)

DELETE FROM ckd_full_kidney WHERE class IS NULL;

-- Missing values marked `?` in the file were replaced with `NULL` in `bgr` (44 missing values) and `dm` (2 missing values) so that averages ignore them.

UPDATE ckd_full_kidney SET bgr = NULL WHERE bgr = '?';
UPDATE ckd_full_kidney SET dm = NULL WHERE dm = '?';

-- Grouped by `class` and `dm`, then counted patients, counted patients with a glucose value, and averaged glucose.

SELECT class, dm,
    COUNT(*) AS patients,
    COUNT(bgr) AS with_glucose,
    ROUND(AVG(bgr), 1) AS average_random_glucose
FROM ckd_full_kidney
WHERE class IN ('ckd', 'notckd')
AND dm IN ('yes', 'no')
GROUP BY class, dm
ORDER BY average_random_glucose DESC;


