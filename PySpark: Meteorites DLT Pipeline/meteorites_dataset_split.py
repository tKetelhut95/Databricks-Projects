# This python script will split the original json dataset into 2 json files...the 1st file will be an intial run of the Databricks DLT Pipeline and the 2nd will test a Job Trigger via File Arrival
# The new json files will retain certain keys and values that are inaccurate in order to demonstrate Databricks DLT Pipeline constraint use cases

# Import the "json" library
import json

# Read data from the meteorite json file and save this data to a variable called "data"
with open("earth_meteorite_landings.json", "r", encoding='utf-8') as f:
    data = json.load(f)

# Split the "data" variable into 2 variables based on the "year" key...one for data before the year 2000 and another for data after 2000 
# Any object that does not contain the "year" key is included in the before 2000 variable due to the "or" statement because all objects contain an "id"
before_2000 = [x for x in data if x.get("year", "other").split("T")[0] < '2000-01-01' or x.get("id") != None]
after_2000 = [x for x in data if x.get("year", "other").split("T")[0] >= '2000-01-01' and x.get("year") != None]     
        
# Define a "json_export" function that has 2 parameters...one for the file name and the other for the before/after 2000 variables above
# The Function has an open statement to write to a json file with 'utf-8' formatting and json.dumps to specify which variable data will be written
def json_export(file_name, data):
    with open(file_name, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

# Call the "json_export" function using 2 arguemnts..."file_name" for the file name desired and "data" for the before/after 2000 variable names to create 2 new json files
json_export("earth_meteorite_landings_before_2000.json", before_2000)
json_export("earth_meteorite_landings_after_2000.json", after_2000)
