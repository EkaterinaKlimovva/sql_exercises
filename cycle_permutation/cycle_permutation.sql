WITH inData AS (SELECT 'acghi' AS str
    FROM dual
    UNION ALL
    SELECT 'acgih' AS str
    FROM dual
    UNION ALL
    SELECT 'sdkfj' AS str
    FROM dual
    UNION ALL
    SELECT 'hacgi' AS str
    FROM dual
    UNION ALL
    SELECT 'cgiha' AS str
    FROM dual
),
temp1 AS (SELECT str, SUBSTR(str, LENGTH(str) - LEVEL + 1, LEVEL) || SUBSTR(str, LEVEL, LENGTH(str) - LEVEL) AS s
    FROM inData
    CONNECT BY LEVEL <= LENGTH(str)
),
temp2 AS (SELECT b.str AS nstr
    FROM temp1 a
    JOIN temp1 b
    ON a.s = b.str
        AND a.str != b.str
)

SELECT DISTINCT str
FROM temp1
WHERE str NOT IN (SELECT nstr FROM temp2);