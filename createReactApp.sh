#!/bin/sh

print_status() {
  local outp=$(echo "$1" | sed -r 's/\\n/\\n## /mg')
  echo
  echo -e "## ${outp}"
  echo
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cfg=$1
if [[ -n "$cfg" ]]; then
    echo "$1"
else
    echo "Please supply the path to the configuration file as argument 1"
    exit
fi

print_status "including configuration from: $1"
. $1

# add the create-react-app to yarn/npm
print_status "installing create-react-app"
yarn global add create-react-app

SITE_ROOT=$BASE_DIR/$APP_NAME
print_status "creating app $APP_NAME in $SITE_ROOT"
cd $BASE_DIR
yarn add create-react-app
yarn create-react-app $APP_NAME
chown -hR $PROVISION_USER: $SITE_ROOT
cd $SITE_ROOT

print_status "environment is $ENVIRONMENT"
if [ $ENVIRONMENT == "dev" ]; then
  print_status "reconfiguring nginx"
  \cp -f $PROVISION_DIR/nginx_drop.conf /etc/nginx/conf.d/drop.conf
  \cp -f $PROVISION_DIR/dev_nginx_default.conf /etc/nginx/conf.d/default.conf
  \cp -f $PROVISION_DIR/dev_nginx.conf /etc/nginx/nginx.conf
fi

print_status "creating pm2 configuration"
[ -d "$TEMP_DIR" ] || mkdir "$TEMP_DIR"
f1=$RANDOM
sed s:SITE_ROOT:"$SITE_ROOT":g $PROVISION_DIR/pm2_process.json > $TEMP_DIR/$f1.json
sed s:APP_NAME:"$APP_NAME":g $TEMP_DIR/$f1.json > $TEMP_DIR/process.json
mv -f $TEMP_DIR/process.json $SITE_ROOT/process.json
rm -rf $TEMP_DIR

print_status "starting app $APP_NAME"
pm2 start process.json
chkconfig nginx on
/etc/init.d/nginx restart
/etc/init.d/nginx status
