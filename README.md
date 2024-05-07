# Fiftysix Blockchain Node Images

## Installing Docker and Docker Compose

In order to run Fiftysix blockchain node images, Docker and Docker Compose is required. Below is a guide on how to install both on different operating systems.

### Ubuntu (22.04)

1. **Update Your Package Index**
   ```bash
   sudo apt update
   ```

2. **Install Required Packages**
   To ensure that your APT works with HTTPS:
   ```bash
   sudo apt install apt-transport-https ca-certificates curl software-properties-common
   ```

3. **Add Docker’s Official GPG Key**
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```

5. **Add the Docker Repository**
   ```bash
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   ```

6. **Update Your Package Index** (again after adding new repository)
   ```bash
   sudo apt update
   ```

7. **Install Docker CE (Community Edition)**
   ```bash
   sudo apt install docker-ce
   ```

8. **Verify Installation**
   Verify that Docker is installed correctly by running the Hello World image.
   ```bash
   sudo docker run hello-world
   ```

9. **Manage Docker as a Non-root User** (Optional but recommended)
   If you want to run Docker commands without `sudo`, you need to add your user to the Docker group.
   ```bash
   sudo usermod -aG docker ${USER}
   su - ${USER}
   ```
   You will need to log out and back in for this to take effect.

### Installing Docker Compose

As of Docker Compose version 1.27.0, you can use the Docker CLI plugin.

1. **Download the Latest Version of Docker Compose**
   First, check the current release and replace `<version>` with the version of Compose you want to use (for example, v2.27.0). Latest versions can be found here: [Docker Compose Releases](https://github.com/docker/compose/releases).
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/<version>/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   ```

2. **Set Permissions**
   ```bash
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Verify Installation**
   Check if Docker Compose is installed correctly:
   ```bash
   docker-compose --version
   ```

## Running a Compose File

In order to run a specific compose file, navigate to the directory and run the following command:

```
ln -s <compose-file> docker-compose.yml
```

Then run (you may need to preface this command with `sudo`):

```
docker-compose up -d
```

Logs can be tracked directly by running:

```
docker logs <container-name>
```
