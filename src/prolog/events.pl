:- module('events', [event/4,category/1]).

/*
* Wissensdatenbank
*/

/*
Kategorien
*/

category('Sport').
category('Einkaufen').
category('Hotel').
category('Schwimmen').
category('Sauna').
category('Grosshandel').
category('Freizeit').
category('Bildung').
category('Tiere').
category('Museum').
category('Studium').
category('Unterhaltung').
category('Bar').
category('Kneipe').

/*
* 
* event(Name des Events, Latitude, Longitude, Liste an Kategorien).
*/

event(	'Hansedom', 
	54.320021,
	13.043840,
	[sport,hotel,schwimmen,sauna]).
event(	'Strelapark',
	54.320678,
	13.046984,
	[einkaufen]).
event(	'Citti', 
	54.320071,
	13.047413, 
	[einkaufen,grosshandel]). 
event(	'Ozeaneum',
	54.315509,
	13.097494,
	[freizeit,museum,bildung,tiere]).
event(	'Meeresmuseum',
	54.3123021,
	13.0845551,
	[freizeit,museum,bildung]).
event(	'Nautineum',
	54.305252,
	13.118912,
	[freizeit,museum,bildung]).
event(	'Marinemuseum',
	54.309746,
	13.119041,
	[freizeit,museum,bildung]).
event(	'Fachhochschule Stralsund',
	54.339149,
	13.076232,
	[bildung,studium]).
event(	'Zoo',
	54.319651,
	13.051815,
	[tiere]).
event(	'Cinestar',
	54.311055,
	13.090076,
	[freizeit,unterhaltung]).
event(	'Haus 8',
	54.340094,
	13.076638,
	[bar,kneipe]).
	
businesshours(	'Hansedom',
		[
			[mon, 930, 2100],
			[tue, 930, 2100],
			[wed, 930, 2100],
			[thu, 930, 2100],
			[fri, 930, 2200],
			[sat, 930, 2200],
			[sun, 930, 2100]
		]).