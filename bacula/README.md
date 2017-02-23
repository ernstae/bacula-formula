# Bacula

This formula installs components from the bacula backup and recovery system [bacula docs](http://www.bacula.org/7.2.x-manuals/en/main/).

The pillar expected by this formula is split into each component; director, client, storage and console. Each components' pillar will comprise, at very least, a `config` section. The `config` section is a direct mapping between pillar and Bacula config. For example:
```
bacula:  
  director:
    config:
      Client:
        - Name: Client1
          Address: client1.domain.local
          Password: b4dp455w0rd
        - Name: Client2
          Address: client2.domain.local
          Password: 0mfg!
```

translates directly as:
```
Client {
  Name = Client1
  Address = client1.domain.local
  Password = b4dp455w0rd
}

Client {
  Name = Client2
  Address = client2.domain.local
  Password = 0mfg!
}
```

## Bacula Director

The bacula director is the central component to bacula. It performs the orchestration of backup and restore jobs and acts as the bridge between the file daemon, which sits on a host where the primary data resides and the storage daemon, which controls the process of archiving the backup data

Here is an example of some pillar data used, within the [director](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html), to configure a job to backup the logs directory.

```
bacula:  
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
```

The following section is used to configure the connection to the catalog, which is the database holding all of the information about the backup and restore jobs that bacula has run. This is detailed in the [catalog resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016160000000000000000).

```
bacula:  
  director:
    config:
      Catalog:
        - Name: MyCatalog
          dbname: "bacula"
          dbaddress: "127.0.0.1"
          dbuser: "bacula"
          dbpassword: "lHa92Hau2mm^a5%a"
```

The Director config, including password, used for authorising access from other components is defined as follows.

```
bacula:  
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
```

The clients section contains a list of the bacula file daemons (client servers), that this instance of the director is configured to talk to. This is detailed in the [clients resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016130000000000000000).

```
bacula:
  director:
    config:
      Client:
        - Name: prod-application-postgresql-01
          Catalog: MyCatalog
          Maximum Concurrent Jobs: 1
          AutoPrune: yes
          File Retention: 6 months
          Address: prod-application-postgresql-01.domain.local
          Job Retention: 6 months
          Password: 5g9yw3Zb7WWC9Cwrty5c
```


The storage section contains a list of the bacula storage daemons that this director can talk to. For systems using file storage (no tape etc), there will normally only be one defined. This is detailed in the [storage resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016140000000000000000).

```
bacula:
  director:
    config:
      Storage:
        - Name: StorageNode
          Media Type: File
          SDPort: 9103
          Address: prod-ops-bacula-01.domain.local
          Device: FileStorage
          Password: Hak9Ja2klaDhb2aYGyas
```

The filesets section defines lists of directories to be included or excluded from a job, along with various options that should be applied to the fileset, such as compression. This is detailed in the [fileset resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001670000000000000000).

```
bacula:
  director:
    config:
      FileSet:
        - Name: fs-postgres-dump
          Include:
            - Options:
                - Compression: GZIP
                  Signature: MD5
              File:
                - /tmp/pg_dumps/all.sql
```


The jobs section defines a list of the jobs to be executed. A job ties together a lot of the other configuration components, such as clients, filessets, storage, pools, etc to define a unique task occuring on a specific client, running on a specific schedule, stored on a specific archive device, in a specific format and for a specific duration. This is detailed in the [jobs resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001630000000000000000).

```
bacula:
  director:
    config:
      Job:
        - Name: prod-application-postgres-pgdump
          JobDefs: jd-postgres-dump
          Storage: StorageNode
          Client: prod-application-postgresql-01
```

Three additional sections can be added to pillar for the director. These are jobdefs, schedules and pools. Jobdefs are a way of templating common aspects of jobs to easy repetition in job config. For example, you could create a jobdef that defines all the common components of a database backup. The the job itself would only need to define the jobdef and the client. This is covered in the [jobdef resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001640000000000000000). Schedules define the period that a job should run. These are covered in the [schedule resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001650000000000000000). Pools define a number of characteristics of the files once archived. These include this such as, whether a backup creates a new file or appends to an existing one. The naming convention for files and also the retention period. This is covered in the [pools resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016150000000000000000).

## File Daemon

The file daemon is the bacula client component and runs on a target server from which data needs to be backed up or restored too. The configuration is covered in the [file daemon docs](http://www.bacula.org/7.2.x-manuals/en/main/Client_File_daemon_Configur.html).

Here is an example of the pillar data needed to configure the file daemon. In addition to the `config` section, an additional `encryption` section may be added to enable encryption of the backups for this client. The `master_cert` is always the same for a given Director.

```
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
```

## Storage Daemon

The storage daemon is the component in bacula that deals with archiving data. A storage daemon can talk to a number of devices, ranging from file storage to tape and just about any other storage media you care to name. The configuration is covered in the [storage daemon docs](http://www.bacula.org/7.2.x-manuals/en/main/Storage_Daemon_Configuratio.html).

Here is an example of the pillar data needed to configure the storage daemon.

```
bacula:
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
```

## Bacula Console

The bacula console is the command line client program for the director. This is used to query the status of previous jobs, along with running jobs manually amongst over things.

Here is an example of the pillar data needed.

```
bacula:   
  console:
    config:
      Director:
        - Name: MyDirector
          DIRport: 9101
          address: localhost
          Password: 9e3Rayg1Ia6Kn29xn8B6yh2
```
