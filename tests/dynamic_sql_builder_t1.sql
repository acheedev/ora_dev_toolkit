DECLARE
    l_sql   VARCHAR2(4000);
    l_binds SYS.ODCIVARCHAR2LIST;
BEGIN
    otk$dynamic_sql_builder.new_query
        .select_cols( SYS.ODCIVARCHAR2LIST('EMPLOYEE_ID', 'LAST_NAME') )
        .from_table('HR.EMPLOYEES')
        .where_clause('DEPARTMENT_ID = :b1', ANYDATA.ConvertNumber(50))
        .order_by('LAST_NAME')
        .fetch_first(10)
        .build(l_sql, l_binds);

    DBMS_OUTPUT.put_line('SQL: ' || l_sql);

    FOR i IN 1 .. l_binds.COUNT LOOP
        DBMS_OUTPUT.put_line('Bind ' || i || ': ' || l_binds(i));
    END LOOP;
END;
/
