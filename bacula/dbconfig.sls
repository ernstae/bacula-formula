{% from "ge_bacula/params.jinja" import params with context -%}

# On a debian based system the bacula-director-pgsql or bacula-director-mysql package will create the bacula
# database on the local host with a user of bacula and a randomly generated password. In order to control this
# process we pre set the values that the packge will use during installation with dbconfig-common.

dbconfig-common:
  pkg.installed:
    - refresh: False

bacula-dbconfig-config:
  file.managed:
    - name : /etc/dbconfig-common/bacula-director-{{params.dbtype}}.conf
    - source: salt://ge_bacula/files/bacula-director-pgsql.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 0600
    - defaults:
      dbuser: {{ salt['pillar.get']("ge_bacula:director:dbuser", "") }}
      dbpassword: {{ salt['pillar.get']("ge_bacula:director:dbpassword", "") }}
      dbtype: {{ params.dbtype }}
      dbhost: {{ salt['pillar.get']("ge_bacula:director:dbhost", "") }}
      dbname: {{ salt['pillar.get']("ge_bacula:director:dbname", "") }}
    - require_in:
      - pkg: bacula-director
