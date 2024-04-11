WITH inData AS (SELECT '1000 11 100' AS code_operation, '93275 234218' AS id_client
    FROM dual
    UNION ALL
    SELECT '2000' AS code_operation, '93275 2342 18' AS id_client
    FROM dual
),
temp1 AS (SELECT ROWNUM nm, code_operation, id_client
    FROM inData
),
ic AS (SELECT DISTINCT REGEXP_SUBSTR(id_client, '\d+', 1, LEVEL) AS icstr, LEVEL AS lvic, nm
    FROM (SELECT code_operation, id_client, REGEXP_COUNT(id_client, ' ') + 1 AS rc, nm
        FROM temp1)
    CONNECT BY LEVEL <= rc
),
co AS (SELECT DISTINCT REGEXP_SUBSTR(code_operation, '\d+', 1, LEVEL) AS costr, LEVEL AS lvco, nm
    FROM (SELECT code_operation, id_client, REGEXP_COUNT(code_operation, ' ') + 1 AS rn, nm
        FROM temp1)
    CONNECT BY LEVEL <= rn   
),
temp2 AS (SELECT nm, 0 AS nm2, 0 AS lv, 0 AS lv2, code_operation, id_client
    FROM temp1
    UNION ALL
    SELECT ic.nm, co.nm, ic.lvic, co.lvco, co.costr, ic.icstr
    FROM ic
    FULL JOIN co
    ON ic.nm = co.nm
        AND ic.lvic = co.lvco
),
outData AS (SELECT nmm, lvv, code_operation, id_client
    FROM temp2
    MODEL
    DIMENSION BY(nm, nm2, lv, lv2)
    MEASURES(nm AS nmm, lv AS lvv, code_operation, id_client)
    RULES (
        nmm[null,any,any,any]=cv(nm2),
        lvv[any,any,null,any]=cv(lv2),
        code_operation[any,any,any,any]=nvl(code_operation[cv(),cv(),cv(),cv()],' '),
        id_client[any,any,any,any]=nvl(id_client[cv(),cv(),cv(),cv()],' ')
    )
    ORDER BY nmm, lvv
)

SELECT CASE 
    WHEN lvv > 0 THEN ' '
    ELSE TO_CHAR(nmm)
    END AS rn, lvv AS cnt, code_operation, id_client
FROM outData;