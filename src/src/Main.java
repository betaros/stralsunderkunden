package src;

/**
 * Prolog <-> Java
 * http://www.swi-prolog.org/packages/jpl/
 */

import java.awt.EventQueue;

import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import gui.MainGui;

public class Main {
	
	public static void main(String[] args) {
		
		// Starte GUI
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
			    } 
			    catch (UnsupportedLookAndFeelException e) {
			       // handle exception
			    	try {
			    		// Set cross-platform Java L&F (also called "Metal")
			    		UIManager.setLookAndFeel(UIManager.getCrossPlatformLookAndFeelClassName());
					} catch (ClassNotFoundException | InstantiationException | IllegalAccessException
							| UnsupportedLookAndFeelException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
			    }
			    catch (ClassNotFoundException e) {
			       // handle exception
			    }
			    catch (InstantiationException e) {
			       // handle exception
		    	}
				catch (IllegalAccessException e) {
					// handle exception
		    	}
				
				try {
					MainGui window = new MainGui();
					window.frmStralsundErkunden.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

}
