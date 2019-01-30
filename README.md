<h1 align="center">
  <br>
  <a><img src="https://github.com/luisgasco/noytext/blob/master/www/img/Noytext-02.jpg?raw=true" alt="Noytext" width="800"></a>
</h1>

       
<h4 align="center">A web-based platform for annotaing social media documents to be used in text mining based acoustic noise perception research.</h4>

<p align="center">
  <a href="https://saythanks.io/to/luisgasco">
      <img src="https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg">
  </a>
  <a href="https://paypal.me/luisgasco?locale.x=es_ES">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#credits">Credits</a> •
  <a href="#cite">Cite</a> •
  <a href="#about">About</a> •
  <a href="#license">License</a>
</p>



## Key Features

* Fully customizable UI - Adapt Noytext to your needs
  - Show your own project description html page
  - Introduce your team with you own html file
  - Configure your own help page
  - Personlize your navigation bar as you wish
  - Choose the overall appearance of the web-app using [shinythemes](https://rstudio.github.io/shinythemes/)
* Connect the web-app to your own Mongo database
* Interannotator agreement - Define the No. of times a text should be annotated by different users
* Get info. about your annotators:
  - Define a small questionaire to ask your annotators.
  - It works with the majority of [Shiny control input widgets](https://shiny.rstudio.com/tutorial/written-tutorial/lesson3/) and two additional inputs of [shinyWidgets](https://github.com/dreamRs/shinyWidgets)
* Emoji support in text visualization 👌
* Cross platform
  - Windows, macOS and Linux. You only need a valid [R-Studio](https://www.rstudio.com/) or [Shiny Server](https://www.rstudio.com/products/shiny/shiny-server/) installation.


More examples of readmes:
https://github.com/amitmerchant1990/electron-markdownify
https://github.com/aimeos/aimeos-typo3


## How To Use

To clone this app, you'll need [Git](https://git-scm.com).
To use this app, you'll need both [R](https://www.r-project.org/) and [MongoDB](https://www.mongodb.com/) installed on your machine. 
If you are going to use it in a local environment, I recommend you to use [RStudio](https://www.rstudio.com/).
If you want to allow other people to use the app, you should install [Shiny server](https://shiny.rstudio.com/) in your own server

Here you have the steps to run the app in your cloud server (running Ubuntu 16.04)
<details>
  <summary>1. Server</summary>
  
  1. The first thing you should do is add a non-root user.
  ```bash
  sudo adduser yourname
  sudo gpasswd -a yourname sudo
  ```
  2. Switch to "yourname"
  ```bash
  su - yourname
  ```
</details>
<details>
  <summary>2. Install R</summary>
  
  1. Add R senial to our sources.list:
  ```bash
  sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list'
  ```
  2. Add the public keys:
  ```bash
  gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
  gpg -a --export E084DAB9 | sudo apt-key add -
  ```
  3. Install R
  ```bash
  sudo apt-get update
  sudo apt-get -y install r-base
  ```
  4. Check that R is working (use the command quit() to exit)
  ```bash
  R
  ```
  5. Install dependencies to install R-libraries
  ```bash
  sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev libssl-dev libsasl2-dev
  ```
  6. Install devtools
  ```bash
  sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
  ```
</details>
<details>
  <summary>3. Install Shiny Server</summary>
  
  1. Install some dependencies
  ```bash
  sudo apt-get -y install gdebi-core
  ```
  2. Install packages you will need
  ```bash
  sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
  sudo su - -c "R -e \"install.packages('rmarkdown', repos='http://cran.rstudio.com/')\""
  sudo su - -c "R -e \"install.packages('packrat', repos='http://cran.rstudio.com/')\""
  ```
  3. Get Shiny installation files
  ```bash
  wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb
  ```
  4. Install Shiny
  ```bash
  sudo gdebi shiny-server-1.5.9.923-amd64.deb
  ```
  5. Check that shiny server is working on port 3838: http://YOUR_IP:3838
</details>
<details>
  <summary>3. Install Git</summary>
  
  ```bash
  sudo apt-get update
  sudo apt-get install git
  ```
</details>
<details>
  <summary>4. Install MongoDB</summary>
  
  1. Import publick key used by the management system for MongoDB
  ```bash
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
  ```
  2. Create a list file for MongoDB for Ubuntu 16.04
  ```bash
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
  ```
  3. Install MongoDB
   ```bash
  sudo apt-get update
  sudo apt-get install mongodb-org
  ```
</details>
<details>
  <summary>5. Install App</summary>
  
  1. Clone repository from Github
  ```bash
  git clone https://github.com/luisgasco/noytext
  ```
  2. Move noytext to srv folder (the standard path for shiny apps)
  ```bash
  sudo mv noytext /srv/shiny-server
  ```
  3. Go to that path
  ```bash
  cd /srv/shiny-server/noytext
  ```
  4. Enter to R like super user
  ```bash
  sudo R
  ```
  5. Enter this commands on R
  ```R
  # Activate packrat (library to manage R libraries)
  packrat::on() 
  # Install libraries on the noytext private library
  packrat::restore()
  ```
</details>

## Credits
This app uses the following open source programs:

- [Shiny](https://shiny.rstudio.com/)
- [R](https://www.r-project.org/)
- [MongoDB](https://www.mongodb.com/)
- [Javascript](https://www.javascript.com/)

And the following R´- libraries:
- [rintrojs](https://github.com/carlganz/rintrojs)
- [shinyBS](https://ebailey78.github.io/shinyBS/)
- [shinyJS](https://github.com/daattali/shinyjs)
- [shinyWidgets](https://github.com/dreamRs/shinyWidgets)
- [mongolite](https://jeroen.github.io/mongolite/)
- [tidyr](https://tidyr.tidyverse.org/)
- [dplyr](https://dplyr.tidyverse.org/)

## Cite
To cite Noytext please use the next reference:
 - [**L. Gasco**, C. Clavel, C. Asensio and G. de Arcas “Beyond sound level monitoring: Exploitation of social media to gather citizens subjective response to noise”,  Science of the Total Environment. 658, p  69-79. March 2019. ](https://doi.org/10.1016/j.scitotenv.2018.12.071)

## About
I developed this tool while I was a PhD student at [Instrumentation and Applied Acoustics Research Group (I2A2 Group)]() of [Universidad Politécnica de Madrid](). Part of this code was developed while I was doing a research stay at [Télecom Paristech]().


<div align="center"><a href="http://www.i2a2.upm.es/"> <img src="https://github.com/luisgasco/noytext/blob/master/www/logo_notext.jpg" alt="I2A2"	width="auto" height="100" align="middle" /></a> <a href="http://www.upm.es/"><img src="https://github.com/luisgasco/noytext/blob/master/www/logo2.jpg" alt="KitUPMten"	width="auto" height="100" align="middle" /></a> <a href=https://www.telecom-paristech.fr/"> <img src="https://github.com/luisgasco/noytext/blob/master/www/logo_telecom.png" alt="TELECOM"	width="auto" height="100" align="middle" /></a> </div>


## License

AGPL-3.0


## You may also like...

- [Ropensky](https://github.com/luisgasco/Ropensky) - R library to get data from OpenSky Network API.

---

> [luisgasco.es](http://luisgasco.es/) &nbsp;&middot;&nbsp;
> GitHub [@luisgasco](https://github.com/luisgasco) &nbsp;&middot;&nbsp;
> Twitter [@luisgasco](https://twitter.com/luisgasco)
> Facebook [Luis Gascó Sánchez page](https://www.facebook.com/Luis-Gasco-Sanchez-165003227504667)

