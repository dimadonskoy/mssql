# 📦 MS SQL Server Docker Setup

A complete and automated setup to run Microsoft SQL Server 2022 in Docker with persistent data, auto database attach, and Windows-compatible startup script.

---

## 🛠 Features

- 🐳 SQL Server 2022 containerized with Docker
- 🔐 Secure password management via Docker secrets
- 💾 Automatically attaches a `POS` database if available
- 📁 Volume mounts for data, logs, secrets, and backups
- 🧰 Windows batch script for one-click setup
- 📦 Supports `.zip` archive extraction of database files

---

## 📁 Project Structure

```
your-project/
├── backup/                      # SQL Server backup files
├── log/                         # SQL Server log files
├── secrets/                     # Docker secrets directory
│   └── mssql_sa_password.b64    # Base64-encoded SA password
├── sqldata/                     # SQL data files
│   └── sqldata.zip              # Contains .mdf, .ndf, .ldf
├── docker-compose.yml           # Docker Compose configuration
├── setup.bat                    # Windows setup script
└── README.md                    # This file
```

---

## ⚙️ Prerequisites

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- Valid `sqldata.zip` with database files inside `sqldata/`
- Base64-encoded SA password in `secrets/mssql_sa_password.b64`

---

## 🔐 Create SA Password Secret (PowerShell)

```powershell
"YourStrongPassword!" | Out-File -Encoding ascii -NoNewline -FilePath secrets\mssql_sa_password.b64
```

---

## 🚀 Quick Start (Windows)

1. Place your database files in `sqldata/sqldata.zip`
2. Create the password secret file as shown above
3. Run the setup script:

```cmd
run-compose.bat
```

This will:
- Create folders
- Extract the database archive
- Start the container
- Attach the `POS` database (if not already attached)

---

## 🐳 `docker-compose.yml`

```yaml
services:
  mssql:
    container_name: mssql-db
    hostname: mssql-db
    image: mcr.microsoft.com/mssql/server:2022-latest
    restart: always
    environment:
      ACCEPT_EULA: 'Y'
      MSSQL_SA_PASSWORD: /run/secrets/mssql_sa_password
      MSSQL_DATA_DIR: /var/opt/mssql/data
      MSSQL_TCP_PORT: 1433 
    ports: 
      - "1433:1433"
    volumes:
      - ./sqldata:/var/opt/mssql/data
      - ./log:/var/opt/mssql/log
      - ./secrets:/var/opt/mssql/secrets
      - ./backup:/var/opt/mssql/backup
    secrets:
      - mssql_sa_password
    command: >
      /bin/bash -c "
        /opt/mssql/bin/sqlservr & 
        sleep 20 && 
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Verifone@2024!!!' -C -Q \"
        IF DB_ID('POS') IS NULL 
        BEGIN 
          CREATE DATABASE [POS] ON 
            (FILENAME = '/var/opt/mssql/data/POS01.mdf'), 
            (FILENAME = '/var/opt/mssql/data/POS02.ndf'), 
            (FILENAME = '/var/opt/mssql/data/POS03.ndf'), 
            (FILENAME = '/var/opt/mssql/data/POS04.ndf'), 
            (FILENAME = '/var/opt/mssql/data/POS_log.ldf') 
          FOR ATTACH 
        END
        \"
        tail -f /dev/null
      "

secrets:
  mssql_sa_password:
    file: ./secrets/mssql_sa_password.b64
```

---


## 📄 License

MIT — free to use personally or commercially.

---

## 🙌 Credits

- SQL Server Image: [Microsoft Docker Hub](https://hub.docker.com/_/microsoft-mssql-server)
- Script & Compose Template by crooper
- email : crooper22@gmail.com
