{% macro generate_schema_name(custom_schema_name, node) -%}
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
