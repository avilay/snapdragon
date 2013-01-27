echo 'Deleting existing data in snapdragon db...'
psql -d snapdragon -f $SD_HOME/front-end/scripts/delete.sql

echo 'Adding test data...'
ruby $SD_HOME/front-end/scripts/add_test_data.rb

echo 'Done.'
