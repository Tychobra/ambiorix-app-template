# Ambiorix Web App Template

### [Live App](https://ambiorix-app-template-kzedhk4g2a-ue.a.run.app)

A starter template for building web apps with an R [Ambiorix](https://ambiorix.dev/docs/ambiorix) backend, 
Postgres Database, and [Solidjs](https://www.solidjs.com/) frontend.

This starter app comes with email link authentication.  Users can sign up or login with an email
and a link will be sent to their email address to authenticate them.  This method of authentication
does not require a password.  We use [Mailgun](https://www.mailgun.com/) to send the emails.

The app comes with an admin panel for managing users.  The admin panel can be extended to handle any
other admin tasks.

### Install JS Dependencies

```terminal
npm install
cd frontend_src && npm install
cd ..
```

### Configure Database and Mailgun Credentials

Create a file named "/app/.env.development" with your database and mailgun credentials.  The file
should look like this:

```.env.development
DB_HOST="<your db host>"
DB_USER="<your db user name>"
DB_PASSWORD="<your db password>"
DB_NAME="<your db name>"

MAILGUN_URL="<your mailgun url>"
MAILGUN_API_KEY="<your mailgun api key>"
APP_URL="http://localhost:8080" # or whatever your app url is
```

### Initialize Database

The following R script will create the database and tables to handle user authentication.

```R
source("data_prep/db_init.R")
```

### Run Locally for Development

```terminal
npm run dev
```

### Build for Production

```terminal
npm run prod
docker build -t ambiorix-app-template .

docker run -p 8080:8080 ambiorix-app-template
```

### Deploy to Google Cloud Run (or anywhere else)

```terminal

# tag image for deployment to GCR (Google Container Registry)
docker tag ambiorix-app-template gcr.io/postgres-db-189513/ambiorix-app-template

# push tagged image to GCR
docker push gcr.io/postgres-db-189513/ambiorix-app-template
```
