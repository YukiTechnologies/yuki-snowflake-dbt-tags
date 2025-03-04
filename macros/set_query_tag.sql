{% macro set_query_tag(extra = {}) -%}
    {{ return(adapter.dispatch('set_query_tag', 'yuki_snowflake_dbt_tags')(extra=extra)) }}
{%- endmacro %}

{% macro default__set_query_tag(extra = {}) -%}
    {% set original_query_tag = get_current_query_tag() %}

    {% set query_tag = {
        "dbt_job": env_var('DBT_JOB_NAME'),
        "dbt_model": model.name,
        "dbt_enabled": env_var('DBT_YUKI_ENABLED', true),
        "invocation_id": invocation_id,
        "run_cmd": flags.WHICH,
        "resource_type": model.resource_type,
    } %}

    {% if model.resource_type == 'model' %}
        {%- do query_tag.update(
            full_refresh=not is_incremental()
        ) -%}
    {% endif %}

    {% set query_tag_json = tojson(query_tag) %}
    {{ log("Setting query_tag to '" ~ query_tag_json ~ "'. Will reset to '" ~ original_query_tag ~ "' after materialization.") }}
    {% do run_query("alter session set query_tag = '{}'".format(query_tag_json)) %}
    {{ return(original_query_tag)}}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
    {{ return(adapter.dispatch('unset_query_tag', 'yuki_snowflake_dbt_tags')(original_query_tag)) }}
{%- endmacro %}

{% macro default__unset_query_tag(original_query_tag) -%}
    {% if original_query_tag %}
        {{ log("Resetting query_tag to '" ~ original_query_tag ~ "'.") }}
        {% do run_query("alter session set query_tag = '{}'".format(original_query_tag)) %}
    {% else %}
        {{ log("No original query_tag, unsetting parameter.") }}
        {% do run_query("alter session unset query_tag") %}
    {% endif %}
{% endmacro %}
