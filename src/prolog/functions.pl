:- use_module(events).
:- use_module(java_connection_functions).

:- use_module(library(lists)).
:- use_module(library(random)).
 
/*
* Konstanten fuer die Berechnungen
*/

latInKm(X, Res) :-
	Res is X * 111.66.

lonInKm(X, Res) :-
	Res is X * 19.39.

/*----------------------------------------------------------------------------------------------*/

/*
* Sucht alle Kategorien f�r Events
*/
findAllCategories(Categories):-
	findall(X, event(_,_,X,_,_,_,_), L),
	mergeListOfListsToList(C1,L),
	Categories = C1.

/*
* Sucht alle Kategorien f�r Restaurants, Imbisse ...
*/
findAllFoodCategories(Categories):-
	findall(X, event(_,_,_,X,_,_,_), L),
	mergeListOfListsToList(C1,L),
	Categories = C1.
	
/*
* Sucht alle Kategorien der Hotels
*/
findAllHotelCategories(Categories):-
	findall(X, hotel(_,_,_,X), L),
	mergeListOfListsToList(C1,L),
	Categories = C1.

/*----------------------------------------------------------------------------------------------*/

/*
* Berechnet die Entfernung zwischen zwei Veranstaltungen
* Entfernung = sqrt((XA-XB)^2 + (YA-YB)^2)
* calcDistance(Name Veranstaltung A, Name Veranstaltung B, Entfernung
*/	
calcDistance(EventA, EventB, Distance) :-
	(
		event(EventA, [XA, YA], _, _, _, _, _)
		;
		hotel(EventA, [XA, YA], _, _)	
	),
		(
		event(EventB, [XB, YB],  _, _, _, _, _)
		;
		hotel(EventB, [XB, YB],  _, _)	
	),
	latInKm(XA, XAinKm),
	latInKm(XB, XBinKm),
	lonInKm(YA, YAinKm),
	lonInKm(YB, YBinKm), 
	TempX is XAinKm - XBinKm,
	TempY is YAinKm - YBinKm,
	PotX is TempX * TempX,
	PotY is TempY * TempY,
	AddBoth is PotX + PotY,
	Distance is sqrt(AddBoth).

/*----------------------------------------------------------------------------------------------*/

/*
* Gibt die m�glichen Events zu den Kategorien zur�ck, wenn Events leer
*/
searchEventsOnCategory(Categories,Events):-
	findall([X,V], event(X,_,V, _, _,_,_), List),
	compareCategories(List,Categories,Events1),
	Events = Events1.
	
/*
* Gibt m�gliche Hotels zu den Kategorien zur�ck
*/
searchHotelsOnCategory(Categories,Hotels):-
	findall([X,V], hotel(X,_,_,V), List),
	compareCategories(List,Categories,Hotels1),
	Hotels = Hotels1.

/*
* Vergleicht die Liste der Kategorien mit der �bergebenen Liste
*/	
compareCategories([E|L],Categories,List1):-
	compareCategories(L,Categories,List2),
	E = [X,Y],
	(  compare_list(Y,Categories)
	-> (
		append([X],List2,List3),
	   	List1 = List3
	   )
	   ;
	   (
	   	List1 = List2
	   )	
	).
	
compareCategories([],_,List1):-
	List1 = [].


/*----------------------------------------------------------------------------------------------*/


/*
*Pr�ft f�r alle Events der Liste ob sie einzeln nicht zu teuer sind und gibt die zur�ck die 
*Preislich in das Budget nicht �bersteigen
*Persons = [Count of Adult, Count of Reduced]
*Budget = Price in cent
*MyEvents = ['EventA', 'EventB' ..]
*ValidEvents = empty Atom -> becomes List of valid events
*/
checkEventsForBudget(Persons,Budget,MyEvents,ValidEvents):-
	checkEventForBudget(Persons,Budget,MyEvents,ValidEvents1),
	ValidEvents = ValidEvents1.

checkEventForBudget(_,_,[],ValidEvents):-
	ValidEvents = [].
	
checkEventForBudget(Persons,Budget,[Event|MyEvents],ValidEvents):-
	checkEventForBudget(Persons,Budget,MyEvents,ValidEvents1),
	((
		event(Event,_,_,_,[AdultPrice,ReducedPrice],_,_),
		[AdultCount|ReducedCount] = Persons,
		Price is (AdultCount*AdultPrice)+(ReducedCount*ReducedPrice),
		write(Price), nl,
		Budget >= Price,		
		append([Event],ValidEvents1,ValidEvents2),
		ValidEvents = ValidEvents2
	)
	;
	(
		ValidEvents = ValidEvents1
	)).

/*
*searchUsefulEvents
*/
searchUsefulEvents(Persons, Budget, Categories, UsefulEvents):-
	searchEventsOnCategory(Categories, Events1),
	checkEventsForBudget(Persons,Budget,Events1,ValidEvents),
	UsefulEvents = ValidEvents.




