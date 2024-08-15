## Installing Docker and Docker Compose on Windows

To run Fiftysix blockchain node images on Windows, Docker and Docker Compose are required. The following guide provides step-by-step instructions for installing both on the latest version of Windows.

### Windows - Installing Docker and Docker Compose

1. **Download Docker Desktop for Windows**
   - Visit the [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop) download page.
   - Click the "Download for Windows" button to download the installer.

2. **Install Docker Desktop**
   - Double-click the downloaded installer to begin the installation process.
   - Follow the prompts in the installation wizard:
     - Agree to the terms.
     - Select the "Use WSL 2 instead of Hyper-V" option if you are on Windows 10 or higher with the WSL 2 backend (recommended for better performance). If you are unsure, you can select the default option.
   - Click "OK" when prompted to enable the WSL 2 feature and install the necessary components.

3. **Set Up WSL 2 (if not already set up)**
   - If you chose to use WSL 2, you may need to set it up by following these steps:
     - Open PowerShell as Administrator.
     - Run the following commands to enable the WSL feature and set WSL 2 as the default version:
       ```powershell
       wsl --install
       wsl --set-default-version 2
       ```
     - Restart your computer if prompted.

4. **Start Docker Desktop**
   - After the installation is complete, Docker Desktop should start automatically. If it doesn’t, you can open Docker Desktop from the Start menu.
   - Docker may ask for your system password to configure the Docker privileges.

5. **Verify Docker Installation**
   - Open PowerShell or Command Prompt and run the following command to verify Docker is installed correctly:
   ```powershell
   docker --version
   ```
   - You should see the Docker version number, confirming that Docker is installed.

6. **Verify Docker Compose Installation**
   - Docker Desktop for Windows includes Docker Compose by default. You can verify its installation by running:
   ```powershell
   docker-compose --version
   ```
   - The output should show the Docker Compose version, confirming it is ready to use.

## Running a Compose File

In order to run a specific compose file, navigate to the directory and run the following command:

```
docker-compose -f <compose-file> up -d
```

Logs can be tracked directly by running:

```
docker logs <container-name>
```
