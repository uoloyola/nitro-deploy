nitro-deploy
============

Deploy script suite compatible with Nitro project (>10.6)

This deploy script suite is not likely to work for your production/stage environment, unless you fire your editor and adapt it to your specific configuration... in other words this is just as starting point from which you can build your own deploy logic.


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

Also we assume that you use the Nitro assembly descriptor to create your release, in other words your release jar should look something like:

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
