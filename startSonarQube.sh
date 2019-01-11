#!/bin/sh

echo "-----> Making java available"
export PATH=$PATH:/home/vcap/app/.java/bin

echo "-----> Setting database environment variable"
SONARQUBE_POSTGRES_URL=$(echo $VCAP_SERVICES | jq -r '.["google-cloudsql-postgres"][0].credentials.uri')

echo "-----> Setting sonar.properties"
echo "       sonar.web.port=${PORT}"
echo "       sonar.jdbc.url=${SONARQUBE_POSTGRES_URL%?????????????}..."
echo "\n ------- The following properties were automatically created by the buildpack -----\n" >> ./sonar.properties
echo "sonar.web.port=${PORT}\n" >> ./sonar.properties
echo "sonar.jdbc.url=jdbc:${SONARQUBE_POSTGRES_URL}\n" >> ./sonar.properties

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
