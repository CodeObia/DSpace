## Installation upgrading from DSpace6
- Download the files:
1. https://gist.github.com/mohammadsalem/134ad817fc57d4d0a308155b23ca8bac
2. https://gist.github.com/mohammadsalem/6471358f9b1b9c1e805622bab3699c71

__Note: For each statistics core an export and import line should be added__

- Comment the Solr volume line in docker-compose.yml
- Create [GeoIP.conf](https://www.maxmind.com/en/accounts/current/license-key/GeoIP.conf) in directory `custom_configuration/config`
- Add handle-server directory for the installation into the relevant directory e.g. `custom_configuration/themes/MELSpace/`
- [Update Handle Server Configuration](https://wiki.lyrasis.org/display/DSDOC7x/Upgrading+DSpace#:~:text=Update%20Handle%20Server%20Configuration)
- Clone Statistics
```shell
git clone --single-branch --branch dspace-7_x https://github.com/codeobia/dspace-statistics-api-js.git
```
- Adjust environment variables in dspace-statistics-api-js/envExample
- Adjust environment variables in docker-compose.yml
- Run the script to migrate the DB and build the containers
```shell
sh DB_MIGRATE.sh dspace dspace_db dspacedb
```
- Run the script to migrate Solr statistics (the script might fail, check if Solr is working on DSpace 6 or just try again)
```shell
sh upgrade_notes.sh dspace dspacesolr
```
- Copy Solr data
```shell
SOLR_USER=$(docker exec dspacesolr bash -c 'id $(whoami)' | grep -oP 'uid\=[0-9]+' | grep -oP '[0-9]+') \
&& SOLR_GROUP=$(docker exec dspacesolr bash -c 'id $(whoami)' | grep -oP 'gid\=[0-9]+' | grep -oP '[0-9]+') \
&& docker stop dspacesolr \
&& docker cp dspacesolr:/var/solr/data data/solrData && \
sudo chown -R "$SOLR_USER":"$SOLR_GROUP" data/solrData
```
- Put back the Solr volume line in docker-compose.yml
- Re-create solr container 
```shell
docker compose up -d --no-deps dspacesolr
```

## Fresh installation (or using DSpace7 data)
- Comment the Solr volume line in docker-compose.yml
- Create [GeoIP.conf](https://www.maxmind.com/en/accounts/current/license-key/GeoIP.conf) in directory `custom_configuration/config`
- Add handle-server directory for the installation into the relevant directory e.g. `custom_configuration/themes/MELSpace/`
- Clone Statistics
```shell
git clone --single-branch --branch dspace-7_x https://github.com/codeobia/dspace-statistics-api-js.git
```
- Adjust environment variables in dspace-statistics-api-js/envExample
- Adjust environment variables in docker-compose.yml
- Build docker
```shell
docker compose up -d --build
```
- Copy Solr data
```shell
SOLR_USER=$(docker exec dspacesolr bash -c 'id $(whoami)' | grep -oP 'uid\=[0-9]+' | grep -oP '[0-9]+') \
&& SOLR_GROUP=$(docker exec dspacesolr bash -c 'id $(whoami)' | grep -oP 'gid\=[0-9]+' | grep -oP '[0-9]+') \
&& docker stop dspacesolr \
&& docker cp dspacesolr:/var/solr/data solrData && \
sudo chown -R "$SOLR_USER":"$SOLR_GROUP" solrData
```
- Put back the Solr volume line in docker-compose.yml
- Re-create solr container
```shell
docker compose up -d --no-deps dspacesolr
```