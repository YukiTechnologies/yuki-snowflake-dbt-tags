-- Test model to verify the query tagging functionality
{{ config(materialized='table') }}

select
    1 as id,
    'test_value' as test_column,
    current_timestamp() as created_at