/*----------------------------------------------------------------------------------------------*/


/*
�berpr�ft die gesamte Timeline
checkEventsOnTime(Persons,[Eventlist] ,DayStart, DayEnd, Hotel, HotelCategorie, Budget, Return, Price):-
Persons = Personen = [X,Y] = [Anzahl Erwachsene, Anzahl Erm��igte]
Eventlist = Eventliste = [Event1, Event2, .., EventX] 
	EventX = [Name des Events, Tag, Startzeit, Dauer, Anfahrt]
Daystart = Startuhrzeit des Tages
Hotel = Name des Hotels
HotelCategorie = Kategorie/nwunsch des Nutzers (wird nur beachtet, wenn kein Hotel angegeben)
Budget = Maximales Budget
Return = R�ckgabewert wird true oder false
Price = Gesamtpreis der Tour

Beispiel:
trace, 
checkEventsOnTime([1,2], 
[
['Cinestar', 1, 1100, 100, 'Car'],
['Fachhochschule Stralsund', 1, 1700, 100, 'Car'],
['Marinemuseum', 2, 700, 100, 'Car'],
['Nautineum', 1, 900, 100, 'Car'], 
['Meeresmuseum', 2, 1100, 100, 'Car'],
['Ozeaneum', 2, 1700, 100, 'Car'],
['Citti', 1, 700, 100, 'Car'],
['Strelapark', 2, 900, 100, 'Car']
], 
500, 2200, 'X Sterne Hotel', _, 
10000000, Return, Price).

*/

checkEventsOnTime(Persons, EventList, DayStart, DayEnd, Hotel, HotelCategorie, Budget, Return, Price):-
	sortEventList(EventList,SortedEventList),
	((
		nonvar(Hotel)
	)
	;
	(
		var(Hotel),
		findHotelsForTrip(HotelCategorie, Hotel1), 
		Hotel = Hotel1
	)),
	checkTimeLine(Persons, SortedEventList, DayStart, DayEnd, Hotel, Budget, Return1, Price1),
	Return = Return1,
	Price = Price1.	


/*
checkTimeLine(Persons,[Eventlist] ,DayStart, Hotel, Budget, Return, Price):-
Persons = Personen = [X,Y] = [Anzahl Erwachsene, Anzahl Erm��igte]
Eventlist = Eventliste = [Event1, Event2, .., EventX] 
	EventX = [Name des Events, Tag, Startzeit, Dauer, Anfahrt]
Daystart = Startuhrzeit des Tages
DayEnd = Uhrzeit des Tagesendes
Hotel = Name des Hotels
Budget = Maximales Budget
Return = R�ckgabewert wird true oder false
Price = Gesamtpreis der Tour

Beispiel positiv an einem Tag:
checkTimeLine([1,2], [['Haus 8',1,1030,100,'Car'],['Zoo',1,1230,100,'Car']],800, 2200, 'X Sterne Hotel', 1000000, Return, Price).
Beispiel positiv an 2 Tagen:
checkTimeLine([1,2],[['Haus 8',1,1030,100,'Car'],['Zoo',2,1030,100,'Car']],800, 2200, '1 Sterne Hotel', 100000, Return, Price).
Beispiel positiv an 2 Tagen:
checkTimeLine([1,2],[['Haus 8',1,930,100,'Car'],['Meeresmuseum',2,930,100,'Car'],['Zoo',2,1100,100,'Car']], 800, 2200, '2 Sterne Hotel', 100000, Return, Price).

Beispiel negativ an einem Tag:
checkTimeLine([1,2],[['Haus 8',1,1030,100,'Car'],['Zoo',1,1130,100,'Car']],800, 2200, '1 Sterne Hotel', 100000, Return, Price).
Beispiel negativ an einem Tag:
checkTimeLine([1,2], [['Haus 8',1,830,100,'Car'],['Zoo',1,1230,100,'Car']],800, 2200, 'X Sterne Hotel', 1000000, Return, Price).
Beispiel negativ an 2 Tagen weil letztes Event zu lange:
checkTimeLine([1,2],[['Haus 8',1,830,100,'Car'],['Zoo',2,2130,100,'Car']],800, 2200, '1 Sterne Hotel', 100000, Return, Price).
Beispiel negativ an 2 Tagen:
checkTimeLine([1,2],[['Haus 8',1,830,100,'Car'],['Haus 8',2,830,100,'Car'],['Zoo',2,930,100,'Car']],800, 2200, '1 Sterne Hotel', 100000, Return, Price).
Beispiel negativ an 2 Tagen weil zu fr�h begonnen:
checkTimeLine([1,2],[['Haus 8',1,830,100,'Car'],['Haus 8',2,830,100,'Car'],['Zoo',2,930,100,'Car']],830, 2200, '1 Sterne Hotelm', 100000, Return, Price).
Beispiel negativ an 2 Tagen weil Budget zu gering:
checkTimeLine([1,2],[['Haus 8',1,830,100,'Car'],['Haus 8',2,830,100,'Car'],['Zoo',2,1030,100,'Car']],800, 2200, '1 Sterne Hotel', 450000, Return, Price).
*/ 


