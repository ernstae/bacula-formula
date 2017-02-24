{% from "bacula/map.jinja" import bacula with context -%}

bacula-director:
  pkg.installed:
    - pkgs: {{ (bacula.get('lookup').get('common_pkgs', []) + bacula.get('lookup').get('director_pkgs', []))|json }}
  service.running:
    - enable: True

{% for key, data in bacula.get('director').get('config', {}).items() %}
{% set path = 'bacula-dir-' + key|lower if key not in ['Director'] else 'bacula-dir' %}
{{ path }}-config:
  file.managed:
    - name: /etc/bacula/{{ path }}.conf
    - source: salt://bacula/files/bacula-tmpl.conf
    - template: jinja
    - user: root
    - group: root
    - defaults:
      key: {{ key }}
      data: {{ data }}
      {%- if key == 'Director' %}
      includes:
        {%- for include in bacula.get('director').get('config', {}).keys() %}
          {%- if include != 'Director' %}
        - bacula-dir-{{ include }}
          {%- endif %}
        {%- endfor -%}
      {%- endif %}
    - watch_in:
      - service: bacula-director
    - require_in:
      - service: bacula-director
{% endfor %}
