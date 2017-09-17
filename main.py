from flask import Flask, request, jsonify

import http.client, urllib.request, urllib.parse, urllib.error, base64
import json

import requests

app = Flask(__name__)

@app.route('/')
def default_route():
    # value = json.loads(jsonify(["testing json"]))
    return "Hello TrvlAR"

@app.route('/flight', methods=['GET'])
def get_flight():
    print("testing flight")
    return "Flight information"


# works with ?key=value pair key=location and value = name of location
@app.route('/get_pictures', methods=['GET'])
def get_pictures():
    location = request.args.get('location', '')

    print("Getting pictures for location: %s" % location)

    # use string, number_of_images for these items to add keywords to image search
    # and number of images to return
    search_items = []
    search_items.append(("", 1))
    search_items.append((" attraction", 1))
    search_items.append((" weather", 1))
    search_items.append((" people", 1))
    search_items.append((" activity", 1))

    master_list = []

    for i in search_items:
        master_list.append(bing_search(location + i[0], i[1]))
    return jsonify(master_list)

# bing image search
def bing_search(location_name, count):

    headers = {
        # Request headers
        'Ocp-Apim-Subscription-Key': 'fedcea6c97d841ac9105b8e9e1abc139',
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

        json_array = json.loads(data.text) #this line won't work

        content_list = json_array['value']
        web_url_list = []
        for i in content_list:
            temp_dict = {}
            temp_dict['name'] = i['name']
            temp_dict['url'] = i['contentUrl']
            web_url_list.append(temp_dict)

        # print(web_url_list)
        return web_url_list

        conn.close()
    except Exception as e:
        print("Error with requesting data.")
        # return an empty list if there is an error
        return []


if __name__=='__main__':
    app.run(threaded=True, debug=True, host='0.0.0.0', port=80)
    # app.run()
