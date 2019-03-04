#!/bin/bash

concurrencies="50 100 200 300 400 500"
host="10.0.1.173"
time="900"
now=$(date +"%T")



declare -a tests=( \
	"authenticate/Authenticate_Super_Tenant_User" \
	"oauth/OAuth_AuthCode_Redirect_WithConsent" \
	#"oauth/OAuth_Client_Credentials_Grant" \
	# "oauth/OAuth_Implicit_Redirect_WithConsent" \
	# "oauth/OAuth_Password_Grant" \
	# "oauth/OAuth_Password_Grant_Refresh_Token" \
	# "oauth/OAuth_Password_Grant_Token_Introspection" \
	# "oauth/OAuth_Password_Grant_Token_Revocation" \
	# "oidc/OIDC_AuthCode_Redirect_WithConsent" \
	# "oidc/OIDC_AuthCode_Request_Path_Authenticator_WithConsent" \
	# "oidc/OIDC_Implicit_Redirect_WithConsent" \
	# "oidc/OIDC_Password_Grant" \
	 "saml/SAML2_SSO_Redirect_Binding" \
	)


echo "started the test"

cd /home/ubuntu/performance/apache-jmeter-3.3/bin
./jmeter -n -t /home/ubuntu/performance/performance-is/distribution/scripts/jmeter/setup/TestData_Add_Super_Tenant_Users.jmx -Jhost=$host
echo "users added"
./jmeter -n -t /home/ubuntu/performance/performance-is/distribution/scripts/jmeter/setup/TestData_Add_SAML_Apps.jmx -Jhost=$host
echo "SAML apps added"
cd

for test in ${tests[@]};do
       echo "$test"	
 for concurrency in $concurrencies;do 
    echo $concurrency
    mkdir -p ~/results/"$test"
    ssh -i ~/private.pem ubuntu@$host << ENDSSH
      
      
      echo "Killing All Carbon Servers..."
      sudo killall java

      echo "Deleting all logs..."
      rm -rf ~/wso2is-5.3.0/repository/logs/*
      echo "sleep for 60 s"
      sleep 60
      echo "Starting identity server..."
      sh ~/wso2is-5.3.0/bin/wso2server.sh start 

      echo "Sleeping for 100s..."
      sleep 100

      echo "Finished restarting identity server..."   
    
ENDSSH

    mysql -h wso2isdbinstance2.cd3cwezibdu8.us-east-1.rds.amazonaws.com -u wso2carbon -pwso2carbon < ~/performance/clean-database.sql
    cd /home/ubuntu/performance/apache-jmeter-3.3/bin
    ./jmeter -n -t /home/ubuntu/performance/performance-is/distribution/scripts/jmeter/$test.jmx -Jtime=$time -Jconcurrency=$concurrency -Jhost=$host -Jport=9443 | tee ~/results/"$test"_"$time"_$concurrency.txt
  done
  echo "........one test finished......"
  sleep 300 
done

echo "...........................finish the whole testing............................................................"
