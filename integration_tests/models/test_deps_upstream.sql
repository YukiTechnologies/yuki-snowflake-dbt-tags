{{ config(materialized='table') }}

select 1 as id, 'upstream' as source_label
