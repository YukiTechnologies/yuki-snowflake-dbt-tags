{{ config(materialized='table') }}

select table_name
from {{ source('information_schema', 'tables') }}
limit 1
