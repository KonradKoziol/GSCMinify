#include common_scripts\utility;#include maps\mp\_utility;#include maps\mp\gametypes\_hud_util;#define WELCOME_MSG=BASE_MSG+GREEN+PROJECT_TITLE;#define RED="^1";#define GREEN="^2";#define BASE_MSG="Infinity Loader | Project: ";#define PROJECT_TITLE="ddd";#ifdef RELEASE#define BUILD="Release Build";#else#ifndef DEBUG#define BUILD="Build type not set";#else#define BUILD="Debug Build";#endif#endif
init(){level thread onPlayerConnect();}
onPlayerConnect(){for(;;){level waittill("connected",player);player thread onPlayerSpawned();}}
onPlayerSpawned(){self endon("disconnect");level endon("game_ended");for(;;){self waittill("spawned_player");if(isDefined(self.playerSpawned))
continue;self.playerSpawned=true;self freezeControls(false);self iprintln(RED+BUILD);self iprintln(WELCOME_MSG);}}