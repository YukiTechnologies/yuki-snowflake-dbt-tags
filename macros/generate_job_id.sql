{% macro generate_job_id() %}
    {% set job_id = uuid() %}
    {{ log("Generated Job ID: " ~ job_id, info=True) }}
    {{ return(job_id) }}
{% endmacro %}