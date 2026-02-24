{% macro generate_schema_name(custom_schema_name, node) -%}
  {# 
    Force schema by folder in the project:

    - models/staging/...      -> POC_ANALYTICS.STAGING
    - models/intermediate/... -> POC_ANALYTICS.INTERMEDIATE
    - models/marts/...        -> POC_ANALYTICS.MART

    Fallback: target.schema
  #}

  {% set fqn = node.fqn %}

  {% if 'staging' in fqn %}
    STAGING
  {% elif 'intermediate' in fqn %}
    INTERMEDIATE
  {% elif 'marts' in fqn %}
    MART
  {% else %}
    {{ target.schema }}
  {% endif %}
{%- endmacro %}
