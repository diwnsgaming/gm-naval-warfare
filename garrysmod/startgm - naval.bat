echo off
cls
echo (%time%) SRCDS started.
start /wait C:\srcds\orangebox\srcds.exe -console -game garrysmod +sv_loadingurl "acfnavalwarfare.tumblr.com/" -maxplayers 18 -port 27015 +hostname "[BNI] Poseidon's Realm[Fast-DL]" +map harbor2ocean_nw_2-1_a.bsp +gamemode navalwarfare +host_workshop_collection 137630275 -authkey A1C736676379BADE2887B0B5F843394D
