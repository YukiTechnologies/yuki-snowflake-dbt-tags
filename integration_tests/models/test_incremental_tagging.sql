-- Test incremental model to verify full_refresh tagging
{{ config(
    materialized='incremental',
    unique_key='test_id',
    meta={'test_type': 'incremental_tagging'}
) }}

select 2 as test_id

{% if is_incremental() %}
  where false  -- Ensures incremental logic is triggered
{% endif %}
