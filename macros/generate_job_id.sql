{% macro generate_job_id() %}
    {% if target.type == 'snowflake' %}
        {% set query_result = run_query("SELECT UUID_STRING() as unique_id") %}

        {% if query_result is not none and query_result.columns[0] is not none %}
            {% set job_id = query_result.columns[0].values()[0] %}
            {{ log("Generated Job ID: " ~ job_id, info=True) }}
        {% else %}
            {{ log("Warning: run_query returned None or unexpected format. Using fallback ID.", info=True) }}
            {% set job_id = "fallback_id" %}
        {% endif %}
    {% else %}
        {{ log("Non-Snowflake target detected. Using unknown ID.", info=True) }}
        {% set job_id = "unknown_id" %}
    {% endif %}

    {{ return(job_id) }}
{% endmacro %}