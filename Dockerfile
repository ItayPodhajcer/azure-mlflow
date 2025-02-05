ARG MLFLOW_VERSION="latest"
FROM ghcr.io/mlflow/mlflow:${MLFLOW_VERSION}

RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc

RUN pip install pyodbc

ENTRYPOINT [ "mlflow" ]

CMD [ "server", "--host", "0.0.0.0", "--port", "5000" ]