{% from "bacula/map.jinja" import bacula with context -%}

bacula-console:
  pkg.installed:
    - pkgs: {{ bacula.get('lookup').get('console_pkgs')|json }}

{% for key, data in bacula.get('console').get('config', {}).items() %}
{% set path = 'bacula-console-' + key|lower if key not in ['Director'] else 'bacula-console' %}
{{ path }}-config:
  file.managed:
    - name: /etc/bacula/{{ path }}.conf
    - source: salt://bacula/files/bacula-tmpl.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - defaults:
      key: {{ key }}
      data: {{ data }}
      {%- if key == 'Director' %}
      includes:
        {%- for include in bacula.get('console').get('config', {}).keys() %}
          {%- if include != 'Director' %}
        - bacula-console-{{ include }}
          {%- endif %}
        {%- endfor -%}
      {%- endif %}
    - watch_in:
      - service: bacula-console
    - require_in:
      - service: bacula-console
  {% endfor %}
