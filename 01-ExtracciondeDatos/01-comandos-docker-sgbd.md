#documentacion de Comandos de contenedores de SGBD

##Contenedores sin Volumen

''' shell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=P@ssw0rd" \
   -p 1433:1433 --name servidorsqlserverDev \
   -d \
   mcr.microsoft.com/mssql/server:2025-latest
   '''

##Comando para creacion de contenedor con id
   ''' shell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=P@ssw0rd" \
   -p 1438:1433 --name servidorsqlserverDev \
   -d \
   bf43
   '''
##Contenedores con volume volumen 
   ''' shell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=P@ssw0rd" \
   -p 1439:1433 --name servidorsqlserverDev2 -v volume-sqlserverdev:/var/opt/mssql \
   -d \
   bf43