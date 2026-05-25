{{ config(materialized='table') }}

select * from {{ ref('test_deps_upstream') }}
