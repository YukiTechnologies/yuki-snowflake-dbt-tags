{% macro set_query_tag() %}
    {% if target.type == 'snowflake' %}
        {% set model_name = this.name %}
        {% set job_name = var('job_name', 'default_job') %}

        -- JSON formatted query tag
        {% set query_tag = '{"dbt_job":"' ~ job_name ~ '", "dbt_model":"' ~ model_name ~ '"}' %}

        -- Set the query tag in Snowflake
        ALTER SESSION SET QUERY_TAG = '{{ query_tag }}';
    {% else %}
        {{ log("set_query_tag is only supported on Snowflake connections.", info=True) }}
    {% endif %}
{% endmacro %}