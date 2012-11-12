nitro-deploy
============

Deploy script suite compatible with Nitro project (>10.6)

This deploy script suite is not likely to work for your production/stage environment unless you fire your editor and adapt it to your configuration... consider this suite just  as starting point from which you can build your own deploy logic.

There's also a lot that can be improved in the scripts, nonetheless they have proved to be solid and we have used them on a daily basis for the Espresso.it project. Be aware that some of the deploy steps are specific for Espresso.it production environment (eg Disaster Recovery deploy & custom webservices).  

Production setup
================

We assume that you have a simplistic production environment made of the following servers:

* jboss
* frontend(s)
* admin
* search
* db

Note that there's no statistic/poll modules in our setup.

First thing first you should make sure that the script suite is copied on *all* your servers in /opt/polopoly/scripts, you might want to have a way of syncing these automatically (svn, shared mount) since you will be likely to change the scripts quite often and it is vital that they are in sync.

The reason why we deploy the release scripts to all servers is that, even if you run the ./perform_release.sh script from jboss, the script will in turn call scripts on external nodes, through ssh. You should also make sure to distribute ssh-keys from jboss to all your servers, otherwise the release script will stop and prompt for password each time it executes a remote script.

We assume that you use the Nitro assembly descriptor to create your release, in other words your release jar should look something like:

    |-- contentdata
    |   |-- admin-gui-10.5-DR3-SNAPSHOT-contentdata.jar
    |   |-- baseline-2.0.4-contentdata.jar
    |   |-- environment-prod-content-1.0-SNAPSHOT-contentdata.jar
    |   |-- project-content-1.0-SNAPSHOT-contentdata.jar
    |   |-- project-source-1.0-SNAPSHOT-contentdata.jar
    |   |-- google-maps-1.0-SNAPSHOT-contentdata.jar
    |   |-- greenfieldtimes-content-10.5-DR3-SNAPSHOT-contentdata.jar
    |   |-- inbox-control-10.5-DR3-SNAPSHOT-activate-contentdata.jar
    |   |-- init-xml-10.5-DR3-SNAPSHOT-contentdata.jar
    |   |-- interactive-preview-10.5-DR3-SNAPSHOT-contentdata.jar
    |   |-- moderation-gui-10.5-DR3-SNAPSHOT-contentdata.jar
    |   |-- repubblicatv-1.0-SNAPSHOT-contentdata.jar
    |   `-- twitter-plugin-2.0.1-contentdata.jar
    |-- deployment-cm
    |   |-- cm-server-10.5-DR3-SNAPSHOT.ear
    |   |-- connection-properties-10.5-DR3-SNAPSHOT.war
    |   `-- content-hub.war
    |-- deployment-config
    |   |-- config.zip
    |   |-- connection.properties
    |   |-- ejb-configuration.properties
    |   |-- importOrder.txt
    |   |-- polopoly-cli.jar
    |   |-- polopoly-imports.jar
    |   |-- project-imports.jar
    |   `-- solr-home.zip
    |-- deployment-front
    |   |-- ROOT.war
    |   `-- solr.war
    |-- deployment-polopoly-gui
    |   |-- ROOT.war
    |   `-- polopoly.war
    |-- deployment-servers
    |   |-- solr-indexer.war
    |   `-- solr.war
    |-- lib-client
    |   |-- ...

Release 
=======

In our project we have set up a Jenkins job that execute the following maven task:
    mvn clean install p:assemble-dist -DtargetEnv=prod
When the build is completed, it uploads the distribution file to an FTP server within the DMZ of our production network.

The first step is to download the release dist to the Jboss node:

    local ~$> ssh user@jboss.prod
    
    jboss.prod ~$> cd /opt/polopoly/scripts
    
    jboss.prod /opt/polopoly/scripts$> ./download_dist.sh
    // interactive //


Once download is completed we can start the release suite:


    jboss.prod /opt/polopoly/scripts$> ./perform_release.sh
    ....  unpacking the release, stop remote servers, distribute WARs ...
    The release is finished!



Multiple environments
=====================

Support for multiple environments is based on an assumption on the hostnames: the environemnt group should be defined in the 2 level of the host name, so for instance jboss.prod.foo and fe1.prod.foo belongs to the *prod* environment.

Each environment should define its conf file in ./deploy/$ENV.config, this file will be automatically sourced in all the scripts. In other words if you run the release from jboss.prod.foo, the release scripts will source the configuration file ./deploy/prod.config.

If the naming convention on the hostname doesn't suit your environment, you can change how configuration files are resolved in ./deploy/config.sh  
