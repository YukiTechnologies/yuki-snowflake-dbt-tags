-- Test incremental model to verify full_refresh tagging
{{ config(
    materialized='incremental',
    unique_key='id'
) }}

select
    2 as id,
    'incremental_test' as test_column,
    current_timestamp() as created_at

{% if is_incremental() %}
    where created_at > (select max(created_at) from {{ this }})
{% endif %}
