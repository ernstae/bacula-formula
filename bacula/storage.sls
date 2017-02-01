{% from "ge_bacula/params.jinja" import params with context -%}

bacula-sd:
  pkg.installed:
    - pkgs: {{ (params.common_pkgs + params.storage_pkgs)|json }}
  service.running:
    - enable: True

bacula-sd-config:
  file.managed:
    - name: /etc/bacula/bacula-sd.conf
    - source: salt://ge_bacula/files/bacula-sd.conf
    - template: jinja
    - user: root
    - group: root
    - defaults:
      storage_name: {{ salt['pillar.get']("ge_bacula:storage:name", "MyStorage") }}
      working_directory: {{ salt['pillar.get']("ge_bacula:storage:working_directory", "/var/lib/bacula") }}
      max_concurrent: {{ salt['pillar.get']("ge_bacula:storage:concurrent", "20") }}
      director_name: {{ salt['pillar.get']("ge_bacula:storage:director", "MyDirector") }}
      password: {{ salt['pillar.get']("ge_bacula:storage:password") }}
      monitor_password: {{ salt['pillar.get']("ge_bacula:storage:monitor_password", False) }} 
    - watch_in:
      - service: bacula-sd

bacula-sd-devices-config:
  file.managed:
    - name: /etc/bacula/bacula-sd-devices.conf
    - source: salt://ge_bacula/files/bacula-sd-devices.conf
    - template: jinja
    - user: root
    - group: root
    - defaults:
      devices: {{ salt['pillar.get']("ge_bacula:storage:devices", {}) }}
    - watch_in:
      - service: bacula-sd
