// https://github.com/SWI-Prolog/packages-jpl/tree/master/examples/java

package prolog;

import java.util.ArrayList;
import java.util.Map;
import java.util.StringTokenizer;

import org.jpl7.*;

public class PrologConnector {
	
	public PrologConnector(){

		Query.hasSolution("consult('src/prolog/functions.pl')");
	
	}
	
	public ArrayList<String> findEvents(){
		ArrayList<String> events = new ArrayList<String>();
		Variable X = new Variable("X");
		Variable Y = new Variable("Y");
		Variable Z = new Variable("Z");
		Variable V = new Variable("V");
		
		Query q4 =
		    new Query(
		        "event",
		        new Term[] {X,Y,Z,V}
		    );

		Map<String, Term>[] solutions = q4.allSolutions();

	    for ( int i=0 ; i<solutions.length ; i++ ) {
	        System.out.println( "X = " + solutions[i].get("X"));
	        events.add(solutions[i].get("X").toString().replace("'", ""));
	    }
	    
	    return events;
	}
	
	public void calcDistance(String placeA, String placeB){
	
		Query distanceQuery = 
				new Query(
						new Compound(
								"calcDistance",
								new Term[] {new Atom(placeA), new Atom(placeB), new Variable("X")}
						)
					);
		
		@SuppressWarnings("rawtypes")
		
		Map ergebnis = distanceQuery.oneSolution();
		
		System.out.println("Entfernung zwischen " + placeA + " und " + placeB + ": " + ergebnis.get("X"));
	

	}

	
	public ArrayList<String> getCategoriesByProlog(){
		ArrayList<String> categories = new ArrayList<String>();
		
		Variable X = new Variable("X");
		
		// Geht, Category muss als Liste per Hand in Wissensdatenbank geflegt werden
		/*
		
		Query q4 =
		    new Query(
		        "category",
		        new Term[] {X}
		    );

		Map<String, Term>[] solutions = q4.allSolutions();

	    for ( int i=0 ; i<solutions.length ; i++ ) {
	        System.out.println( "X = " + solutions[i].get("X"));
	        categories.add(solutions[i].get("X").toString());
	    }
	    
	    */
		
		Query q4 =
			    new Query(
			        "findAllCategories",
			        new Term[] {X}
			    );

		/*
		Map<String, Term>[] solutions = q4.allSolutions();

	    for ( int i=0 ; i<solutions.length ; i++ ) {
	        System.out.println( "X = " + solutions[i].get("X"));
	        categories.add(solutions[i].get("X").toString());
	    }
		*/
		
		Map<String, Term> solution = q4.oneSolution();
	   
	    String[] array = solution.get("X").toString().split(" ");
	    for(int i = 0; i<array.length-1; i++){
	    	array[i] = array[i].replace("'[|]'(", "").replace(",","").replace("'","");
	    	System.out.println(array[i]);
	    	if (!categories.contains(array[i])) {
	    	    categories.add(array[i]);
	    	}
	    }
	    
	    return categories;
	}

}
