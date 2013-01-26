echo 'Deleting existing data in snapdragon db...'
psql -d snapdragon -f $SD_HOME/scripts/delete.sql

echo 'Adding test data...'
ruby $SD_HOME/scripts/add_test_data.rb

echo 'Done.'
