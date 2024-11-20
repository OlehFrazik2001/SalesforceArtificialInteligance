# Salesforce Artificial Inteligance
Steps to prepare environment
1) Create Salesforce Developer Edition (https://developer.salesforce.com/signup)
2) Install Visual Studio Code (https://code.visualstudio.com/)
3) Install Salesforce Extension Pack to Visual Studio Code (https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

Predeployment Steps:
1) Create a new Object 'Weather' and fields:
   "Date" - Date/Time
   "Temperature" - Number
   "Humidity" - Number
   "Prediction Record" - boolean
   "Category" - picklist values (
       Every Hour
      Every 3 Hours
      Every 6 Hours
      Every 12 Hours
      Every 24 Hours)
2) Get API Key from World Weather API 
3) Create Custom Settings for storing API Key (Create new Field "API Key")
4) Add Remote Site Setting to the https://www.worldweatheronline.com/

Steps to deploy metadata to the org
1) In Visual Studio Code deploy Apex AuthCallout (right click on the file in Visual Studio Code and click "Deploy")
2) Go to Developer Console and click Debug -> Run Anonymous Window. 
3) Run Script "AuthCallout.getPastWeather('Lviv', '01-01-2024', '02-02-2024', '1', 'Every Hour')".
4) As a result you will have records created. 
