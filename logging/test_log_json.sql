SET SERVEROUTPUT ON
DECLARE
    l_ctx1    JSON;
    l_ctx2    JSON;
    l_ctx     JSON;
    l_payload JSON;
    l_rc      SYS_REFCURSOR;
    l_row     otk_error_log_json%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put_line('=== TEST: otk$log_json (JSON-native engine, stateless) ===');

    ----------------------------------------------------------------------
    -- Build context objects
    ----------------------------------------------------------------------
    l_ctx1 := otk$log_json.ctx('module', 'test_log_json');
    l_ctx2 := otk$log_json.ctx('phase', 'startup');
    l_ctx  := otk$log_json.ctx_merge(l_ctx1, l_ctx2);

    ----------------------------------------------------------------------
    -- Build JSON payload
    ----------------------------------------------------------------------
    l_payload := JSON_OBJECT('payload' VALUE 'test', 'value' VALUE 999);

    ----------------------------------------------------------------------
    -- INFO
    ----------------------------------------------------------------------
    otk$log_json.info(
        message => 'Starting JSON-native stateless logging test',
        context => l_ctx,
        payload => l_payload
    );

    ----------------------------------------------------------------------
    -- DEBUG
    ----------------------------------------------------------------------
    otk$log_json.debug(
        message => 'Debug message for JSON logger',
        context => otk$log_json.ctx('debug_flag','true')
    );

    ----------------------------------------------------------------------
    -- WARN
    ----------------------------------------------------------------------
    otk$log_json.warn(
        message => 'This is a JSON warning',
        context => otk$log_json.ctx('severity','medium')
    );

    ----------------------------------------------------------------------
    -- ERROR
    ----------------------------------------------------------------------
    BEGIN
        DECLARE x NUMBER;
        BEGIN
            SELECT 1 / 0 INTO x FROM dual;
        EXCEPTION
            WHEN OTHERS THEN
                otk$log_json.error(
                    message => 'JSON logger error test',
                    context => otk$log_json.ctx('operation','division'),
                    payload => JSON_OBJECT('input' VALUE '1/0')
                );
        END;
    END;

    ----------------------------------------------------------------------
    -- get_recent
    ----------------------------------------------------------------------
    DBMS_OUTPUT.put_line('=== get_recent(5) ===');
    l_rc := otk$log_json.get_recent(5);
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
    DBMS_OUTPUT.put_line('=== search("JSON") ===');
    l_rc := otk$log_json.search('JSON');
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
    DBMS_OUTPUT.put_line('=== purge(0.0001) ===');
    otk$log_json.purge(0.0001);

    DBMS_OUTPUT.put_line('=== TEST COMPLETE ===');
END;
/
