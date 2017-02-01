# Bacula

This formula installs components from the bacula backup and recovery system [bacula docs](http://www.bacula.org/7.2.x-manuals/en/main/).

## Bacula Director

The bacula director is the central component to bacula. It performs the orchestration of backup and restore jobs and acts as the bridge between the file daemon, which sits on a host where the primary data resides and the storage daemon, which controls the process of archiving the backup data.

Here is an example of some pillar data used, within the [director](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html), to configure a job to backup the logs directory.

``
  ge_bacula:  
    director:  
      dbname: bacula  
      dbuser: bacula  
      dbpassword: password  
      password: password  
      clients:  
        test-1:  
          Address: 127.0.0.1  
          Password: password  
      storage:  
        LocalStorage:  
          Password: password  
          Device: FileStorage  
      filesets:  
        logs:  
          include:  
            options:  
              signature: MD5  
              compression: GZIP  
            files:  
              - /var/logs  
      jobs:  
        test-1-logs:  
          Type: Backup  
          Client: test-1  
          FileSet: logs  
          Storage: LocalStorage  
          Pool: Default  
          Messages: Standard  
          Schedule: Hourly  
``

The following section is used to configure the connection to the catalog, which is the database holding all of the information about the backup and restore jobs that bacula has run. This is detailed in the [catalog resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016160000000000000000).

``
  ge_bacula:
    director:
      dbname: bacula
      dbuser: bacula
      dbpassword: password
``

The directors password, used for authorising access from other components is defined as follows.

``
  ge_bacula:
    director:
      password: password
``

The clients section contains a list of the bacula file daemons (client servers), that this instance of the director is configured to talk to. This is detailed in the [clients resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016130000000000000000).

``
  ge_bacula:
    director:
      clients:
        test-1:
          Address: 127.0.0.1
          Password: password
``


The storage section contains a list of the bacula storage daemons that this director can talk to. For systems using file storage (no tape etc), there will normally only be one defined. This is detailed in the [storage resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016140000000000000000).

``
  ge_bacula:
    director:
      storage:
        LocalStorage:
          Password: password
          Device: FileStorage
``

The filesets section defines lists of directories to be included or excluded from a job, along with various options that should be applied to the fileset, such as compression. This is detailed in the [fileset resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001670000000000000000).

``
  ge_bacula:
    director:
      filesets:
        logs:
          include:
            options:
              signature: MD5
              compression: GZIP
            files:
              - /var/logs
``


The jobs section defines a list of the jobs to be executed. A job ties together a lot of the other configuration components, such as clients, filessets, storage, pools, etc to define a unique task occuring on a specific client, running on a specific schedule, stored on a specific archive device, in a specific format and for a specific duration. This is detailed in the [jobs resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001630000000000000000).

``
  ge_bacula:
    director:
      jobs:
        test-1-logs:
          Type: Backup
          Client: test-1
          FileSet: logs
          Storage: LocalStorage
          Pool: Default
          Messages: Standard
          Schedule: Hourly
``


Three additional sections can be added to pillar for the director. These are jobdefs, schedules and pools. Jobdefs are a way of templating common aspects of jobs to easy repetition in job config. For example, you could create a jobdef that defines all the common components of a database backup. The the job itself would only need to define the jobdef and the client. This is covered in the [jobdef resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001640000000000000000). Schedules define the period that a job should run. This formula comes with a number of defaults for the most commonly used schedules. However, more can be added. These are covered in the [schedule resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION001650000000000000000). Pools define a number of characteristics of the files once archived. These include this such as, whether a backup creates a new file or appends to an existing one. The naming convention for files and also the retention period. This is covered in the [pools resource](http://www.bacula.org/7.2.x-manuals/en/main/Configuring_Director.html#SECTION0016150000000000000000).

## File Daemon

The file daemon is the bacula client component and runs on a target server from which data needs to be backed up or restored too. The configuration is covered in the [file daemon docs](http://www.bacula.org/7.2.x-manuals/en/main/Client_File_daemon_Configur.html).

Here is an example of the pillar data needed to configure the file daemon.

``
  ge_bacula:
    client:
      password: password
``

The only required component for the client is the password needed to connect to the director.

## Storage Daemon

The storage daemon is the component in bacula that deals with archiving data. A storage daemon can talk to a number of devices, ranging from file storage to tape and just about any other storage media you care to name. The configuration is covered in the [storage daemon docs](http://www.bacula.org/7.2.x-manuals/en/main/Storage_Daemon_Configuratio.html).

Here is an example of the pillar data needed to configure the storage daemon.

``
  ge_bacula:
    storage:
      password: password
      devices:
        FileStorage:
          Archive Device: /bacula/backup
``

## Bacula Console

The bacula console is the command line client program for the director. This is used to query the status of previous jobs, along with running jobs manually amongst over things.

Here is an example of the pillar data needed. Only the password for the director is required.

``
  ge_bacula:
    console:
      password: password
``
