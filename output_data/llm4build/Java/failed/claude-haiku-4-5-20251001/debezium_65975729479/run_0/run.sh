./mvnw clean install -B -pl debezium-connector-mysql -am \
  -Pmysql-ci \
  -Dcheckstyle.skip=true \
  -Dformat.skip=true \
  -Dversion.mysql.server=8.0 \
  -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
  -Dmaven.wagon.http.pool=false \
  -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
  -DfailFlakyTests=false \
  -Ddebezium.test.mongo.replica.primary.startup.timeout.seconds=120