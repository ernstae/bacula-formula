{% from "bacula/map.jinja" import bacula with context -%}

bacula-sd:
  pkg.installed:
    - pkgs: {{ (bacula.get('lookup').get('common_pkgs', []) + bacula.get('lookup').get('storage_pkgs', []))|json }}
  service.running:
    - enable: True

{% for key, data in bacula.get('storage').get('config', {}).items() %}
{% set path = 'bacula-sd-' + key|lower if key not in ['Storage'] else 'bacula-sd' %}
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
      {%- if key == 'Storage' %}
      includes:
        {%- for include in bacula.get('storage').get('config', {}).keys() %}
          {%- if include != 'Storage' %}
        - bacula-sd-{{ include }}
          {%- endif %}
        {%- endfor -%}
      {%- endif %}
    - watch_in:
      - service: bacula-sd
    - require_in:
      - service: bacula-sd
{% endfor %}

{% for device in bacula.get('storage').get('config').get('Device', []) %}
  {% if device.get('Archive Device', False) %}
bacula-sd-device-{{ device.get('Archive Device')|replace('/', '_') }}-dir:
  file.directory:
    - name: {{ device.get('Archive Device') }}
    - mode: 770
    - user: bacula
    - group: bacula
    - recurse:
      - mode
      - user
    - require_in:
      - service: bacula-sd
  {% endif %}
{% endfor %}
