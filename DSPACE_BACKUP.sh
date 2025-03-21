#!/bin/bash
db_name="dspace-$(date +%s).dump"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo "$(tput setaf 6)Creating full backup $db_name.tar.gz ...$(tput sgr 0)"

cd "$SCRIPT_DIR"/data/db_backup/ || exit
docker exec -i dspacedb pg_dump -U dspace -Fc -f /"$db_name" dspace
cd ./data/db_backup/ || exit
docker cp dspacedb:/"$db_name" .
docker exec dspacedb sh -c "rm /$db_name"
tar -czvf "$db_name".tar.gz "$db_name"
rm "$db_name"
echo "$(tput setaf 6)Backup finished.$(tput sgr 0)"