/*
Kalkuliert: 
- Hotel vor dem ersten Event
- Anfahrt zum ersten Event
- Das erste Event
*/
checkTimeLine(Persons,[EventHead|EventsTail],DayStart, DayEnd, Hotel, Budget, Return, Price):-
	(
			write('Pr�fe Event ohne Vorg�nger'), nl,
		calcHotelPrice(Persons, Hotel, HotelPrice),
		[ThisEvent,_,EventStartTime,EventTime,Vehicle] = EventHead,
			write(Hotel + " zu " + ThisEvent), nl,
		calcApproachForEvent(Persons, _, ThisEvent, Hotel, Vehicle, EventStartTime, [_,_,_,RealStartTime,Price1]),
		calcEventPrice(Persons, ThisEvent, Price2),
			write("Startzeit des Tages: "+DayStart), nl,
			write("Startzeit: "+RealStartTime), nl,
		RealStartTime >= DayStart,
		Price3 is Price1 + Price2 + HotelPrice,
		Budget >= Price3,
		checkBussinesHours(ThisEvent, EventStartTime, EventTime),
			write("Event g�ltig"), nl,
		checkTimeLine(Persons, EventHead, EventsTail, DayStart, DayEnd, Hotel, Budget, Return1, Price4),
			write("Price3 " + Price3 + " Price4 " + Price4), nl,
		Price is Price3 + Price4,
			write("Entg�ltiger Gesamtpreis: "+ Price), nl,
		Return = Return1,
		Budget >= Price
	)
	;
	(
			write("Event ung�ltig"), nl,
		Price = 0,
		Return = false,!
	).
/*
Kalkuliert: 
- Anfahrt zum ersten Event
- das n�chste Event
*/	
checkTimeLine(Persons, PrevEventInput,[EventHead|EventsTail],DayStart, DayEnd, Hotel,Budget, Return, Price):-
	(
			write('Pr�fe Event mit Vorg�nger'), nl,
		[ThisEvent,Day,EventStartTime,EventTime,Vehicle] = EventHead,
		[PrevEvent,PrevDay,PrevEventStartTime,PrevEventTime,_] = PrevEventInput,
			write("Pr�fe " + PrevEvent + " und " + ThisEvent), nl,
		((
			PrevDay \= Day,
				write("Events an unterschiedlichen Tagen"), nl,
				write("checkTimeLine f�r Vorg�ngertag start"), nl,
			checkTimeLine(Persons, PrevEventInput, [], _, DayEnd, Hotel, Budget, Return1, Price1a),
				write("checkTimeLine f�r Vorg�ngertag beendet"), nl,
			calcApproachForEvent(Persons, _, ThisEvent, Hotel, Vehicle, EventStartTime, [_,_,_,RealStartTime,Price1b]),
				write("Price1a " + Price1a + " Price1b " + Price1b), nl,
			Price1 is Price1a + Price1b,
				write("Startzeit des Tages: "+DayStart), nl,
				write("Startzeit: "+RealStartTime), nl,
			RealStartTime >= DayStart			
		)
		;
		(
			PrevDay = Day,
				write("Events an selben Tag"), nl,
				write(PrevEvent + "zu" + ThisEvent), nl,
			calcApproachForEvent(Persons, PrevEvent, ThisEvent, Hotel, Vehicle, EventStartTime, [_,_,_,RealStartTime,Price1]),
			PrevEventEndTime is PrevEventStartTime+PrevEventTime,
				write("Ende des letzten Events: "+PrevEventEndTime), nl,
				write("Startzeit: "+RealStartTime), nl,
			RealStartTime >= PrevEventEndTime		
		)),
			write("checkTimeLine 3"), nl,
		checkTimeLine(Persons, EventHead, EventsTail, DayStart, DayEnd, Hotel,Budget, Return1, Price2),
		Return = Return1,
		calcEventPrice(Persons, ThisEvent, Price3),
			write("Price1 " + Price1 + " Price2 " + Price2 +" Price3 " + Price3), nl,
		Price is Price3 + Price2 + Price1,
			write("Gesamtpreis bis hier: "+Price), nl,
		Budget >= Price,
		checkBussinesHours(ThisEvent, EventStartTime, EventTime),
			write("Event g�ltig"), nl
	)
	;
	(
			write("Event ung�ltig"), nl,
		Price = 0,
		Return = false,!
	).

