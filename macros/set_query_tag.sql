{% macro set_query_tag() %}
{% set model = this.name %}
    {% set enabled = env_var('DBT_YUKI_ENABLED', 'True') %}
    {% set job = env_var('DBT_JOB_NAME') %}
    {% set started = run_started_at.strftime('%Y-%m-%dT%H:%M:%S') %}
    {% set query_tag = '{"dbt_job":"' ~ job ~ '", "dbt_model":"' ~ model ~ '", "job_started_at":"' ~ started ~ '", "dbt_enabled":"' ~ enabled ~ '"}' %}
ALTER SESSION SET QUERY_TAG = '{{ query_tag }}';
{% endmacro %}