{% macro set_query_tag() %}
    {% set model_name = this.name %}
    {% set job_name = env_var('DBT_JOB_NAME', 'default_job') %}  -- Retrieve from environment variable, or use 'default_job'

    -- Create JSON formatted query tag
    {% set query_tag = '{"dbt_job":"' ~ job_name ~ '", "dbt_model":"' ~ model_name ~ '"}' %}

    -- Set the query tag in Snowflake
    ALTER SESSION SET QUERY_TAG = '{{ query_tag }}';
{% endmacro %}