/*
Kalkuliert: 
- Hotel nach dem letzten Event des Tages
- Anfahrt zum letzten Event des Tages
- Das letzten Event des Tages
*/
checkTimeLine(Persons, PrevEventInput, [], _, DayEnd, Hotel, Budget, Return, Price):-
		nl, write('Letztes Event des Tages wird gepr�ft'), nl,
	((
		[PrevEvent, _, PrevEventStartTime, PrevEventTime, Vehicle] = PrevEventInput,
			write("Kalkuliere letztes Event und Hotel: "+ PrevEvent), nl, 
		calcApproachForEvent(Persons, PrevEvent, _, Hotel, Vehicle, PrevEventStartTime, [_,_,DriveTime,_,Price1]),
		RealEndTime is PrevEventStartTime + PrevEventTime + DriveTime,
			write("Tagesende nach Events um: "+ RealEndTime), nl,
		RealEndTime =< DayEnd,
		calcHotelPrice(Persons, Hotel, HotelPrice),
		Price is Price1 + HotelPrice,
		Price < Budget,
			write('Letztes Event des Tages g�ltig'), nl,
		checkBussinesHours(PrevEvent, PrevEventStartTime, PrevEventTime),
		Return = true
	)
	;
	(
		Return = false,
		Price is 0,
			write('Letztes Event des Tages ung�ltig'), nl
	)).


/*----------------------------------------------------------------------------------------------*/




/*----------------------------------------------------------------------------------------------*/
	
/*
*calcApproachlForEvent
*Berechnet die Anfahrt zum Event
Previousvent = vorheriges Event
ThisEvent = Event zu dem die Anfahrt berechnet wird
Hotel = Das Hotel des Nutzers
Vehicle = Fahrzeug 
EventTime = Startzeit des ThisEvent
Arrivel wird zur�ckgegeben (Arrival = ('Anfahrt', Vehicle, Zeit in Minuten, Startzeit)
*Wenn PreviousEvent (vorheriges Event) leer, dann wird Hotel genommen.
*Beispiel: calcArrivalForEvent('Cinestar', 'Haus 8', 'Hansedom', 'Car', 800, Arrival).
*/
calcApproachForEvent([AdultCount,ReducedCount], PreviousEvent, ThisEvent, Hotel, Vehicle, EventTime, Approach):-
	((
		nonvar(PreviousEvent),
		Point1 = PreviousEvent
			% ,
			% write('Kalkuliere von PreviousEvent ')
	)
	;
	(
		var(PreviousEvent),
		Point1 = Hotel
			% ,
			% write('Kalkuliere von Hotel ')
	)),
	((
		nonvar(ThisEvent),
		Point2 = ThisEvent
			% ,
			% write('zu ThisEvent'), nl
	)
	;
	(
		var(ThisEvent),
		Point2 = Hotel
			% ,
			% write('zu Hotel'), nl
	)),
	calcDistance(Point1, Point2, Distance),
	vehicle(Vehicle, [AdultPrice,ReducedPrice], Speed),
	ArrivalTime is ceiling(Distance/Speed*60),
		% write("Zeit f�r Anfahrt: "+ ArrivalTime), nl,
	StartTime is EventTime - ArrivalTime,
	Price is (AdultCount*AdultPrice)+(ReducedCount*ReducedPrice),
		% write("-> Preis f�r Fahrt: "+Price), nl,
	Approach = ['Anfahrt', Vehicle, ArrivalTime, StartTime, Price].


/*----------------------------------------------------------------------------------------------*/


/*calcEventPrice
calcEventPrice(Persons, Price1, Price2, Event, Price),
Berechnet Preis f�r Event mit Anfahrt incl. 2 weiterer Preise
Genutzt werden Price1 und Price2 f�r die Berechnung in der �berpr�fung der Timeline
*/
calcEventPrice([AdultCount,ReducedCount], Event, Price):-
		write("Berechne Preis f�r "+Event), nl,
	event(Event,_,_,_,[AdultPrice,ReducedPrice],_,_),
	Price is (AdultCount*AdultPrice) + (ReducedCount*ReducedPrice),
		write("-> Preis f�r " + Event + " ist: " + Price), nl. 
	

/*
Berechnet den Preis f�r das Hotel
In Abh�ngigkeit der Personen und der ben�tigten Doppelzimmer
*/
calcHotelPrice(Persons, Hotel, Price):-
	hotel(Hotel,_,PricePerRoom,_),
	[Adult,Reduced] = Persons,
	PersonsCount = Adult + Reduced,
	Rooms is ceiling(PersonsCount/2),
	HotelPrice is Rooms * PricePerRoom,
		write("-> Preis f�r Hotel f�r diese Nacht: " + HotelPrice), nl,
	Price is HotelPrice.

/*----------------------------------------------------------------------------------------------*/

	
/*
Findet Hotels zur angegebenen Categorie
*/
findHotelsForTrip(HotelCategorie, Hotel1, Budget, Persons):-
	findall([X,V], hotel(X,_,_,V), List),
	compareCategoriesAndBudget(List,HotelCategorie,Budget,Persons,Hotels),
	Hotels = [Hotel1|_].

