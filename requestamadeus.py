import requests
import json
from unidecode import unidecode


APIKEY = ""

ORIGIN = "BOS"
ONE_WEEK = "2017-09-24"
ONE_MONTH = "2017-10-17"
THREE_MONTHS = "2017-12-17"
THIS_MONTH = "2016-09"

def remove_non_ascii(string):
	''' Returns the string without non ASCII characters'''
	stripped = (c for c in string if 0 < ord(c) < 127)
	return ''.join(stripped)

#given first few letters/entire destination name, return airport code
def get_airport_code(user_inp):
	airport_url = "http://api.sandbox.amadeus.com/v1.2/airports/autocomplete?apikey=" + APIKEY + "&term=" + user_inp
	airport = requests.get(url=airport_url)

	if airport.status_code != 200:
		return "Error getting airport code"
	else:
		parsed = json.loads(airport.text)
		if len(parsed) > 0 and "value" in parsed[0]:
			return parsed[0]["value"]
		else:
			return "Invalid airport format"


#given airport code, returns city name, lat, long, timezone, airport code, airport name
def get_loc_information(airport_code):
	info_url = "http://api.sandbox.amadeus.com/v1.2/location/" + airport_code + "/?apikey=" + APIKEY
	info = requests.get(url=info_url)

	if info.status_code != 200:
		return "Error getting location information"
	else:
		parsed = json.loads(info.text)
		if "Info" in parsed:
			return "Error getting location information"
		all_info = {}
		all_info["city"] = parsed["city"]["name"]
		all_info["latitude"] = parsed["city"]["location"]["latitude"]
		all_info["longitude"] = parsed["city"]["location"]["longitude"]
		all_info["timezone"] = parsed["city"]["timezone"]
		all_info["code"] = None
		all_info["airport"] = None
		if len(parsed["airports"]) > 1:
			all_info["code"] = parsed["airports"][0]["code"]
			all_info["airport"] = parsed["airports"][0]["name"]
		return all_info


def get_nearest(latitude, longitude):
	nearest_url = "http://api.sandbox.amadeus.com/v1.2/airports/nearest-relevant?latitude=" + latitude + "&longitude=" + longitude+ "&apikey=" + APIKEY
	nearest = requests.get(url=nearest_url)

	if nearest.status_code != 200:
		return "Error getting nearest location"
	else:
		parsed = json.loads(nearest.text)
		if len(parsed) > 0 and "airport" in parsed[0] and "airport_name" in parsed[0]:
			return (parsed[0]["airport"], parsed[0]["airport_name"])
		return "Error getting nearest location"


def get_attractions(latitude, longitude):
	attract_url = "https://api.sandbox.amadeus.com/v1.2/points-of-interest/yapq-search-circle?number_of_results=10&category=landmark&radius=30&latitude=" + latitude + "&longitude=" + longitude + "&apikey=" + APIKEY
	attract = requests.get(url=attract_url)

	if attract.status_code != 200:
		# return "Error getting attractions"
		with open('saved_responses.json') as data_file:
			my_data = json.load(data_file)
			print(my_data[0][0]["attractions"])
			return my_data[0][0]["attractions"]
	else:
		parsed = json.loads(attract.text)
		points_of_interest = []
		if "points_of_interest" not in parsed:
			return "Error getting attractions"
		for i in parsed["points_of_interest"]:
			points_of_interest.append(i["title"])
		return points_of_interest

# def get_low_fare(dest_city):
# 	fares = {}
# 	for DEPARTURE_DATE in [ONE_WEEK, ONE_MONTH, THREE_MONTHS]:
# 		# low_fare_url = "http://api.sandbox.amadeus.com/v1.2/flights/extensive-search?origin=BOS&destination=" + dest_city + "&departure_date=" + DEPARTURE_DATE + "&one-way=true&apikey=" + APIKEY
#
# 		low_fare_url = "http://api.sandbox.amadeus.com/v1.2/flights/low-fare-search?origin=BOS&destination=" + dest_city + "&departure_date=" + DEPARTURE_DATE + "&one-way=true&apikey=" + APIKEY
#
# 		low_fare = requests.get(url=low_fare_url)
#
# 		print(low_fare.text)
#
# 		if low_fare.status_code != 200:
# 			return "Error getting low fare"
# 		else:
# 			parsed = json.loads(low_fare.text)
# 			# fares[DEPARTURE_DATE] = [parsed["results"][0]["price"], parsed["currency"], parsed["results"][0]["airline"]]
# 			fares[DEPARTURE_DATE] = [parsed["results"][0]["fare"]["total_price"], parsed["currency"], parsed["results"][0]["itineraries"][0]["outbound"]["flights"][0]["marketing_airline"]]
# 	return fares

