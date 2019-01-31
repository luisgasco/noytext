<h1 align="center">
  <br>
  <a href="https://luisgasco.github.io/noytext_web/"><img src="https://github.com/luisgasco/noytext/blob/master/www/img/Noytext%20Final-01.jpg?raw=true" alt="Noytext" width="100%"></a>
</h1>

       
<h4 align="center">A web-based platform for annotating short-text documents to be used in applied text-mining based research.</h4>

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
  <a href="#installation">Installation</a> •
  <a href="#configuration">Configuration</a> •
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


<!---More examples of readmes: https://github.com/amitmerchant1990/electron-markdownify https://github.com/aimeos/aimeos-typo3 )-->


## Installation

To clone this app, you'll need [Git](https://git-scm.com) • To use this app, you'll need both [R](https://www.r-project.org/) and [MongoDB](https://www.mongodb.com/) installed on your machine • If you are going to use it in a local environment, I recommend you to use [RStudio](https://www.rstudio.com/) • If you want to allow other people to use the app, you should install [Shiny server](https://shiny.rstudio.com/) in your own server

Here you have the steps to run the app in your cloud server (running Ubuntu 16.04)
<details>
  <summary><b>1. Server</b></summary>
  
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
  <summary><b>2. Install R</b></summary>
  
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
  <summary><b>3. Install Shiny Server</b></summary>
  
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
  <summary><b>4. Install Git</b></summary>
     
      sudo apt-get update
      sudo apt-get install git
      
</details>
<details>
  <summary><b>5. Install MongoDB</b></summary>
  
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
  4. Set MongoDB as a Ubuntu service
      ```bash
      sudo service mongod start
      ```
</details>
<details>
  <summary><b>6. Install App</b></summary>
  
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
      # Init packrat:
      packrat::init()
      ```
</details>
<details>
  <summary><b>7. Database creation and configuration</b></summary>
  
   Before using the application, you have to create a MongoDB database with two collections to import your texts there. I recommend you to use a new database with two collections, where you should import your texts. The following steps show you the process:
  1. Enter to MongoDB
      ```bash
      mongo
      ```
  2. Create database "db_name". This is just a name example, you can use the name you want.
      ```js
      use db_name
      ```
  3.  Create the "text_collection" and "user_collection" collections, which will contain your texts and annotations and your annotators data respectively.
      ```js
      db.createCollection("text_collection")
      db.createCollection("user_collection")
      # exit
      quit()
      ```
  4. Import your texts. To show the process, we are going to import the file present on the "testing_data" folder of the app. This is done in Ubuntu bash. Note that you need to name your column with texts as "text", otherwise the application will crash.
     ```bash
     cd /srv/shiny-server/noytext/testing_data/
     mongoimport --db db_name --collection text_collection --type CSV --headerline --file "test_text.csv"
     ```
   The general command to import a csv is:

   *mongoimport --db db_name --collection "your_text_collection_name" --type CSV --headerline --file "path_to_your_csv_file"*

  **I repeat that is very important to have the column of the texts named as "text", otherwise the application will not work.**
    
</details>


## Configuration
To configure the graphical interface of Noytext you must modify the .txt files present in the path *noytext/config_files/*. These files use the "::" symbol as a separator, so you cannot use that symbol in your texts. On the other hand, you should not put quotation marks in these documents because it could cause problems when reading the lines.


|      File name     |               Configure...              |
|:------------------:|:---------------------------------------:|
| `GeneralUI_conf.txt` | ...the elements of the graphical interface |
| `HelpTexts_conf.txt` |     ...the helpers from the tab "help"     |
|  `MongoDB_conf.txt`  |    ...your MongoDB connection parameters   |
|   `Survey_conf.txt`  |            ...your questionaire            |

<details><summary><b>GeneralUI_conf.txt parameters</b></summary>

Noytext currently has 4 tabs (information, help, label and about). You can hide all of them, except the one used to annotate texts (label).The first element of each line represents the element you are going to modify. This file consists on 6 configuration lines:

**1. Title:**

   It allow you to specify the name of your project/app. i.e:
    
    Title:Annotation for soundscapes
  
**2. Information:**
    
   It allow you to define the name of the introduction tab of your app, as well as if you want to show it and the file name of the html  that you are using for this purpose. The file must be placed at the root of the project. i.e:

   a. To hide this tab:
      
      Information:Introduction to scoundscapes:FALSE:intro.html

   b. To show this tab:
      
      Information:Introduction to scoundscapes:TRUE:intro.html

**3. Help:**
    
   It allow you to define the name of the help tab, as well as if you want to show it or no.i.e:
  
   a. To hide this tab: 
   
    Information:Introduction to scoundscapes:FALSE
     
   b. To show this tab:
   
    Information:Introduction to scoundscapes:TRUE
   
**4. Label:**
  
   Change the title of the label tab.i.e:
   
    Label:Help us to annotate
  
**5. About:**

   It allow you to define the name of the about tab of your app, as well as if you want to show it and the file name of the html  that you are using for this purpose. The file must be placed at the root of the project. i.e:

   a. To hide this tab: 
    
    About:Our team:FALSE:index.html

   b. To show this tab:
    
    About:Our team:TRUE:index.html
  
**6. Shinydasboad appearance:**
  
   You can use shinythemes constans to change the color and style of the NavBar. This values can be found on https://rstudio.github.io/shinythemes/ .i.e:
   
    Shinydasboard_appearance:sandstone
   
</details>



<details><summary><b>HelpTexts_conf.txt parameters</b></summary>

  This file allow you to change the helpers file from the tab help. You can use most of the html tags in the definition (I did not check all of them). Currently, you only can define the 4 sentences that will be shown in each step of this tab.

  The first element of each line represents the element you are going to modify. i.e:

  ```
  HELP1:<h3>This is the first helper with a h3 tag</h3>
  HELP2:<b> You can use bold tag </b>
  HELP3:You can write plain text
  HELP4:<h3>This is the last helper, you cannot add more</h3>
  ```

</details>



<details><summary><b>MongoDB_conf.txt parameters</b></summary>

   Here you can define your connection URL, database port, name, and collections. If you want to register user data, besides the text collection you will need to create a collection for this purpose (it was created in the installation guide). The file configures a localhost URL and the port 27017 by default, this is the standard configuration required to access MongoDB from the app in an Ubuntu instance. 
  
  ```
  ConnectionURL:localhost
  ConnectionPORT:27017
  DatabaseNAME:db_name
  CollectionTextNAME:text_collection
  CollectionUsersNAME:user_collection
  ```

  On the other hand, you can set in this file the number of times you need a text be annotated by different users:
  
  ```
  num_annotations_text:3
  ```
</details>


<details><summary><b>Survey_conf.txt parameters</b></summary>
  
  1. This file allows you to define if you need to show a survey to annotators the first time they log in. i.e:
  
      a. To show survey and user login: 

          SurveyNeeded:TRUE

      b. To hide survey and user login:

          SurveyNeeded:FALSE

  2. If you decide to show the survey to your users, you have to define de number of questions the survey will have:
  
    NumberQuestions:10


  3. Define the questions you need:
              UNDER CONSTRUCTION

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
I developed this tool while I was a PhD student at [Instrumentation and Applied Acoustics Research Group (I2A2 Group)](http://www.i2a2.upm.es/) of [Universidad Politécnica de Madrid](http://www.upm.es/). Part of this code was developed while I was doing a research stay at [Télecom Paristech](https://www.telecom-paristech.fr/).


<div align="center"><a href="http://www.i2a2.upm.es/"> <img src="https://github.com/luisgasco/noytext/blob/master/www/img/logo_notext.jpg" alt="I2A2"	width="auto" height="100" align="middle" /></a> <a href="http://www.upm.es/"><img src="https://github.com/luisgasco/noytext/blob/master/www/img/logo2.jpg" alt="UPM"	width="auto" height="100" align="middle" /></a> <a href="https://www.telecom-paristech.fr/"> <img src="https://github.com/luisgasco/noytext/blob/master/www/img/logo_telecom.png" alt="TELECOM"	width="auto" height="100" align="middle" /></a> </div>


## License

AGPL-3.0


## You may also like...

- [Ropensky](https://github.com/luisgasco/Ropensky) - R library to get data from OpenSky Network API.

---

> [luisgasco.es](http://luisgasco.es/) &nbsp;&middot;&nbsp;
> GitHub [@luisgasco](https://github.com/luisgasco) &nbsp;&middot;&nbsp;
> Twitter [@luisgasco](https://twitter.com/luisgasco)
> Facebook [Luis Gascó Sánchez page](https://www.facebook.com/Luis-Gasco-Sanchez-165003227504667)
