-- Example model demonstrating query tagging
-- This model will not be included in the package, it's just for demonstration

{{ config(
    materialized='view'
) }}

select
    1 as example_id,
    'This model demonstrates how query tagging works' as description,
    current_timestamp() as tagged_at
