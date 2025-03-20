/*
 INSTRUCTIONS

 This script is used to reassign ownership of db schema objects from one role to another en masse
 To execute this script properly, run using a postgres role that has superuser access
 Before executing, change `current_owner` to the postgres role that currently owns db schema objects you want to fix
*/

-- Input variables
DO $$
DECLARE
    current_owner TEXT := 'current_owner'; -- Input: Replace with role that currently owns schema objects
    target_owner TEXT := current_database();
    object_row RECORD;
BEGIN
    -- 1. Add role membership for the current user on "current_owner" role
    EXECUTE format('GRANT %I TO CURRENT_USER', current_owner);

    -- 2. Find all database objects with the owner "current_owner"
    FOR object_row IN
        SELECT
            n.nspname AS schema_name,
            c.relname AS object_name,
            c.relkind AS object_type
        FROM
            pg_class c
                JOIN
            pg_namespace n ON n.oid = c.relnamespace
        WHERE
            c.relowner = (SELECT oid FROM pg_roles WHERE rolname = current_owner)
            AND c.relkind in ('r', 'v', 'm', 'S', 'f')
            AND n.nspname = 'public'
    LOOP
        -- 3. Change ownership of each object from "current_owner" to "target_owner"
        EXECUTE format(
            'ALTER %s %I.%I OWNER TO %I',
            CASE object_row.object_type
                WHEN 'r' THEN 'TABLE'    -- Regular table
                WHEN 'v' THEN 'VIEW'     -- View
                WHEN 'm' THEN 'MATERIALIZED VIEW' -- Materialized view
                WHEN 'S' THEN 'SEQUENCE' -- Sequence
                WHEN 'f' THEN 'FOREIGN TABLE' -- Foreign table
                ELSE 'TABLE' -- Default/fallback object type (adjust as needed)
            END,
            object_row.schema_name,
            object_row.object_name,
            target_owner
        );
    END LOOP;

    -- 4. Revoke role membership for the current user on "current_owner" role
    EXECUTE format('REVOKE %I FROM CURRENT_USER', current_owner);

END $$;