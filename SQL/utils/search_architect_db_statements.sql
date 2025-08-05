SELECT app.name application_name, 
		adb.name act_database_name, 
		acd.statement act_database_statement
FROM REPOSITORY..t_act_database adb
INNER JOIN REPOSITORY..t_act_database_detail acd
	ON adb.id = acd.id
INNER JOIN ADV..t_application app
	ON adb.application_id = app.application_id
WHERE acd.statement LIKE '%UPDATE%t_whse%'
