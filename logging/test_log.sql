SET SERVEROUTPUT ON
DECLARE
    l_ctx1   CLOB;
    l_ctx2   CLOB;
    l_ctx    CLOB;
    l_payload CLOB;
    l_rc     SYS_REFCURSOR;
    l_row    otk_error_log%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put_line('=== TEST: otk$log (CLOB engine, stateless) ===');

    ----------------------------------------------------------------------
    -- Build context objects
    ----------------------------------------------------------------------
    l_ctx1 := otk$log.ctx('module', 'test_log');
    l_ctx2 := otk$log.ctx('phase', 'initialization');
    l_ctx  := otk$log.ctx_merge(l_ctx1, l_ctx2);

    ----------------------------------------------------------------------
    -- Build a JSON payload (CLOB)
    ----------------------------------------------------------------------
    l_payload := '{"payload":"test","value":123}';

    ----------------------------------------------------------------------
    -- INFO
    ----------------------------------------------------------------------
    otk$log.info(
        message => 'Starting stateless logging test',
        context => l_ctx,
        payload => l_payload
    );

    ----------------------------------------------------------------------
    -- DEBUG
    ----------------------------------------------------------------------
    otk$log.debug(
        message => 'Debug message: x=42',
        context => otk$log.ctx('debug_flag','true')
    );

    ----------------------------------------------------------------------
    -- WARN
    ----------------------------------------------------------------------
    otk$log.warn(
        message => 'This is a warning',
        context => otk$log.ctx('severity','medium')
    );

    ----------------------------------------------------------------------
    -- ERROR (with SQLERRM, stack, backtrace)
    ----------------------------------------------------------------------
    BEGIN
        DECLARE x NUMBER;
        BEGIN
            SELECT 1 / 0 INTO x FROM dual;
        EXCEPTION
            WHEN OTHERS THEN
                otk$log.error(
                    message => 'Division by zero occurred',
                    context => otk$log.ctx('operation','division'),
                    payload => '{"input":"1/0"}'
                );
        END;
    END;

    ----------------------------------------------------------------------
    -- get_recent
    ----------------------------------------------------------------------
    DBMS_OUTPUT.put_line('=== get_recent(5) ===');
    l_rc := otk$log.get_recent(5);
    LOOP
        FETCH l_rc INTO l_row;
        EXIT WHEN l_rc%NOTFOUND;
        DBMS_OUTPUT.put_line(
            l_row.log_id || ' | ' ||
            l_row.log_level || ' | ' ||
            l_row.message
        );
    END LOOP;
    CLOSE l_rc;

    ----------------------------------------------------------------------
    -- search
    ----------------------------------------------------------------------
    DBMS_OUTPUT.put_line('=== search("warning") ===');
    l_rc := otk$log.search('warning');
    LOOP
        FETCH l_rc INTO l_row;
        EXIT WHEN l_rc%NOTFOUND;
        DBMS_OUTPUT.put_line(
            l_row.log_id || ' | ' ||
            l_row.log_level || ' | ' ||
            l_row.message
        );
    END LOOP;
    CLOSE l_rc;

    ----------------------------------------------------------------------
    -- purge
    ----------------------------------------------------------------------
    DBMS_OUTPUT.put_line('=== purge(0.0001) (purge older than ~8 seconds) ===');
    otk$log.purge(0.0001);

    DBMS_OUTPUT.put_line('=== TEST COMPLETE ===');
END;
/
