#!/bin/sh

echo "-----> Making java available"
export PATH=$PATH:/home/vcap/app/.java/bin

echo "-----> Setting database environment variable"
POSTGRES_CREDENTIALS=$(echo $VCAP_SERVICES | jq --raw-output '.["google-cloudsql-postgres"][0].credentials | {database_name, Username, Password, host}')
POSTGRES_DATABASE_NAME=$(echo $POSTGRES_CREDENTIALS | jq --raw-output '.database_name')
POSTGRES_HOST=$(echo $POSTGRES_CREDENTIALS | jq --raw-output '.host')
POSTGRES_PASSWORD=$(echo $POSTGRES_CREDENTIALS | jq --raw-output '.Password')
POSTGRES_USERNAME=$(echo $POSTGRES_CREDENTIALS | jq --raw-output '.Username')
SONARQUBE_POSTGRES_URL=jdbc:postgresql://$POSTGRES_HOST/$POSTGRES_DATABASE_NAME
echo "-----> Setting sonar.properties"
echo "       sonar.web.port=${PORT}"
echo "       sonar.jdbc.url=${SONARQUBE_POSTGRES_URL}"
echo "       sonar.jdbc.username=${POSTGRES_USERNAME}"
echo "       sonar.jdbc.password=...."
echo "\n ------- The following properties were automatically created by the buildpack -----\n" >> ./sonar.properties
echo "sonar.web.port=${PORT}\n" >> ./sonar.properties
echo "sonar.jdbc.url=${SONARQUBE_POSTGRES_URL}\n" >> ./sonar.properties
echo "sonar.jdbc.username=${POSTGRES_USERNAME}\n" >> ./sonar.properties
echo "sonar.jdbc.password=${POSTGRES_PASSWORD}\n" >> ./sonar.properties

# Replace all environment variables with syntax ${MY_ENV_VAR} with the value
# thanks to https://stackoverflow.com/questions/5274343/replacing-environment-variables-in-a-properties-file
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg; s/\$\{([^}]+)\}//eg' ./sonar.properties > ./sonar_replaced.properties
mv ./sonar_replaced.properties ./sonar.properties

echo "------------------------------------------------------" > /home/vcap/app/sonarqube/logs/sonar.log

echo "-----> Starting SonarQube"

/home/vcap/app/sonarqube/bin/linux-x86-64/sonar.sh start

echo "-----> Tailing log"
sleep 10 # give it a bit of time to create files
cd /home/vcap/app/sonarqube/logs
tail -f ./sonar.log ./es.log ./web.log ./ce.log ./access.log
