cd RustServer

:start
RustDedicated.exe -batchmode -nographics -logFile Log.txt +server.identity "example" +oxide.directory "server/example/oxide/"
timeout /t 10 /nobreak
goto start