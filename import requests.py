import requests
import json

params = {
  'api_key': 'API_KEY',
  'params1': 'value1'
}
method = 'delays?delay=30&type=departures&dep_iata=ATL&_fields=dep_iata,name,airline_iata,delayed,status,dep_time'
api_base = 'http://airlabs.co/api/v9/'
api_result = requests.get(api_base+method, params)
api_response = api_result.json()

json_string = json.dumps(api_response, indent=4, sort_keys=True)
with open("airlabs.json", 'w') as jsonfile:
    jsonfile.write(json_string)