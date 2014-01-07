# Out of Country Voter Registration

The OCVR tool pre-registers out-of-country voters in order to facilitate resource allocation and improve voter experience in Libyan elections.

## Requirements
- Ruby 1.9.3
- RVM
- Rails 3.2.14
- Postgres

## Installation
```
bundle install
rake db:migrate
foreman rails server
```

Set required environment variables in .env file: 
```
NID_API_USERNAME = voter-api
NID_API_PASSWORD = ****
ADMIN_USERNAME = ****
ADMIN_PASSWORD = ****
SENDGRID_USERNAME=HNEC
SENDGRID_PASSWORD=****
```

## Deployment

On Heroku, uses 2 web dynos, 1 worker, Kappa db, and SSL endpoint. 