/*
* findHotelsForTrip([3], Hotel1, 10, [2,2]).
* findHotelsForTrip([5], Hotel1, 10000000, [2,0]).
* Vergleicht die Liste der Kategorien & Budget mit der �bergebenen Liste
*/	
compareCategoriesAndBudget([E|L],Categories,Budget,Persons,List1):-
	compareCategoriesAndBudget(L,Categories,Budget,Persons,List2),
	E = [X,Y],
	((
	
		calcHotelPrice(Persons, X, Price),
		compare_list(Y,Categories), 
		Price  =< Budget)
	-> (
		append([X],List2,List3),
	   	List1 = List3
	   )
	   ;
	   (
	   	List1 = List2
	   )	
	).
	
compareCategoriesAndBudget([],_,_,_,List1):-
	List1 = [].
	
/*
Findet Restaurant passend zur Gruppe
findRestaurant(['Fast-Food'], Restaurant, [1200,1500]).
*/
findRestaurant(FoodCategories, Restaurant,[Starting,Ending]):-
 
	findall([Name,Cat,[Start,End]], event(Name,_,_,Cat,_,[Start,End],_), List),
	compareRestaurants(List,FoodCategories,[Starting,Ending],Restaurants),
	Restaurants = [Restaurant|_].
	
compareRestaurants([E|L],FoodCategories,[Start,End],List1):-
	compareRestaurants(L,FoodCategories,[Start,End],List2),
	E = [Name,Cat,[Opening,Closing]],
	((
	
		compare_list(Cat,FoodCategories), 
		Opening =< Start,
		Duration is Start + 60,
		Duration =< Closing 
		)
	-> (
		append([Name, [Start,Duration]],List2,List3),
	   	List1 = List3
	   )
	   ;
	   (
	   	List1 = List2
	   )	
	).
	
compareRestaurants([],_,_,List1):-
	List1 = [].
/*
Pr�ft die �ffnungszeiten
*/
checkBussinesHours(ThisEvent, EventStartTime, EventTime):-
	event(ThisEvent,_,_,_,_,[Opening, Closing],_),
	EventStartTime >= Opening,
	EventEndTime is EventStartTime + EventTime,
	EventEndTime =< Closing.

	
	

/*----------------------------------------------------------------------------------------------*/	
/* Mehrfachverwendbare Hilfsfunktionen*/

mergeListOfListsToList(C1,[R|[]]):-
		C1 = R.
	
mergeListOfListsToList(C,[R|L]):-
	mergeListOfListsToList(C1,L),
	append(C1,R,X),
	C = X.
	
/*
* compare_list vergleicht ob mindestens ein Member einer Liste in der anderen Liste ist
*/
compare_list([],[]):-false.
compare_list([],_):-false.
compare_list([L1Head|L1Tail], List2):-
    (member(L1Head,List2)
    )
    ;
    (compare_list(L1Tail,List2)
    ).




/*
Abfolge f�r das Trennen und Sortieren der Eventliste
sortEventList([
['E1_1', 1, 1000, 100, 'Car'],
['E1_2', 1, 1700, 100, 'Car'],
['E2_1', 2, 700, 100, 'Car'],
['E1_3', 1, 900, 100, 'Car'], 
['E2_2', 2, 1000, 100, 'Car'],
['E2_3', 2, 1700, 100, 'Car'],
['E1_4', 1, 700, 100, 'Car'],
['E2_4', 2, 900, 100, 'Car']], 
SortedEventList).

*/
sortEventList(EventList,SortedEventList):-
	splitList(EventList,1,UnsortedDay1,UnsortedDay2),
	quickSort(UnsortedDay1, SortedDay1),
	quickSort(UnsortedDay2, SortedDay2),
	append(SortedDay1, SortedDay2, SortedEventList1),
	SortedEventList = SortedEventList1.


/*
Teilt die Liste in jeweils eine Liste pro Tag auf
Funktioniert nur bei 2 Tagen
splitList([['E1_1', 1, 1000, 100, 'Car'],['E2_2', 2, 900, 100, 'Car'],['E1_2', 2, 1200, 200, 'Car'],['E2_1', 2, 1300, 100, 'Car'],['E1_2', 1, 1200, 100, 'Car'],['E2_1', 2, 2100, 100, 'Car']], 1, List1, List2).
*/

splitList([], _, [], []).
	
splitList([Head|Rest], A, [Head|Rest1], Rest2) :-
	[_, A, _, _, _] = Head,
    	splitList(Rest, A, Rest1, Rest2).
    	
splitList([Head|Rest], B, Rest1, [Head|Rest2]) :-
	[_, A, _, _, _] = Head,
        A =\= B,
        splitList(Rest, B, Rest1, Rest2).


/*
Sortiert die Liste der Events
quickSort([['E1_1', 1, 1000, 100, 'Car'],['E1_2', 1, 1700, 100, 'Car'],['E1_2', 1, 700, 100, 'Car'],['E1_2', 1, 900, 100, 'Car']], SortedList).
*/
quickSort(List,Sorted):-
	qSort(List,[],Sorted).
	
qSort([],Acc,Acc).

qSort([H|T],Acc,Sorted):-
	pivoting(H,T,L1,L2),
	qSort(L1,Acc,Sorted1),
	qSort(L2,[H|Sorted1],Sorted).
	
