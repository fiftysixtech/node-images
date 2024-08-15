## Installing Docker and Docker Compose on macOS

To run Fiftysix blockchain node images on macOS, you need to install Docker and Docker Compose. The following guide provides step-by-step instructions for installing both on the latest version of macOS.

### macOS - Installing Docker and Docker Compose

1. **Download Docker Desktop for Mac**
   - Visit the [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop) download page.
   - Click the "Download for Mac (Apple silicon or Intel chip)" button depending on your Mac's hardware.

2. **Install Docker Desktop**
   - Open the downloaded `.dmg` file.
   - Drag the Docker icon to the Applications folder.
   - Open Docker from your Applications folder.

3. **Grant Required Permissions**
   - Upon first launch, Docker will ask for permissions to access system files. Approve these requests.
   - You may also need to enter your system password to allow the installation to proceed.

4. **Verify Docker Installation**
   - Open a terminal and run the following command to verify that Docker is installed correctly:
   ```bash
   docker --version
   ```
   - You should see a version number in the output, confirming that Docker is installed.

5. **Start Docker Desktop**
   - Docker Desktop should start automatically after installation. You can also start it manually by finding Docker in your Applications and opening it.

6. **Enable Docker Compose**
   - Docker Desktop includes Docker Compose by default. You can verify its installation by running:
   ```bash
   docker-compose --version
   ```
   - The output should show the Docker Compose version, confirming it is ready to use.

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
