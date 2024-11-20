public class AuthCallout { 

    

    public static String getPastWeather(String location, String startDateWeather, String endDateWeather, String frequency, String category) { 

        try { 

            // Create a new HTTP request 

            HttpRequest req = new HttpRequest(); 

            req.setEndpoint('https://api.worldweatheronline.com/premium/v1/past-weather.ashx'); 

            req.setMethod('GET'); 

             

            // Set parameters for the API call 

            String params = 'key=' + API_KEY +  

                            '&q=' + EncodingUtil.urlEncode(location, 'UTF-8') +  

                            '&date=' + EncodingUtil.urlEncode(startDateWeather, 'UTF-8') +  

                            '&enddate=' + EncodingUtil.urlEncode(endDateWeather, 'UTF-8') +  

                			'&tp=' + EncodingUtil.urlEncode(frequency, 'UTF-8') +  

                            '&format=json';  

             

            // Append parameters to the endpoint URL 

            req.setEndpoint(req.getEndpoint() + '?' + params); 

             

            // Send the HTTP request 

            Http http = new Http(); 

            HttpResponse res = http.send(req); 

             

            // Check the response status 

            if (res.getStatusCode() == 200) { 

                system.debug(res.getBody()); 

                parseWeatherResponse(res.getBody(), category); 

                return 'Success'; 

            } else { 

                System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus()); 

                return null; 

            } 

        } catch (Exception e) { 

            System.debug('Exception: ' + e.getMessage()); 

            return null; 

        } 

    } 

     

    public static void parseWeatherResponse(String jsonResponse, String category) { 

        // Parse the JSON string into a map 

         Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse); 

     

        // Navigate through the parsed map to get weather data 

        Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data'); 

        List<Object> weatherList = (List<Object>) dataMap.get('weather'); 

    	List<WeatherWrapper> weatherWrappers = new List<WeatherWrapper>(); 

        for(Object weather: weatherList){ 

  

            // Cast each element of the weatherList to a Map<String, Object> 

            Map<String, Object> weatherData = (Map<String, Object>) weather; 

            String dateWeather = (String) weatherData.get('date'); 

            List<Integer> dateWeatherList = new List<Integer>(); 

            for (String s : dateWeather.split('-')) { 

                dateWeatherList.add(Integer.valueOf(s)); 

            } 

             

            // Parse hourly data if needed 

            List<Object> hourlyList = (List<Object>) weatherData.get('hourly'); 

            if (hourlyList != null && hourlyList.size() > 0) { 

            	for(Object hourly: hourlyList){ 

                	WeatherWrapper weatherWrap = new WeatherWrapper(); 

                    Map<String, Object> hourlyData = (Map<String, Object>) hourly; 

                    weatherWrap.temperatureWeather =  Integer.valueOf(hourlyData.get('tempC')); 

                    weatherWrap.humidityWeather = Integer.valueOf( hourlyData.get('humidity')); 

                    Integer timeT = Integer.valueOf(hourlyData.get('time')) / 100; 

                    weatherWrap.dateTimeWeather = Datetime.newInstance(dateWeatherList[0], dateWeatherList[1], dateWeatherList[2],timeT, 0, 0);  

weatherWrappers.add(weatherWrap);                                     

                } 

            } 

        } 

        createWeatherRecords(weatherWrappers, category); 

    } 

     

    public static void createWeatherRecords(List<WeatherWrapper> weatherWrappers, String category){ 

        List<Weather__c> weatherList = new List<Weather__c>(); 

        for(WeatherWrapper weatherWrap: weatherWrappers){ 

        	Weather__c weather = new Weather__c(); 

            weather.Date__c = weatherWrap.dateTimeWeather; 

            weather.Temperature__c  = weatherWrap.temperatureWeather;             

            weather.Humidity__c  = weatherWrap.humidityWeather; 

            weather.Prediction_Record__c = false; 

            weather.Category__c = category; 

            weatherList.add(weather); 

        } 

        insert weatherList; 

    } 

    public static void updateWeatherRecords(List<WeatherWrapper> weatherWrappers, String category){ 

        List<Weather__c> weatherList = [SELECT Id, Date__c, Temperature__c FROM Weather__c WHERE Category__c = :category AND Prediction_Record__c = true]; 

        Map<DateTime, Weather__c> mapWeatherByDateTime = new Map<DateTime, Weather__c>(); 

        for(Weather__c weather: weatherList){ 

            mapWeatherByDateTime.put(weather.Date__c, weather); 

        } 

        List<Weather__c> weatherListToUpdate = new List<Weather__c>(); 

         

        for(WeatherWrapper weatherWrap: weatherWrappers){ 
            if(mapWeatherByDateTime.containsKey(weatherWrap.dateTimeWeather)){ 
            	Weather__c weather = mapWeatherByDateTime.get(weatherWrap.dateTimeWeather);             
            	weather.Temperature__c  = weatherWrap.temperatureWeather;             
            	weatherListToUpdate.add(weather); 
            } 
        } 
        update weatherListToUpdate; 

    } 
     

     

    public class WeatherWrapper { 

        private  DateTime dateTimeWeather; 

       	private  Integer temperatureWeather; 

       	private  Integer humidityWeather; 

    }   

} 