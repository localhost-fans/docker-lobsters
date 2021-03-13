#!/bin/sh

# TODO
# This script could use additional logic.

# Install any needed gems. This is useful if you mount
# the project as a volume to /lobsters
# bundle install

# Used for simple logging purposes.
timestamp="date +\"%Y-%m-%d %H:%M:%S\""
alias echo="echo \"$(eval $timestamp) -$@\""

# Get current state of database.
db_version=$(bundle exec rake db:version)
db_status=$?

echo "DB Version: ${db_version}"

# Provision Database.
if [ "$db_status" != "0" ]; then
  echo "Creating database."
  bundle exec rake db:create
  echo "Loading schema."
  bundle exec rake db:schema:load
  echo "Migrating database."
  bundle exec rake db:migrate
  echo "Seeding database."
  bundle exec rake db:seed
elif [ "$db_version" = "Current version: 0" ]; then
  echo "Loading schema."
  bundle exec rake db:schema:load
  echo "Migrating database."
  bundle exec rake db:migrate
  echo "Seeding database."
  bundle exec rake db:seed
else
  echo "Migrating database."
  bundle exec rake db:migrate
fi

# Set out SECRET_KEY_BASE
if [ "$SECRET_KEY_BASE" = "" ]; then
  echo "No SECRET_KEY_BASE provided, generating one now."
  export SECRET_KEY_BASE=$(bundle exec rake secret)
  echo "Your new secret key: $SECRET_KEY_BASE"
fi

# Compile our assets.
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rake assets:precompile
  bundle exec rake assets:clean
fi

# Start the rails application.
bundle exec rails server -b 0.0.0.0
