{% from "bacula/map.jinja" import bacula with context -%}

bacula-fd:
  pkg.installed:
    - pkgs: {{ bacula.get('lookup').get('client_pkgs', [])|json }}
  service.running:
    - enable: True

bacula-working-directory:
  file.directory:
    - name: {{ bacula.get('lookup').get('bacula:client:config:FileDaemon:WorkingDirectory', '/var/lib/bacula') }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require_in:
      - service: bacula-fd

bacula-pid-directory:
  file.directory:
    - name: {{ bacula.get('lookup').get('bacula:client:config:FileDaemon:Pid Directory', '/var/run/bacula') }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require_in:
      - service: bacula-fd


{% if bacula.get('client').get('encryption', False) %}
bacula-fd-key-pair:
  file.managed:
    - name: /etc/bacula/keypair.pem
    - contents_pillar: bacula:client:encryption:keypair
    - user: root
    - group: root
    - mode: 600
    - watch_in:
      - service: bacula-fd
    - require_in:
      - service: bacula-fd

bacula-fd-master-key:
  file.managed:
    - name: /etc/bacula/master.cert
    - contents_pillar: bacula:client:encryption:master_cert
    - user: root
    - group: root
    - mode: 600
    - watch_in:
      - service: bacula-fd
    - require_in:
      - service: bacula-fd
{% endif %}

{% for key, data in bacula.get('client').get('config', {}).items() %}

  {% if key in ['FileDaemon'] and bacula.get('client').get('encryption', False) %}
    {# update the first FileDaemon config only to include encryption config; nasty, but means we have a single template for all data structures #}
    {% do data[0].update ({"PKI Signatures": "Yes", "PKI Encryption": "Yes", "PKI Keypair": "/etc/bacula/keypair.pem", "PKI Master Key": "/etc/bacula/master.cert"}) %}
  {% endif %}

  {% set path = 'bacula-fd-' + key|lower if key not in ['FileDaemon'] else 'bacula-fd' %} # set the path for non-default data structures to external files (see below).
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
      {%- if key == 'FileDaemon' %}
      includes:
        {%- for include in bacula.get('client').get('config', {}).keys() %} # for structures that are NOT the default, include the external file.
          {%- if include != 'FileDaemon' %}
        - bacula-fd-{{ include }}
          {%- endif %}
        {%- endfor -%}
      {%- endif %}
    - watch_in:
      - service: bacula-fd
    - require_in:
      - service: bacula-fd
  {% endfor %}