pivoting(_,[],[],[]).

pivoting(H,[X|T],[X|L],G):-
	[_, _, XStartTime, _, _] = X,
	[_, _, HStartTime, _, _] = H,
	XStartTime>HStartTime,
	pivoting(H,T,L,G).
	
pivoting(H,[X|T],L,[X|G]):-
	[_, _, XStartTime, _, _] = X,
	[_, _, HStartTime, _, _] = H,
	XStartTime=<HStartTime,
	pivoting(H,T,L,G).
	
calculateFullTimeLine(Persons,Budget,DayStart,DayEnd,Categories,FoodCategories,Hotelcategories,TimeLine,Hotel,Vehicle):-
	
	findHotelsForTrip(Hotelcategories, Hotel1, Budget, Persons),
	calcHotelPrice(Persons, Hotel1, Price),
	Budget1 is Budget - Price,
	Hotel is Hotel1,
	findEvent(Persons,Budget,DayStart,DayEnd,Categories,Event),
	Event = [Name,[Start,Duration],EventPrice],
	Budget2 is Budget1 - Price,
	calcApproachForEvent(Persons, Hotel, Name, Hotel, Vehicle, Start, Approach),
	EventX = [Name, 1, Start, Duration, Approach],
	append(EventX,TimeLine,TimeLine),
	/*Persons = [A,C],
	Kids = true,
	(C=0,
	Kids = false
	)
	*/
	write(TimeLine).
	
% findEvent([2,2],100000, 600,2100,['Einkaufen'],Event).
findEvent(Persons,Budget,Start,End,Categories,Event):-
	findall([Name,Cat,[Adultprice,Childprice],[XStart,XEnd],Duration], event(Name,_,Cat,_,[Adultprice,Childprice],[XStart,XEnd],Duration), List),
	compareEvents(List,Persons,Budget,Start,End,Categories,Events),
	checkEventsForBudget(Persons,Budget,Events,ValidEvents),
	ValidEvents = [Event|_].
	
