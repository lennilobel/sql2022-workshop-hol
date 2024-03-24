/* =================== LTRIM/RTRIM =================== */

SELECT '|' +	LTRIM('     #  data  .  ')			+ '|'	-- pre-2022
SELECT '|' +	LTRIM('     #  data  .  ', '#., ')	+ '|'	-- 2022 added 'characters' argument (same as TRIM with LEADING keyword)

SELECT '|' +	RTRIM('     #  data  .  ')			+ '|'	-- pre-2022
SELECT '|' +	RTRIM('     #  data  .  ', '#., ')	+ '|'	-- 2022 added 'characters' argument (same as TRIM with TRAILING keyword)

/* =================== TRIM =================== */

SELECT '|' +	TRIM('     data   ')				+ '|'	-- pre 2017
SELECT '|' +	TRIM(' ' FROM '     data   ')		+ '|'	-- 2017 added 'characters FROM' clause

SELECT '|' +	TRIM('<>'  FROM '<<< data >>>')		+ '|'		
SELECT '|' +	TRIM('<> ' FROM '<<< data >>>')		+ '|'	

-- 2022

SELECT '|' +	TRIM(			'#., '	FROM '     #  data  . ')	+ '|'	-- 2017+
SELECT '|' +	TRIM(BOTH		'#., '	FROM '     #  data  . ')	+ '|'	-- 2022 added BOTH keyword (same as TRIM)
SELECT '|' +	TRIM(LEADING	'#., '	FROM '     #  data  . ')	+ '|'	-- 2022 added LEADING keyword (same as LTRIM with 'characters' argument)
SELECT '|' +	TRIM(TRAILING	'#., '	FROM '     #  data  . ')	+ '|'	-- 2022 added TRAILING keyword (same as RTRIM with 'characters' argument)
