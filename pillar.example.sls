bacula:
  client:
    encryption:
      keypair: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAxoHZOJRGLTd1PeVAPVTulDa3ncup2gFmAQ3t5Zf+1q1m7e2j
        ...
        TSMVXqQ7gqzyxr8lnAMk7BBrfiuersovHsW3BHgYTGQBmr7bdM2k
        -----END RSA PRIVATE KEY-----
        -----BEGIN CERTIFICATE-----
        MIIFUjCCBDqgAwIBAgIJAPBXSgBhV2uEMA0GCSqGSIb3DQEBDQUAMIHLMQswCQYD
        ...
        p+w6xMcg94T2sDsfIPzhG4Zd7P66AeY51kgi9+ztB+aeAd+73p12i6BTC7B5z50G
        /wWDiNTubfYMNMSMnTxPXF2v/btWTw==
        -----END CERTIFICATE-----
      master_cert: |
        -----BEGIN CERTIFICATE-----
        MIIE5TCCA82gAwIBAgIJAO+/VhzgLottMA0GCSqGSIb3DQEBBQUAMIGnMQswCQYD
        ...
        ZX/mu422/MDM
        -----END CERTIFICATE-----
    config:
      Director:
        - Name: MyDirector
          Password: La12Ha991AhMnanQ2
      FileDaemon:
        - Name: prod-ops-bacula-01
          FDport: 9102
          WorkingDirectory: /var/lib/bacula
          Pid Directory: /var/run/bacula
          Maximum Concurrent Jobs: 20
      Messages:
        - Name: Standard
          director: MyDirector = all, !skipped, !restored
  console:
    config:
      Director:
        - Name: MyDirector
          DIRport: 9101
          address: localhost
          Password: 9e3Rayg1Ia6Kn29xn8B6yh2
  director:
    config:
      Director:
        - Name: MyDirector
          DIRPort: 9101
          QueryFile: /etc/bacula/scripts/query.sql
          WorkingDirectory: /var/lib/bacula
          PidDirectory: /var/run/bacula
          Maximum Concurrent Jobs: 20
          Password: 9e3Rayg1Ia6Kn29xn8B6yh2
          # Console password
          Messages: Daemon
      Catalog:
        - Name: MyCatalog
          dbname: "bacula"
          dbaddress: "127.0.0.1"
          dbuser: "bacula"
          dbpassword: "lHa92Hau2mm^a5%a"
      Messages:
        - Name: Standard
          console: all, !skipped, !saved
          append: '"/var/log/bacula/bacula.log" = all, !skipped'
          catalog: all
        - Name: Daemon
          console: all, !skipped, !saved
          append: '"/var/log/bacula/bacula.log" = all, !skipped'
      Pool:
        - Name: Default
          Pool Type: Backup
          Recycle: yes
	  # Bacula can automatically recycle Volumes
          AutoPrune: yes
          # Prune expired volumes
          Volume Retention: 1 year
          # one year
          Maximum Volume Jobs: 1
          # create a new volume for each job
          Label Format: ${Job}-${Level}-${JobId}
      Client:
        - Name: prod-application-postgresql-01
          Catalog: MyCatalog
          Maximum Concurrent Jobs: 1
          AutoPrune: yes
          File Retention: 6 months
          Address: prod-application-postgresql-01.domain.local
          Job Retention: 6 months
          Password: 5g9yw3Zb7WWC9Cwrty5c
      FileSet:
        - Name: fs-postgres-dump
          Include:
            - Options:
                - Compression: GZIP
                  Signature: MD5
              File:
                - /tmp/pg_dumps/all.sql
      JobDefs:
        - Name: jd-postgres-dump
          FileSet: fs-postgres-dump
          Level: Incremental
          Messages: Standard
          Priority: 10
          Write Bootstrap: /var/lib/bacula/%c_%n.bsr
          Client Run Before Job: su postgres -c 'pg_dumpall --add-drop-database > /tmp/pg_dumps/all.sql'
          Type: Backup
          Schedule: TwiceDaily
          Accurate: yes
          Client Run After Job: rm /tmp/pg_dumps/all.sql
          Pool: Default
      Job:
        - Name: prod-application-postgres-pgdump
          JobDefs: jd-postgres-dump
          Storage: StorageNode
          Client: prod-application-postgresql-01
      Schedule:
        - Name: TwiceDaily
          Run:
          - Incremental Daily at 12:00am
          - Incremental Daily at 12:00pm
      Storage:
        - Name: StorageNode
          Media Type: File
          SDPort: 9103
          Address: prod-ops-bacula-01.domain.local
          Device: FileStorage
          Password: Hak9Ja2klaDhb2aYGyas
  storage:
    config:
      Storage:
        - Name: MyStorage
          SDPort: 9103
          WorkingDirectory: /var/lib/bacula
          Pid Directory: "/var/run/bacula"
          Maximum Concurrent Jobs: 20
      Director:
        - Name: MyDirector
          Password: Hak9Ja2klaDhb2aYGyas
      Messages:
        - Name: Standard
          director: MyDirector = all
      Device:
        - Name: FileStorage
          LabelMedia: yes
          Media Type: File
          AutomaticMount: yes
          RemovableMedia: no
          Archive Device: /backup/prod-ops-bacula-01
          AlwaysOpen: no
          Random Access: Yes
