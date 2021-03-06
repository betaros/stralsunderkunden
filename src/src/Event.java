package src;

import java.util.ArrayList;

import org.jxmapviewer.viewer.GeoPosition;

public class Event {
	private String name;
	private double latitude;
	private double longitude;
	private ArrayList<String> categories;
	private ArrayList<String> food;

	private GeoPosition geoPos;
	
	private int priceInCentAdult;
	private int priceInCentChild;
	
	private int day;
	private int startTime;
	private int duration;
	private int businesshoursBegin;
	private int businesshoursEnd;
	private int traveltime;

	/**
	 * 
	 * @param _name
	 * @param _lat
	 * @param _lon
	 * @param _priceAdult
	 * @param _priceChild
	 * @param _cat
	 * @param _food
	 * @param _day
	 * @param _startTime
	 * @param _duration
	 * @param _businesshoursBegin
	 * @param _businesshoursEnd
	 */
	public Event(String _name, double _lat, double _lon, int _priceAdult, int _priceChild, ArrayList<String> _cat, ArrayList<String> _food, int _day, int _startTime, int _duration, int _businesshoursBegin, int _businesshoursEnd){
		this.name = _name;
		this.latitude = _lat;
		this.longitude = _lon;
		this.priceInCentChild = _priceChild;
		this.priceInCentAdult = _priceAdult;
		this.categories = _cat;
		this.food = _food;
		this.day = _day;
		this.startTime = _startTime;
		this.duration = _duration;
		this.businesshoursBegin = _businesshoursBegin;
		this.businesshoursEnd = _businesshoursEnd;
		this.traveltime = 0;
		
		this.geoPos = new GeoPosition(_lat, _lon);
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @return the latitude
	 */
	public double getLatitude() {
		return latitude;
	}

	/**
	 * @return the longitude
	 */
	public double getLongitude() {
		return longitude;
	}

	/**
	 * @return the categories
	 */
	public ArrayList<String> getCategories() {
		return categories;
	}

	/**
	 * @return the food
	 */
	public ArrayList<String> getFood() {
		return food;
	}
	
	/**
	 * @return the geoPos
	 */
	public GeoPosition getGeoPos() {
		return geoPos;
	}

	/**
	 * @return the priceInCent
	 */
	public int getPriceInCentAdult() {
		return priceInCentAdult;
	}

	/**
	 * @param priceInCent the priceInCent to set
	 */
	public void setPriceInCentAdult(int priceInCent) {
		this.priceInCentAdult = priceInCent;
	}
	
	/**
	 * @return the priceInCentChild
	 */
	public int getPriceInCentChild() {
		return priceInCentChild;
	}

	/**
	 * @param priceInCentChild the priceInCentChild to set
	 */
	public void setPriceInCentChild(int priceInCent) {
		this.priceInCentChild = priceInCent;
	}
	
	/**
	 * @return the startTime
	 */
	public int getStartTime() {
		return startTime;
	}

	/**
	 * @param startTime the startTime to set
	 */
	public void setStartTime(int startTime) {
		this.startTime = startTime;
	}

	/**
	 * @return the duration
	 */
	public int getDuration() {
		return duration;
	}

	/**
	 * @param duration the duration to set
	 */
	public void setDuration(int duration) {
		this.duration = duration;
	}
	
	/**
	 * @return the businesshoursBegin
	 */
	public int getBusinesshoursBegin() {
		return businesshoursBegin;
	}

	/**
	 * @return the businesshoursEnd
	 */
	public int getBusinesshoursEnd() {
		return businesshoursEnd;
	}
	
	/**
	 * @return the day
	 */
	public int getDay() {
		return day;
	}

	/**
	 * @param day the day to set
	 */
	public void setDay(int day) {
		this.day = day;
	}
	
	/**
	 * @return the traveltime
	 */
	public int getTraveltime() {
		return traveltime;
	}

	/**
	 * @param traveltime the traveltime to set
	 */
	public void setTraveltime(int traveltime) {
		this.traveltime = traveltime;
	}

}
