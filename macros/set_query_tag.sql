{% macro set_query_tag() %}
    {% set model_name = this.name %}
    {% set job_name = var('job_name', 'default_job') %}
    {% set job_started_at = run_started_at.strftime('%Y-%m-%dT%H:%M:%S') %}
    {% set query_tag = '{"dbt_job":"' ~ job_name ~ '", "dbt_model":"' ~ model_name ~ '", "job_started_at":"' ~ job_started_at ~ '"}' %}
    ALTER SESSION SET QUERY_TAG = '{{ query_tag }}';
{% endmacro %}
