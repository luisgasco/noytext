#!/bin/bash

# Add noytext user
sudo adduser noytext
sudo gpasswd -a noytext sudo
su - noytext

# R installation
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -

sudo apt-get update
sudo apt-get -y install r-base

sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev libssl-dev libsasl2-dev

sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""

# Shiny server instalattion
sudo apt-get -y install gdebi-core


sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('rmarkdown', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('packrat', repos='http://cran.rstudio.com/')\""

wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb

sudo gdebi shiny-server-1.5.9.923-amd64.deb

# Install git
sudo apt-get update
sudo apt-get install git

# Install MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install mongodb-org
sudo service mongod start

# Install app
git clone https://github.com/luisgasco/noytext
sudo mv noytext /srv/shiny-server
cd /srv/shiny-server/noytext

sudo su - -c "R -e \"packrat::on()\""
sudo su - -c "R -e \"packrat::restore()\""
sudo su - -c "R -e \"packrat::init()\""