-- Snapshot to verify query tagging on snapshot resources
{% snapshot test_snapshot %}
{{
    config(
      unique_key='id',
      strategy='check',
      check_cols='all',
    )
}}
select * from {{ ref('test_seed') }}
{% endsnapshot %}
