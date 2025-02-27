import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async
{
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget
{
  @override
  WeatherState createState() => WeatherState();
}

class WeatherState extends State<HomeScreen>
{
  final TextEditingController cityController = TextEditingController();
  double? temperature;
  int? humidity;
  String? iconCode;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> getWeatherData(String city) async
  {
    final apiKey=dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    setState(()
    {
      isLoading =true;
      errorMessage = '';
    });

    try
    {
      final response=await http.get(Uri.parse(url));

      if(response.statusCode == 200)
      {
        final data =json.decode(response.body);

        setState(()
        {
          temperature =data['main']['temp'].toDouble();
          humidity=data['main']['humidity'];
          iconCode=data['weather'][0]['icon'];
          isLoading=false;
        });
      }
      else
      {
        setState(()
        {
          isLoading=false;
          errorMessage='Please enter a valid name for the city';
          temperature=null;
          humidity=null;
          iconCode=null;
        });
      }
    }
    catch(e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error,Plz try again later';
        temperature=null;
        humidity=null;
        iconCode=null;

      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App',
            style:TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
        ),
      ) ,
      body: Padding(
        padding:const EdgeInsets.all(15.0),
        child : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: ('Enter City'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height:25),

            ElevatedButton(
              onPressed: ()
              {
                if(cityController.text.isNotEmpty)
                {
                  getWeatherData(cityController.text);
                }
              },
              child : Text('Get Weather'),
            ),
            SizedBox(height: 20),

            if(errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(
                    fontSize:20,
                    color: Colors.red[800]),

              ),

            if(isLoading)
              CircularProgressIndicator(),

            if(!isLoading && temperature!=null)...[
              Text(
                'Temperature: ${temperature?.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize:25),
              ),

              if(iconCode!=null)
                Image.network(
                  'https://openweathermap.org/img/wn/$iconCode@2x.png',
                  width: 100,
                  height: 100,

                ),

              if(humidity!=null)
                Text(
                  'Humidity:$humidity%',
                  style: TextStyle(fontSize:22),
                ),
            ]
          ],
        ),
      ),
    );
  }
}