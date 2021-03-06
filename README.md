# TCI - Tikal Jenkins-based CI solution

![tci](src/resources/images/tci.png)

### ***TCI - Tikal Jenkins-based CI solution***
Powered by **[Tikal Knowledge](http://www.tikalk.com)** and the community.
<hr/>

With this repository, you can establish 2 kind of TCI Jenkins server types:
* <img src="./src/resources/images/tci-server.png" width="80" height="80"> **tci-server** - for loading a well-established Jenkins server.
* <img src="./src/resources/images/tci-local.png" width="80" height="80"> **tci-local** - for loading a local developement Jenkins environment.(Work in progress)

### ***<img src="./src/resources/images/tci-server.png" width="60" height="60"> tci-server establishment instructions***

In order to establish a <img src="./src/resources/images/tci-server.png" width="60" height="60"> **tci-server**, follow the below instructions on the server you want to host it:

1. Make sure you have the following commands installed: **git**, **docker** & **docker-compose**.
1. Make sure you have an SSH private key file on the hosting server. The default path it looks for is ~/.ssh/id_rsa, but you can configure it to use a different file.
1. clone this repository (git@github.com:TikalCI/tci.git) to a local folder and cd to it.
1. Run _**./tci-server.sh info**_ to see that the path to the SSH private key file is correct. If it is not correct, change it in the generated **environemnts/tci-server/.config** file.
1. Run _**./tci-server.sh start**_ to load the server. 
1. The first load will take at least 10 minutes, so please wait until the prompt is back.
1. Once the load is over, browse to [http://localhost:8080](http://localhost:8080) and login with admin/admin credentials.

Once the server is up, you can modify it (e.g. add LDAP configuration, add seed jobs, add credentials and much more) following the instructions as in [tci-master](https://github.com/TikalCI/tci-master).

The _**./tci-server.sh**_ script have the following actions: **start**, **stop**, **restart**, **info**.

The loaded server is already configured to work with [<img src="./src/resources/images/tci-library.png" width="60" height="60"> tci-library](https://github.com/TikalCI/tci-library) so you can start working with it and<br/>use [<img src="./src/resources/images/tci-pipelines.png" width="60" height="60"> tci-pipelines](https://github.com/TikalCI/tci-pipelines) as a reference as well.

If you want to participate in the TCI project as an active contributor, please refer to [<img src="./src/resources/images/tci-dev.png" width="60" height="60"> tci-dev-env](https://github.com/TikalCI/tci-dev-env).

