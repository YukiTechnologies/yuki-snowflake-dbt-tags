{% macro set_query_tag(extra = {}) -%}
  {{ return(adapter.dispatch('set_query_tag', 'yuki_snowflake_dbt_tags')(extra=extra)) }}
{%- endmacro %}

{% macro default__set_query_tag(extra = {}) -%}
  {% set original_query_tag = get_current_query_tag() %}
  {% set original_query_tag_parsed = {} %}
  {% set clean_original_query_tag = {} %}
  {% set clean_original_query_tag_parsed = {} %}

  {% if original_query_tag %}
    {% set clean_original_query_tag = modules.re.sub('^(\\{[^}]*"PseudoWarehouse"[^}]*\\})(;;(.*))?$', '\\3', original_query_tag) or '{}' %}
  {% endif %}

  {% if clean_original_query_tag %}
    {% if fromjson(clean_original_query_tag) is mapping %}
      {% set clean_original_query_tag_parsed = fromjson(clean_original_query_tag) %}
    {% endif %}
  {% endif %}

  {# Get model level query tags #}
  {% set query_tag = config.get('query_tag', default={}) %}

  {% if query_tag is not mapping %}
  {% do log("dbt-snowflake-query-tags warning: the query_tag config value of '{}' is not a mapping type, so is being ignored. If you'd like to add additional query tag information, use a mapping type instead, or remove it to avoid this message.".format(query_tag), True) %}
  {% set query_tag = {} %} {# If the user has set the query tag config as a non mapping type, start fresh #}
  {% endif %}

  {# Add user session level and extra query tags #}
  {% do query_tag.update(clean_original_query_tag_parsed) %}
  {% do query_tag.update(extra) %}

  {# Add Yuki query tags #}
  {% do query_tag.update({
    "dbt_job": env_var('DBT_JOB_NAME'),
    "dbt_model": model.name,
    "dbt_enabled": env_var("DBT_YUKI_ENABLED", "true") | lower == "true",
    "dbt_target": target.name,
    "invocation_id": invocation_id,
    "run_cmd": flags.WHICH,
    "resource_type": model.resource_type,
  }) %}

  {# Set full_refresh and materialization query tag for models only (not tests, seeds, etc.) #}
  {% if model.resource_type == 'model' %}
    {%- do query_tag.update(
      full_refresh=not is_incremental(),
      materialization=model.config.materialized
    ) -%}
  {% endif %}

  {% set query_tag_json = tojson(query_tag) %}
  {{ log("Setting query_tag to '" ~ query_tag_json ~ "'. Will reset to '" ~ clean_original_query_tag ~ "' after materialization.") }}
  {% do run_query("alter session set query_tag = '{}'".format(query_tag_json)) %}
  {{ return(clean_original_query_tag)}}
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