% compareEvents([
compareEvents([E|L],Persons,Budget,Start,End,Categories,List1):-
	compareEvents(L,Persons,Budget,Start,End,Categories,List2),
	E = [Name,Cat,[AdultPrice,ReducedPrice],[Opening,Closing],Duration],
	Persons = [AdultCount,ReducedCount],
	((
		compare_list(Cat,Categories), 
		Opening =< Start,
		Duration+Start =< Closing,
		End - Start >= Duration
		)
	-> (
	
		Price is (AdultCount*AdultPrice)+(ReducedCount*ReducedPrice),
		append([Name, [Start,Duration],Price],List2,List3),
	   	List1 = List3
	   )
	   ;
	   (
	   	List1 = List2
	   )	
	).
	
compareEvents([],_,_,_,_,_,List1):-
	List1 = [].

 /*
F�llt die bestehende Timeline mit Events
fillTimeLine(Persons, PrevEvent, EventList, DayStart, DayEnd, Hotel, HotelCategorie, Budget, ResultTimeLine, Return, Price)
fillTimeLine(A, B, C, D, E, F , G, H, I, J, K)
A = Persons = [Erwachsene, Kinder]
B = EventCategories
C = PrevEvent = Vorhergehendes Event
D = TimeLine = Restliche Eventliste
E = DayStart = Startzeit des Tages
F = DayEnd = Ende des Tages
G = Hotel = Name des Hotels
H = HotelCategorie = Kategorien des Hotels = ['Kat.Name', ...]
I = Budget = Budget
J = ResultTimeLine = Timeline nach F�llung
K = Return = True oder False
L = Price = Preis der gesamten Tour
trace, fillTimeLine([1,0], ['Bar', 'Freizeit'], _, [['Haus 8',1,1030,100,'Car'],['Zoo',1,1230,100,'Car']],800, 2200, 'X Sterne Hotel', _, 1000000, X, Return, Price).
trace, fillTimeLine([1,0], ['Bar', 'Freizeit'], _, [['Meeresmuseum',1,1030,100,'Car'],['Zoo',1,1230,100,'Car']],800, 2200, 'X Sterne Hotel', _, 1000000, X, Return, Price).

*/
fillTimeLine(Persons, EventCategories, PrevEvent, TimeLine, DayStart, DayEnd, Hotel, HotelCategories, Budget, ResultTimeLine, Return, Price):-
	%checkEventsOnTime(Persons, TimeLine, DayStart, DayEnd, Hotel, HotelCategories, Budget, Return, Price),
	[EventHead|EventsTail] = TimeLine,
	checkRTL(ResultTimeLine, ResultTimeLine1),
	((
		% PrevEvent ist angegeben, damit befindet sich die Schleife mitten im Tag
		nonvar(PrevEvent)
	)
	;
	(
		% kein PrevEvent angegeben, damit befindet sich die Schleife am Anfang des Tages
		var(PrevEvent),
		DayTimeLine = [],
		findFirstEventOfDay(Persons, EventCategories, DayTimeLine, TimeLine, DayStart, DayEnd, Hotel, Budget, ResultTimeLine1, Return, Price)
	)). 
	
/*
Erstellt ein Event f�r den Zeitraum zwischen "Anfang des Tages" bis zum ersten Event
Beispiel: findFirstEventOfDay(Persons, TimeLine, DayStart, DayEnd, Hotel, Budget, ResultTimeLine, Return, Price)
*/
findFirstEventOfDay(Persons, EventCategories, DayTimeLine, TimeLine, DayStart, DayEnd, Hotel, Budget, ResultTimeLine, Return, Price):-
	[EventHead|EventTail] = TimeLine,
	[FirstEvent, FirstDay, FirstStartTime, FirstTime, FirstVehicle] = EventHead,
	calcApproachForEvent(Persons, _, FirstEvent, Hotel, Vehicle, FirstStartTime, [_,_,_,NextRealStartTime,Price1]),
	(
		NextRealStartTime > DayStart,
		findEventForFreeTime(TimeLine, EventCategories, Persons, Budget, Hotel, FirstVehicle, DayStart, NextRealStartTime, Result)
	).
	
findEventForFreeTime(TimeLine, EventCategories, Persons, Budget, Hotel, Vehicle, DayStart, NextRealStartTime, Result):-
	searchEventsOnCategory(EventCategories, Events),
		write(Events), nl,
	searchPossibleEventsOnDuration(DayStart, NextRealStartTime, Hotel, Vehicle, Events, PossibleEventsOnDuration),
		write(PossibleEventsOnDuration), nl, 
		write(Budget + Persons + Vehicle + Hotel + PossibleEventsOnDuration), nl,
	searchPossibleEventsOnBudget(Budget, Persons, Vehicle, Hotel, PossibleEventsOnDuration, PossibleEventsOnBudget),
		write(PossibleEventsOnBudget), nl, 
	searchPossibleEventsOnAdultChildRatio(Persons, PossibleEventsOnBudget, PossibleEventOnAdultChildRatio),
		write(PossibleEventOnAdultChildRatio), nl,
	searchPossibleEventsOnTimeline(PossibleEventOnAdultChildRatio, TimeLine, PossibleEventsOnTimeline),
		write(PossibleEventsOnTimeline), nl,
	shuffleOneResult(PossibleEventsOnTimeline, Result), nl,
		write(Result), nl
	.


/*
Pr�ft ob die Events in der Zeit passen
*/
searchPossibleEventsOnTimeline([], _, PossibleEventsOnTimeline):-
	% write("Ende der Suche"), nl,
	PossibleEventsOnTimeline = [].
			
searchPossibleEventsOnTimeline([EventsHead|EventsTail], Timeline, PossibleEventsOnTimeline):-
	searchPossibleEventsOnTimeline(EventsTail, Timeline, PossibleEventsOnTimeline1),
	write("Suche zu " + EventsHead), nl,	
	searchEventInTimeLine(EventsHead, Timeline, Result),
	(
		(
			%write("Event noch nicht vorhanden"), nl,
			Result = 'false',
			append(PossibleEventsOnTimeline1, [EventsHead], PossibleEventsOnTimeline2)
		)
		;
		(	
			write("Event bereits vorhanden"), nl,
			Result = 'true',
			PossibleEventsOnTimeline2 = PossibleEventsOnTimeline1
		)
	),
	PossibleEventsOnTimeline = PossibleEventsOnTimeline2.

searchEventInTimeLine(_, [], Result):-
	Result = 'false'.
searchEventInTimeLine(Event, [Head|Tail], Result):-
	[EventHead, _, _, _, _] = Head,
	write("Suche f�r " + Event + EventHead), nl,
	((
		write("Vergleiche " + Event + EventHead), nl,
		Event = EventHead,
		Result = 'true',
		write("Ist gleich")
	)
	;
	(
		searchEventInTimeLine(Event, Tail, Result)
	)).

shuffleOneResult([], []).
shuffleOneResult(PossibleEventOnAdultChildRatio, Result) :-
        length(PossibleEventOnAdultChildRatio, Length),
        random(0, Length, Index),
        nth0(Index, PossibleEventOnAdultChildRatio, Result).
	
/*
Pr�ft ob die Events in der Zeit passen
searchPossibleEventOnAdultChildRatio([2,3], ['Hansedom','Meeresmuseum','Zoo','Haus 8'], PossibleEventOnAdultChildRatio)
searchPossibleEventOnAdultChildRatio([2,0], ['Hansedom','Meeresmuseum','Zoo','Haus 8'], PossibleEventOnAdultChildRatio)
compareCategories(['Zoo','Kneipe'], ['Tiere','Museum'],  Result)
compareCategories([['Hansedom',['Tiere','Museum']]], ['Tiere','Museum'],  Result)
compareCategories([['Haus 8',['Bar','Kneipe']]], ['Tiere','Museum'],  Result)
*/
searchPossibleEventsOnAdultChildRatio(_, [], PossibleEventOnAdultChildRatio):-
		% write("Ende der Suche"), nl,
	PossibleEventOnAdultChildRatio = [].
			
searchPossibleEventsOnAdultChildRatio(Persons, [EventsHead|EventsTail], PossibleEventOnAdultChildRatio):-
	searchPossibleEventsOnAdultChildRatio(Persons, EventsTail, PossibleEventOnAdultChildRatio1),
		% write("Pr�fe"), nl,
	[_,Children] = Persons,
	event(EventsHead, _, EventCategories, _, _, _, _),
	(
		(
			Children =\= 0,
			childCategories(ChildList),
			compareCategories([[EventsHead, EventCategories]], ChildList,  Result)
		)
		;
		(
			Children = 0,
			adultCategories(AdultList),
			compareCategories([[EventsHead, EventCategories]], AdultList,  Result)
		)
		
	),
	(
		(
			Result = [],
			PossibleEventOnAdultChildRatio2 = PossibleEventOnAdultChildRatio1
		)
		;
		(
			append(PossibleEventOnAdultChildRatio1, Result, PossibleEventOnAdultChildRatio2)
		)
	),
	PossibleEventOnAdultChildRatio = PossibleEventOnAdultChildRatio2.



/*
Pr�ft ob die Events in der Zeit passen
*/
searchPossibleEventsOnBudget(_, _, _, _, [], PossibleEventsOnBudget):-
	% write("Ende der Suche"), nl,
	PossibleEventsOnBudget = [].
			
searchPossibleEventsOnBudget(Budget, Persons, Vehicle, Hotel, [EventsHead|EventsTail], PossibleEventsOnBudget):-
	% write("SearchOnBudget"), nl,
	% write(EventsHead), nl,
	searchPossibleEventsOnBudget(Budget, Persons, Vehicle, Hotel, EventsTail, PossibleEventsOnBudget1),
	% write("Kalkuliere weiter"), nl,
	calcApproachForEvent([0,0], _, EventsHead, Hotel,  Vehicle, 0,  [_,_,_,_,ApproachPrice]),
	calcEventPrice(Persons, EventsHead, EventPrice),
	(
		(
			% write("Pr�fe auf Budget dass korrekt"), nl,
			FullEventPrice is EventPrice + ApproachPrice,
			Budget >= FullEventPrice,
			append(PossibleEventsOnBudget1, [EventsHead], PossibleEventsOnBudget2)
		)
		;
		(	
			% write("Budget reicht nicht"), nl,
			PossibleEventsOnBudget2 = PossibleEventsOnBudget1
		)
	),
	PossibleEventsOnBudget = PossibleEventsOnBudget2.

/*
Pr�ft ob die Events in der Zeit passen
*/
searchPossibleEventsOnDuration(_, _, _, _, [], PossibleEventsOnDuration):-
	PossibleEventsOnDuration = [].
			
searchPossibleEventsOnDuration(From, To, Hotel, FirstVehicle, [EventsHead|EventsTail], PossibleEventsOnDuration):-
	searchPossibleEventsOnDuration(From, To, Hotel, FirstVehicle, EventsTail, PossibleEventsOnDuration1),
	calcApproachForEvent([0,0], _, EventsHead, Hotel,  FirstVehicle, 0,  [_,_,ApproachTime,_,_]),
	event(EventsHead, _, _, _, _, [Opening, Closing], [EventDuration]),
	write("From: " + From + " To: " + To + " Opening: " + Opening + " Closing: " + Closing), nl,
	(( 	
		Opening >= From,
		Earliest = Opening
		)
		;
		(
		Opening < From,
		Earliest = From
	)),
	(( 	
		Closing >= To,
		Latest = To
		)
		;
		(
		Closing < To,
		Latest = Closing
	)),
	MaxDuration is Latest - Earliest,
	write("MaxDuration: " + MaxDuration + " EventDuration " + EventDuration), nl,
	((
			FullEventDuration is EventDuration + ApproachTime,
			MaxDuration >= FullEventDuration,
			append(PossibleEventsOnDuration1, [EventsHead], PossibleEventsOnDuration2)
		)
		;
		(
			PossibleEventsOnDuration2 = PossibleEventsOnDuration1
	)),
	PossibleEventsOnDuration = PossibleEventsOnDuration2.
		
/*
Pr�ft ob RTL leer oder nicht und gibt leere Liste zur�ck
Beispiel1: checkRTL(ResultTimeLine, ResultTimeLine1)
Beispiel2: checkRTL([], ResultTimeLine1)
*/
checkRTL(ResultTimeLine, ResultTimeLine1):-
	((
		% RTL ist angegeben
		nonvar(ResultTimeLine)
	)
	;
	(
		% RTL ist angegeben
		var(ResultTimeLine),
		ResultTimeLine1 = []
	)).


	