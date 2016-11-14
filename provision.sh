#!/bin/sh

print_status() {
  local outp=$(echo "$1" | sed -r 's/\\n/\\n## /mg')
  echo
  echo -e "## ${outp}"
  echo
}

WORKING_DIR=$(pwd)
print_status "working directory is $WORKING_DIR"

cfg=$1
if [[ -n "$cfg" ]]; then
    echo "$1"
else
    echo "please supply the path to the configuration file as argument 1"
    exit 1
fi
print_status "including configuration from: $1"
. $1

# update OS
print_status "updating OS"
yum -y update

# set server timezone
print_status "setting local time to $TIMEZONE"
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
date

# disable ipv6 traffic
print_status "disabling IPv6"
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# install yarn, npm, and node
print_status "installing yarn, npm, and node"
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
yum install -y nodejs yarn npm

# install pm2 with yarn
print_status "installing pm2"
yarn global add pm2

# install nginx
print_status "installing nginx"
yum install -y epel-release
yum install -y nginx

print_status "environment is $ENVIRONMENT"
if [ $ENVIRONMENT == "dev" ]; then
  print_status "installing git, nano, rmate"
  yum install -y git nano
  git config --global core.editor "nano"
  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email $GIT_USER_EMAIL


  #  pull project from repo
  #  ssh-keyscan -H $GIT_HOST >> ~/.ssh/known_hosts
  #  ssh -T git@$GIT_HOST
  #  git clone git@$GIT_HOST:$GIT_USER_NAME/$GIT_REPO

  # add rmate so we can remote edit w/ atom
  curl -o /usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate
  chmod +x /usr/local/bin/rmate
fi

/etc/init.d/nginx start

print_status "all done"
