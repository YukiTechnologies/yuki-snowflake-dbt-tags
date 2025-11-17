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
    version: 0.2.5
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

**Specifying a Custom Job Name**

1.	Navigate to: Deploy -> Environments -> Environments Variables.
2.	Click Add variable.
3.	Fill in the following details:

&nbsp;&nbsp;- Key: `DBT_JOB_NAME`
&nbsp;&nbsp;- Project default: default_job

4.	Click Save.

Next, configure the job-specific override:
1.	Go to: Deploy -> Jobs and select the relevant job.
2.	Navigate to Settings -> Advanced Settings -> Environment Variables.
3.	Locate `DBT_JOB_NAME` and define a Job override  - this should be the job name.	This job name will be reflected in the Yuki UI.

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
  "full_refresh": false,
  "materialization": "incremental",
}
```

This makes it easy to filter and analyze queries by job or model name in Snowflake’s history.

## ➕ Custom Query Tag Extensions

Use the `extra` kwarg on `set_query_tag` to add your own key/value pairs while keeping the  tags from this package.

```jinja
{% macro set_query_tag() -%}
  {% do return(dbt_snowflake_query_tags.set_query_tag(
    extra={
      'custom_config_property': config.get('custom_config_property'),
    }
  )) %}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
  {% do return(dbt_snowflake_query_tags.unset_query_tag(original_query_tag)) %}
{% endmacro %}
```

Calling the package macros keeps the built-in metadata and simply adds your custom fields.

## 📄 License
This package is open-source under the MIT License. See the LICENSE file for details.

## 💬 Support
If you have any questions or need help, feel free to open an issue or contact us directly. We’re here to help make Snowflake query management a breeze! 🐧✨
www.yukidata.com
