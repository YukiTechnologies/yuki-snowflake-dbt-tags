-- Test model to verify the query tagging functionality
{{ config(
    materialized='table',
    meta={'test_type': 'query_tagging'}
) }}

select 1 as test_id
