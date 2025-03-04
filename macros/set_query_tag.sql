{% macro set_query_tag() %}
    {% set query_tag = {
        "dbt_job": env_var('DBT_JOB_NAME'),
        "dbt_model": model.name,
        "dbt_enabled": env_var('DBT_YUKI_ENABLED', true),
        "full_refresh": flags.FULL_REFRESH,
        "invocation_id": invocation_id,
        "run_cmd": flags.WHICH
    } | tojson %}
ALTER SESSION SET QUERY_TAG = '{{ query_tag }}';
{% endmacro %}
