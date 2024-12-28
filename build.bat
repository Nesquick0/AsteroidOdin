@echo off

if not exist build mkdir build

set game_name=AsteroidOdin.exe

pushd build
odin build ..\src\desktop -out:%game_name% -debug -vet -strict-style
popd

exit /B %errorlevel%