{% from "bacula/map.jinja" import bacula with context -%}

bacula-fd:
  pkg.installed:
    - pkgs: {{ bacula.client_pkgs|json }}

bacula-fd-config:
  file.managed:
    - name: /etc/bacula/bacula-fd.conf
    - source: salt://bacula/files/bacula-fd.conf
    - template: jinja
    - user: root
    - group: root
    - defaults:
      client_name: {{ salt['pillar.get']("bacula:client:name", grains['localhost']) }}
      working_directory: {{ salt['pillar.get']("bacula:client:working_directory", "/var/lib/bacula") }}
      max_concurrent: {{ salt['pillar.get']("bacula:client:concurrent", "20") }}
      director_name: {{ salt['pillar.get']("bacula:client:director", "MyDirector") }}
      password: {{ salt['pillar.get']("bacula:client:password") }}
      monitor_password: {{ salt['pillar.get']("bacula:client:monitor_password", False) }}
      encryption: {{ bacula.encryption }}
    - watch_in:
      - service: bacula-fd

{% if bacula.encryption %}
bacula-fd-key-pair:
  file.managed:
    - name: /etc/bacula/keypair.pem
    - contents_pillar: bacula:keypair
    - user: root
    - group: root
    - mode: 600

bacula-fd-master-key:
  file.managed:
    - name: /etc/bacula/master.cert
    - contents_pillar: bacula:master_cert
    - user: root
    - group: root
    - mode: 600
{% endif %}
