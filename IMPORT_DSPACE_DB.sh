#!/bin/bash

echo "$(tput setaf 6)ARE YOU SURE? <yes/no>"$(tput sgr 0)
read sure
if [ $sure != 'yes' ]; then
   exit
fi

echo "$(tput setaf 6)AGAIN ARE YOU SURE? <yes/no>"$(tput sgr 0)
read sureagain
if [ $sureagain != 'yes' ]; then
   exit
fi

cd ./db_backup

echo "$(tput setaf 6)mEnter database number <<default:Last downloaded database>>"$(tput sgr 0)
read num

if [ ! -n "$num" ]; then
    num=`ls -t | awk '{printf("%s",$0);exit}' | tr -d '[:alpha:]\-\.'`
fi

if [ -f "dspace-$num.dump" ]; then
   echo "$(tput setaf 5)File dspace-$num.dump  exist."$(tput sgr 0)
elif [ -f "dspace-$num.dump.tar.gz" ]; then
   echo "$(tput setaf 5)Extracting the file..."$(tput sgr 0)
   tar -xvzf dspace-$num.dump.tar.gz
else
   echo "$(tput setaf 5)File not found"$(tput sgr 0)
   exit
fi

echo "$(tput setaf 6)Stopping dspace container..."$(tput sgr 0)
docker stop dspace7

echo "$(tput setaf 6)Droping database..."$(tput sgr 0)
docker exec dspacedb dropdb -U dspace dspace

echo "$(tput setaf 6)Creating database..."$(tput sgr 0)
docker exec dspacedb createdb -U dspace -O dspace --encoding=UNICODE dspace

echo "$(tput setaf 6)Creating pgcrypto extension..."$(tput sgr 0)
docker exec dspacedb psql -U dspace dspace -c 'CREATE EXTENSION pgcrypto;'

echo "$(tput setaf 6)Creating dspace user..."$(tput sgr 0)
docker exec dspacedb psql -U dspace dspace -c "CREATE USER postgres WITH PASSWORD 'postgres';"
docker exec dspacedb psql -U dspace dspace -c 'alter user postgres superuser;'

echo "$(tput setaf 6)Copying database..."$(tput sgr 0)
docker cp dspace-$num.dump dspacedb:/

echo "$(tput setaf 6)Importing database..."$(tput sgr 0)
docker exec dspacedb pg_restore -U postgres -d dspace /dspace-$num.dump

echo "$(tput setaf 6)Vacum database..."$(tput sgr 0)
docker exec dspacedb vacuumdb -U dspace dspace

echo "$(tput setaf 6)Updating sequences..."$(tput sgr 0)
docker cp ../dspace-api/src/main/resources/org/dspace/storage/rdbms/sqlmigration/postgres/update-sequences.sql dspacedb:/
docker exec dspacedb psql -U dspace -f /update-sequences.sql dspace

echo "$(tput setaf 6)Removing dspace user..."$(tput sgr 0)
docker exec dspacedb psql -U dspace dspace -c 'alter user postgres nosuperuser;'

echo "$(tput setaf 6)Cleaning up..."$(tput sgr 0)
docker exec -it dspacedb bash -c "rm dspace-$num.dump"
docker exec -it dspacedb bash -c "rm update-sequences.sql"
#rm dspace-$num.dump

echo "$(tput setaf 6)Starting dspace container..."$(tput sgr 0)
docker start dspace7

echo "$(tput setaf 6)Finish"$(tput sgr 0)