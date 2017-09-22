from flask import Flask, request, jsonify

import http.client, urllib.request, urllib.parse, urllib.error, base64
import json

import requests

# import requestamadeus
from requestamadeus import *

app = Flask(__name__)

MICROSOFT_KEY = ""

@app.route('/')
def default_route():
    # value = json.loads(jsonify(["testing json"]))
    return "Hello TrvlAR"

@app.route('/trip_info', methods=['GET'])
def get_trip():
    location = request.args.get('location', '')
    all_info = all_information(location)
    all_info["population"] = population(location)
    info = remove_non_ascii(str(all_info))
    # print(info)
    return info

# wolfram alpha section
# extracts the resuling population of a location using the wolfram simple api for general questions
@app.route('/population', methods=['GET'])
def get_population():

    location = request.args.get('location', '')
    return population(location)

def population(location):
    # general api usage
    # http://api.wolframalpha.com/v2/query?input=pi&appid=XXXX

    url_val = "http://api.wolframalpha.com/v2/query"

    query = "What is the population of " + location
    API_KEY_Wolfram = "HK83UR-UHGPY7A8JA"

    data = requests.get(url=url_val, params={"input": query, "appid": API_KEY_Wolfram})


    result_string = 'pod title=\'Result\''

    just_before_string = 'alt=\''

    start_index = data.text.find(result_string)
    index = data.text.find(just_before_string, start_index) + len(just_before_string)
    end_index = data.text.find(" people", index)

    my_result = data.text[index:end_index] + " people"

    # print(data.text[index:end_index] + " people")
    # print(remove_non_ascii(data.text))

    # return jsonify(data.text)
    # print(my_result)
    return my_result

# works with ?key=value pair key=location and value = name of location
@app.route('/get_pictures', methods=['GET'])
def get_pictures():
    location = request.args.get('location', '')

    print("Getting pictures for location: %s" % location)

    # get the attractions at this location
    information = get_loc_information(get_airport_code(location))
    attractions = get_attractions(str(information["latitude"]), str(information["longitude"]))
    # print(attractions)

    # use string, number_of_images for these items to add keywords to image search
    # and number of images to return
    search_items = []


    if isinstance(attractions, str):
        search_items.append((" weather", 1))
        search_items.append((" people", 1))
        search_items.append((" attractions", 1))
        search_items.append((" sports", 1))
        search_items.append((" geography", 1))
        search_items.append((" map", 1))
        search_items.append((" resort", 1))
        search_items.append((" culture", 1))
        search_items.append((" sites", 1))
    else:


        search_items.append(("", 1))

        # grab one image from each attraction
        for attraction in attractions:
            search_items.append((" " + attraction, 1))

    master_list = []

    # print(len(search_items))

    for i in search_items:
        search_val = bing_search(location + i[0], i[1])
        if len(search_val) > 0:
            master_list.append(search_val[0])
    return jsonify(master_list)

# bing image search
def bing_search(location_name, count):

    global MICROSOFT_KEY

    headers = {
        # Request headers
        # key 1 of regular api - ethan (used to work)
        # 'Ocp-Apim-Subscription-Key': 'fedcea6c97d841ac9105b8e9e1abc139',

        # key 1 of new api version - ethan
        # 'Ocp-Apim-Subscription-Key': 'fedcea6c97d841ac9105b8e9e1abc139',

        # key 1 of arlene's api
        # 'c4e8df438e7042f8856acc8f41f0fa21'

        'Ocp-Apim-Subscription-Key': MICROSOFT_KEY,
    }

    params = {
        # Request parameters
        'q': location_name,
        'count': count,
        'offset': '0',
        'mkt': 'en-us',
        'safeSearch': 'Moderate',
    }

    try:

        data = requests.get(url="https://api.cognitive.microsoft.com/bing/v5.0/images/search", params=params, headers=headers)

        print(data.url)
        print(data.status_code)
        json_array = json.loads(data.text) #this line won't work

        content_list = json_array['value']
        web_url_list = []
        for i in content_list:
            temp_dict = {}
            # temp_dict['name'] = i['name']
            temp_dict['name'] = location_name
            temp_dict['url'] = i['contentUrl']
            web_url_list.append(temp_dict)

        # print(web_url_list)
        return web_url_list

        conn.close()
    except Exception as e:
        print("Error with requesting data.")
        # return an empty list if there is an error
        # return []
        # default value in case something goes wrong but we still want to display content
        with open('saved_responses.json') as data_file:
            my_data = json.load(data_file)
            print(my_data[1])
            return my_data[1]


if __name__=='__main__':
    app.run(threaded=True, debug=True, host='0.0.0.0', port=80)
    # app.run()
