# 🐧 yuki-snowflake-dbt-tags

**yuki-snowflake-dbt-tags** is a dbt package that automatically tags each query executed on Snowflake with a JSON-formatted identifier containing the associated model name and job name. This enhances traceability, enabling you to track query history, optimize performance, and monitor job runs directly from Snowflake's `QUERY_HISTORY` table.

## 🚀 Features

- Automatically tags each query with a unique identifier in JSON format.
- Includes the **dbt model name** and customizable **job name** in each tag.
- Simplifies query performance monitoring and debugging.
- Fully configurable, making it easy to integrate with your existing dbt workflow.

## 🌐 Installation

To install this package, add the following entry to your `packages.yml` file in your dbt project:

```yaml
packages:
  - git: "https://github.com/YukiTechnologies/yuki-snowflake-dbt-tags.git"
    revision: main
```

## 🔧 Configuration

To enable automatic query tagging, configure your dbt project to call the set_query_tag macro as a pre-hook for specific models in your dbt_project.yml file. This approach allows you to tag each query executed by those models individually.

```yaml
models:
  <your_model>:
    +pre-hook: "{{ yuki_snowflake_dbt_tags.set_query_tag() }}"
```
Replace <your_model> with the specific model or folder you want to tag.

**Specifying a Custom Job Name**

By default, the job_name is set to "default_job", but you can customize it to reflect the specific job or task being run. To set a custom job_name, pass it as a variable when running dbt.

```bash
dbt run --vars 'job_name: "example-full-job"'
```

This custom job name will appear in your query tags, making it easier to identify and track specific jobs in the Snowflake query history.


## 🛠 Usage

1.	Run dbt Models: Execute your dbt models with dbt run. You can also specify a custom job_name if desired (as shown above).
2.	View Tags in Snowflake: Log into Snowflake and navigate to the QUERY_HISTORY table to see the tags applied to each query. The tags are stored in the QUERY_TAG column in JSON format, for example:

```json
{"dbt_job": "compute-events-full-job", "dbt_model": "your_model_name"}
```

This makes it easy to filter and analyze queries by job or model name in Snowflake’s history.

## 📄 License
This package is open-source under the MIT License. See the LICENSE file for details.

## 💬 Support
If you have any questions or need help, feel free to open an issue or contact us directly. We’re here to help make Snowflake query management a breeze! 🐧✨
www.yukidata.com
