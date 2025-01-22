{% macro set_query_tag() %}
    {% set query_tag = {
        "dbt_enabled": env_var('DBT_YUKI_ENABLED'),
        "dbt_job": env_var('DBT_JOB_NAME'),
        "dbt_model": this.name,
        "job_started_at": run_started_at.strftime('%Y-%m-%dT%H:%M:%S'),
        "full_refresh": flags.FULL_REFRESH
    } | tojson %}

ALTER SESSION SET QUERY_TAG = '{{ query_tag }}';
{% endmacro %}