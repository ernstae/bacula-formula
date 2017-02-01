{% from "bacula/params.jinja" import params with context -%}

bacula-console:
  pkg.installed:
    - pkgs: {{ params.console_pkgs|json }}

bacula-console-config:
  file.managed:
    - name: /etc/bacula/bconsole.conf
    - source: salt://bacula/files/bconsole.conf
    - template: jinja
    - user: root
    - group: root
    - defaults:
      director_name: {{ salt['pillar.get']("bacula:console:director_name", "MyDirector") }}
      director_address: {{ salt['pillar.get']("bacula:console:director_address", "localhost") }}
      password: {{ salt['pillar.get']("bacula:console:password") }}
    - watch_in:
      - service: bacula-sd
