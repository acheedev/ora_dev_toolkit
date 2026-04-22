CREATE OR REPLACE PACKAGE assert_utils IS

    -- Validate a simple identifier (column, table, index, constraint)
    FUNCTION simple_name(p_name VARCHAR2) RETURN VARCHAR2;

    -- Validate a schema-qualified object name (table, view, index, etc.)
    FUNCTION object_name(p_name VARCHAR2) RETURN VARCHAR2;

    -- Validate a schema name only
    FUNCTION schema_name(p_name VARCHAR2) RETURN VARCHAR2;

    -- Validate a literal value (quotes it safely)
    FUNCTION literal(p_value VARCHAR2) RETURN VARCHAR2;

    -- Quote an identifier (case-sensitive or special chars)
    FUNCTION enquote(p_name VARCHAR2) RETURN VARCHAR2;

END assert_utils;
/
