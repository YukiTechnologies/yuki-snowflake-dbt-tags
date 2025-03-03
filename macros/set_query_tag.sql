{% macro set_query_tag() %}
{% set model = this.name %}
    {% set enabled = env_var('DBT_YUKI_ENABLED', 'True') %}
    {% set job = env_var('DBT_JOB_NAME') %}
    {% set started = run_started_at.strftime('%Y-%m-%dT%H:%M:%S') %}
    {% set query_tag = '{' %}
    {% set query_tag = query_tag ~ '"dbt_job": "' ~ job ~ '",' %}
    {% set query_tag = query_tag ~ '"dbt_model": "' ~ model ~ '",' %}
    {% set query_tag = query_tag ~ '"job_started_at": "' ~ started ~ '",' %}
    {% set query_tag = query_tag ~ '"dbt_enabled": ' ~ enabled | lower ~ ',' %}
    {% set query_tag = query_tag ~ '"full_refresh": ' ~ flags.FULL_REFRESH | lower ~ ',' %}
    {% set query_tag = query_tag ~ '"dbt_invocation_id": "' ~ invocation_id ~ '"' %}
    {% set query_tag = query_tag ~ '}' %}
    {% set query_tag_json = query_tag %}

ALTER SESSION SET QUERY_TAG = '{{ query_tag_json }}';
{% endmacro %}