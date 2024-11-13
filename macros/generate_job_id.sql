{% macro generate_job_id() %}
    {% if target.type == 'snowflake' %}
        {% set job_id = run_query("SELECT UUID_STRING() as unique_id").columns[0].values()[0] %}
    {% else %}
        {% set job_id = "unknown_id" %}
    {% endif %}
    {{ return(job_id) }}
{% endmacro %}