{% from "ge_bacula/params.jinja" import params with context -%}

bacula-console:
  pkg.installed:
    - pkgs: {{ params.console_pkgs|json }}

bacula-console-config:
  file.managed:
    - name: /etc/bacula/bconsole.conf
    - source: salt://ge_bacula/files/bconsole.conf
    - template: jinja
    - user: root
    - group: root
    - defaults:
      director_name: {{ salt['pillar.get']("ge_bacula:console:director_name", "MyDirector") }}
      director_address: {{ salt['pillar.get']("ge_bacula:console:director_address", "localhost") }}
      password: {{ salt['pillar.get']("ge_bacula:console:password") }}
    - watch_in:
      - service: bacula-sd
