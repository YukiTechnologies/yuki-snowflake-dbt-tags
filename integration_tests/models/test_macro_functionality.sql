-- Test that verifies basic macro compilation
{{ config(materialized='view') }}

select 'macro_test' as test_result
