# 🐧 yuki-snowflake-dbt-tags

This package automatically tags each query executed on Snowflake with a JSON-formatted identifier containing the associated model name and job name. This enhances traceability, enabling you to track query history, optimize performance, and monitor job runs directly from Snowflake's `QUERY_HISTORY` table.
## 🚀 Features

- Automatically tags each query with a unique identifier in JSON format.
- Includes the **dbt model name**, **dbt invocation_id** and the customizable **job name** in each tag.
- Simplifies query performance monitoring and debugging.
- Fully configurable, making it easy to integrate with your existing dbt workflow.

## 🌐 Installation

To install this package, add the following entry to your `packages.yml` file in your dbt project:

```yaml
packages:
  - package: YukiTechnologies/yuki_snowflake_dbt_tags
    version: 0.3.1
```

## 🔧 Configuration

To enable automatic query tagging, configure the dispatch search order in `dbt_project.yml`:

```yaml
dispatch:
  - macro_namespace: dbt
    search_order:
      - <YOUR_PROJECT_NAME>
      - yuki_snowflake_dbt_tags
      - dbt
```

**Specifying a Job Name**

The package resolves the job name using the following fallback chain:

1. `DBT_JOB_NAME` environment variable (recommended - human-readable)
2. `DBT_CLOUD_JOB_ID` environment variable (automatic in dbt Cloud)
3. `UNNAMED_JOB` (default if neither is set)

**Setting `DBT_JOB_NAME` in dbt Cloud:**

1.	Navigate to: Orchestration -> Environments -> Environment Variables.
2.	Click Add variable.
3.	Fill in the following details:

&nbsp;&nbsp;- Key: `DBT_JOB_NAME`
&nbsp;&nbsp;- Project default: default_job

4.	Click Save.

Next, configure the job-specific override:
1.	Go to: Orchestration -> Jobs and select the relevant job.
2.	Navigate to Settings -> Advanced Settings -> Environment Variables.
3.	Locate `DBT_JOB_NAME` and define a Job override  - this should be the job name. This job name will be reflected in the Yuki UI.

This custom job name will appear in your query tags, making it easier to identify and track specific jobs in the Snowflake query history.

## 🌟 Enforce Original Warehouse Size

If you have a use case where you want the job to run on the original warehouse size connected to dbt, you can disable Yuki for a specific run. To do this add an environment variable (similar to the steps for DBT_JOB_NAME) with the following details:

&nbsp;&nbsp;- Key: `DBT_YUKI_ENABLED`
&nbsp;&nbsp;- Value: `False`

This configuration ensures that the job uses the original warehouse size while bypassing Yuki optimizations.


## 🛠 Usage

1.	Run dbt Models: Execute your dbt models with dbt run. You can also specify a custom job_name if desired (as shown above).
2.	View Tags in Snowflake: Log into Snowflake and navigate to the QUERY_HISTORY table to see the tags applied to each query. The tags are stored in the QUERY_TAG column in JSON format, for example:

```json
{
  "dbt_job": "your_job_name",
  "dbt_model": "your_model_name",
  "dbt_target": "prod",
  "invocation_id": "c5faa810-9e05-44d9-b00e-6a1bfbc82431",
  "run_cmd": "build",
  "resource_type": "model",
  "dbt_cloud_project_id": "12345",
  "dbt_cloud_environment_name": "Production",
  "full_refresh": false,
  "materialization": "incremental"
}
```

**dbt Cloud project and environment tags**

When running in dbt Cloud, queries are additionally tagged with `dbt_cloud_project_id` and `dbt_cloud_environment_name`, sourced from the `DBT_CLOUD_PROJECT_ID` and `DBT_CLOUD_ENVIRONMENT_NAME` [special environment variables](https://docs.getdbt.com/docs/build/environment-variables#special-environment-variables) that dbt Cloud sets automatically. This lets you filter or break down cost and usage by dbt Cloud project and environment. The tags are omitted when the variables are not set (e.g. dbt Core), so non-Cloud users are unaffected; dbt Core users can opt in by setting these environment variables themselves.

This makes it easy to filter and analyze queries by job or model name in Snowflake’s history.

## ➕ Custom Query Tag Extensions

Use the `extra` kwarg on `set_query_tag` to add your own key/value pairs while keeping the  tags from this package.

```jinja
{% macro set_query_tag() -%}
  {{ return(yuki_snowflake_dbt_tags.set_query_tag(
    extra={
      'custom_config_property': config.get('custom_config_property'),
    }
  )) }}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
  {{ return(yuki_snowflake_dbt_tags.unset_query_tag(original_query_tag)) }}
{% endmacro %}
```

Calling the package macros keeps the built-in metadata and simply adds your custom fields.

## 🔗 Composing With Another Query-Tagging Package

dbt invokes a single `set_query_tag` hook per node, so installing this package alongside **another package that also overrides `set_query_tag`** isn't enough; only one can win.

Use **`build_query_tag`** to combine both with a single `ALTER SESSION`. It builds this package's merged tag **without** touching the session, returning a mapping with two keys: `query_tag` (the merged tag dict) and `original_query_tag` (the value to restore).

In your dbt project, create `macros/set_query_tag.sql` and add the macros below. dbt resolves project-level macros ahead of any package, so this override becomes the single `set_query_tag`/`unset_query_tag` hook dbt invokes. It lets this package build the tag, then hands the result to the other package as its `extra` so the other package performs the one and only `ALTER SESSION`:

```jinja
{% macro set_query_tag(extra = {}) -%}
  {# This package builds the tag without altering the session, and the other package performs the single ALTER SESSION. #}
  {% set built = yuki_snowflake_dbt_tags.build_query_tag(extra=extra) %}
  {% do your_other_query_tagging_package.set_query_tag(extra=built["query_tag"]) %}
  {{ return(built["original_query_tag"]) }}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
  {{ return(yuki_snowflake_dbt_tags.unset_query_tag(original_query_tag)) }}
{% endmacro %}
```

This keeps this package's tags and restore behavior authoritative while merging in the other package's fields, all in a single session update.

## 📄 License
This package is open-source under the MIT License. See the LICENSE file for details.

## 💬 Support
If you have any questions or need help, feel free to open an issue or contact us directly. We’re here to help make Snowflake query management a breeze! 🐧✨
www.yukidata.com
