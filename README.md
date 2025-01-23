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

Need to set query comments to null in dbt_project.yml:
```yaml
query-comment: null
```

To enable automatic query tagging, configure your dbt project to call the set_query_tag macro as a pre-hook for specific models in your dbt_project.yml file. This approach allows you to tag each query executed by those models individually.

```yaml
models:
  <your_model>:
    +pre-hook: "{{ yuki_snowflake_dbt_tags.set_query_tag() }}"
```
Replace <your_model> with the specific model or folder you want to tag.

**Specifying a Custom Job Name**

	1.	Navigate to: Deploy -> Environments -> Environments Variables.
	2.	Click Add variable.
	3.	Fill in the following details:
	•	Key: DBT_JOB_NAME
	•	Project default: default_job
	4.	Click Save.

Next, configure the job-specific override:
	1.	Go to: Deploy -> Jobs and select the relevant job.
	2.	Navigate to Settings -> Advanced Settings -> Environment Variables.
	3.	Locate DBT_JOB_NAME and define a Job override (this should be the job name).
	•	This job name will be reflected in the Yuki UI.

This custom job name will appear in your query tags, making it easier to identify and track specific jobs in the Snowflake query history.

## 🌟 Enforce Original Warehouse Size (Optional)

If you have a use case where you want the job to run on the original warehouse size connected to dbt, you can disable Yuki for a specific run. To do this:
	1.	Add an environment variable (similar to the steps for DBT_JOB_NAME) with the following details:
	•	Key: DBT_YUKI_ENABLED
	•	Project default: True (default value)
	2.	If you have a job that needs to run on the original warehouse size, override the value to False at the job level.

This configuration ensures that the job uses the original warehouse size while bypassing Yuki optimizations.


## 🛠 Usage

1.	Run dbt Models: Execute your dbt models with dbt run. You can also specify a custom job_name if desired (as shown above).
2.	View Tags in Snowflake: Log into Snowflake and navigate to the QUERY_HISTORY table to see the tags applied to each query. The tags are stored in the QUERY_TAG column in JSON format, for example:

```json
{"dbt_job": "your_job_name", "dbt_model": "your_model_name", "job_started_at":"2024-11-14T08:47:50", "job_started_at":"2024-11-14T08:47:50"}
```

This makes it easy to filter and analyze queries by job or model name in Snowflake’s history.

## 📄 License
This package is open-source under the MIT License. See the LICENSE file for details.

## 💬 Support
If you have any questions or need help, feel free to open an issue or contact us directly. We’re here to help make Snowflake query management a breeze! 🐧✨
www.yukidata.com
