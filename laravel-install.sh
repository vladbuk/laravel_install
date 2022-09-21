#!/bin/bash

set -e

REPO=""
BRANCH=""
WORKDIR=""
DB_USER=""
DB_NAME=""
DB_PASS=""

echo "Creating database"

if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo "database exists"
else
    sudo -u postgres createuser --pwprompt $DB_USER
    sudo -u postgres createdb -O $DB_USER $BD_NAME
fi

echo "Cloning project from repo"
if [[ -d $WORKDIR ]]
then
    cd $WORKDIR
    git pull $REPO
    git checkout $BRANCH
else
    mkdir -p $WORKDIR
    cd $WORKDIR
    git clone $REPO $WORKDIR -b $BRANCH
fi

# after that configure .env
if [[ ! -f .env ]]
then
    cp .env.example .env
    #nano .env
    sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=pgsql/" .env
    sed -i "s/DB_HOST=.*/DB_HOST=localhost/" .env
    sed -i "s/DB_PORT=.*/DB_PORT=5432/" .env
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env
fi

composer install
php artisan migrate:fresh --seed
php artisan key:generate
sudo chmod -R 775 storage/framework/cache/data/
php artisan storage:link

echo "***************************************"
echo "*** Laravel installed successfully. ***"
echo "***************************************"
