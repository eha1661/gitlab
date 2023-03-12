
# Installation Gitlab using Docker 
## 1. Using Docker Compose 

1. configure environment variable ```$GITLAB_HOME``` pointing to the directory where the configuration, logs, and data files will reside

``` sh 
    export GITLAB_HOME="/home/sfn/docker-volumes/gitlab-server"
```

2. Create Docker Compose which has the configuration of Gitlab and Gitlab-runner set.
    * hosted volume is used to keep data persistent:
        * ```/var/opt/gitlab```	For storing application data.
        * ```/var/log/gitlab```	For storing logs.
        * ```/etc/gitlab```	For storing the GitLab configuration files.
    

3. start Gitlab and gitlab-runner containers
``` sh
docker compose up -d
```

4. add configured external url to your hosts file (linux). 
> get container IP adress
``` sh
docker inspect \
       -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitlab
```
> add the mapping to ```\etc\hosts```
```
...
172.18.0.3  gitlab.example.com
```

## 2. Basic Configuration

1. Get root password and change it in Gitlab console
```
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

## 3. Gitlab-runner Configuration explained
We use the containerized version of gitlab-runner.

To run gitlab-runner inside a Docker container, you need to make sure that the configuration is not lost when the container is restarted.


To make sure that the configuration of gitlab-runner is saved when container is restarted, mount local system vulume to store configurations.


## Next Tasks 
* Install gitlab and configure TLS ( [link1](https://blog.programster.org/dockerized-gitlab-configure-ssl) )

## Resources
[Doc Install Gitlab Docker](https://docs.gitlab.com/ee/install/docker.html)
[Doc Gitlab-Runner](https://docs.gitlab.com/runner/install/docker.html)