def get_low_fare(dest_city):
	fares = {}
	for DEPARTURE_DATE in [ONE_WEEK, ONE_MONTH, THREE_MONTHS]:
		# low_fare_url = "http://api.sandbox.amadeus.com/v1.2/flights/extensive-search?origin=BOS&destination=" + dest_city + "&departure_date=" + DEPARTURE_DATE + "&one-way=true&apikey=" + APIKEY

		# low_fare_url = "http://api.sandbox.amadeus.com/v1.2/flights/low-fare-search?origin=IST&destination=BOS&destination=" + dest_city + "&number_of_results=20" + "&departure_date=" + DEPARTURE_DATE + "&one-way=true&apikey=" + APIKEY

		low_fare_url = "http://api.sandbox.amadeus.com/v1.2/flights/low-fare-search?origin=BOS&destination=" + dest_city + "&departure_date=" + DEPARTURE_DATE + "&one-way=true&number_of_results=10&apikey=" + APIKEY
		low_fare = requests.get(url=low_fare_url)

		# print(low_fare.text)

		# if low_fare.status_code != 200:
		# 	return "Error getting low fare"
		# else:
		# 	parsed = json.loads(low_fare.text)
		# 	# fares[DEPARTURE_DATE] = [parsed["results"][0]["price"], parsed["currency"], parsed["results"][0]["airline"]]
		#
		# 	fares[DEPARTURE_DATE] = [parsed["results"][0]["fare"]["total_price"], parsed["currency"], parsed["results"][0]["itineraries"][0]["outbound"]["flights"][0]["marketing_airline"]]

		if low_fare.status_code != 200:
			# return "Error getting low fare"
			with open('saved_responses.json') as data_file:
				my_data = json.load(data_file)
				print(my_data[0][0]["fares"])
				return my_data[0][0]["fares"]
		else:
			parsed = json.loads(low_fare.text)
			# fares[DEPARTURE_DATE] = [parsed["results"][0]["price"], parsed["currency"], parsed["results"][0]["airline"]]
			flights = []
			for i in range(len(parsed["results"])):
				start_index = parsed["results"][i]["itineraries"][0]["outbound"]["flights"][0]["departs_at"].find("T") + 1
				flights.append([parsed["results"][i]["fare"]["total_price"], parsed["currency"], parsed["results"][i]["itineraries"][0]["outbound"]["flights"][0]["marketing_airline"],
				parsed["results"][i]["itineraries"][0]["outbound"]["flights"][0]["departs_at"][start_index:]])

			fares[DEPARTURE_DATE] = flights

	return fares


def ranked_suggestions():
	suggestions = []
	suggest_url = "https://api.sandbox.amadeus.com/v1.2/travel-intelligence/top-destinations?period=" + THIS_MONTH + "&origin=BOS&number_of_results=10&apikey=" + APIKEY
	suggest = requests.get(url=suggest_url)

	if suggest.status_code != 200:
		return "Error getting suggestions"
	else:
		parsed = json.loads(suggest.text)
		if "results" in parsed:
			for i in parsed["results"]:
				suggestions.append(i["destination"])
	return suggestions


def all_information(user_inp):
	try:
		information = get_loc_information(get_airport_code(user_inp))
		information["attractions"] = get_attractions(str(information["latitude"]), str(information["longitude"]))
		information["fares"] = {}
		information["code"] = get_nearest(str(information["latitude"]), str(information["longitude"]))[0]
		information["airport"] = get_nearest(str(information["latitude"]), str(information["longitude"]))[1]
		information["popular_places"] = ranked_suggestions()
		if information["code"] is not None:
			information["fares"] = get_low_fare(information["code"])
		return information
	except Exception as e:
		return e

# print(remove_non_ascii(str(all_information("salt"))))
