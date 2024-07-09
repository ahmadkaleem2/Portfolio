set -e


SHA=$(git rev-parse HEAD)
echo $SHA
sed "s|\${revision}|$(git rev-parse HEAD)|" pom.xml > pom_temp.xml

mvn -f ./pom_temp.xml package

curl -u admin:@Admin123 -T target/student-management-system-$SHA.jar "http://13.57.179.80:8081/artifactory/student/student-$SHA.jar"