-- Simple test to verify query tagging works
-- Run this manually in Snowflake after installing the package

-- 1. Set environment variables (or defaults will be used)
-- DBT_JOB_NAME: your_test_job
-- DBT_YUKI_ENABLED: true

-- 2. Create a simple model that uses the macro
select
    'test' as test_column,
    current_timestamp() as test_time

-- 3. Check query history
-- SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE QUERY_TAG LIKE '%dbt_model%'
-- ORDER BY START_TIME DESC
-- LIMIT 5;
