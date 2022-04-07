import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int? temperature = 0;
  String location = 'Hallo';
  String? weather = 'snow';

  //menambahkan kode unik untuk kota tertentu
  int woeid = 1047378;

  //membuat variable untuk icon dan error message
  String abberviation = '';
  String errorMassage = '';


  //membuat link url untuk API nya
  String searchApiUrl = 'https://www.metaweather.com/api/location/search/?query=';
  String locationApiurl = 'https://www.metaweather.com/api/location/';

  //varibale buat list temp
  var minTemperatureForecast = List.filled(7 , 0);
  var maxTemperatureForecast = List.filled(7 , 0);
  var abbreviationForecast = List.filled(7 , " ");

  Future<void> fetchSearch(String input) async{
    try{
      var searchResult = await http.get(Uri.parse(searchApiUrl+ input));
      var result = jsonDecode(searchResult.body)[0];

      setState(() {
        location = result['title'];
        woeid = result["woeid"];
        errorMassage = '';
      });

    }catch (error) {
      print (error);
      setState(() {
        errorMassage = 'Maaf kota yang anda cari tidak ada guysss, sorry!';
      });
    }
  }

  Future<void> fetchLocation() async{
    var locationResult =
      await http.get(Uri.parse(locationApiurl + woeid.toString()));
    var result = jsonDecode(locationResult.body);
    var consolidated_weather = result['consolidated_weather'];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abberviation = data['weather_state_abbr'];
    });
  }

  //membuat function untuk menapilakan data 7 hari
  Future<void> fecthSevenDays() async{
    var today = DateTime.now();
    for (var i = 0; i < 7; i++ ) {
      var locationDayResult = await http.get(Uri.parse(locationApiurl + woeid.toString() + '/' + DateFormat('y/M/d').format(today.add(Duration(days: i + 1))).toString()));
      var result = jsonDecode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTemperatureForecast[i] = data["min_temp"].round();
        maxTemperatureForecast[i] = data["max_temp"].round();
        abbreviationForecast[i] = data['weather_state_abbr'];
      });
    }
  }

  //buat fungsi untuk si kolom search agar mendapatkan inputan
  void onTextfieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
    await fecthSevenDays();
  }

  @override
  void initState() {
    super.initState();
    fetchLocation();
    fecthSevenDays();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('asset/$weather.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
        )
      ),
      child: temperature == null
      ? CircularProgressIndicator()
      : Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Column(
                children: [
                  Center(
                    child: Image.network(
                      'https://www.metaweather.com/static/img/weather/png/' + abberviation + '.png',
                      width: 100,
                      color: Colors.white,
                    ),
                  ),
                  Center(
                      child: Text( temperature.toString() + ' ℃',style: TextStyle(
                          color: Colors.white,fontSize: 60
                      ),)
                  ),
                  Center(
                    child: Text(location, style: TextStyle(
                    color: Colors.white, fontSize: 40
                    ),),
                  ),

                  //Untuk tampilan 7 hari berikutnya
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < 7 ; i++)
                            forecestElement(
                                i + 1,
                                abbreviationForecast[i],
                                maxTemperatureForecast[i],
                                minTemperatureForecast[i]),
                        ],
                      ),
                    ),
                  ),

                  //membuat column untuk search
                  Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          onSubmitted: (String input) {
                            onTextfieldSubmitted(input);
                          },
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search Location...',
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            prefixIcon: Icon(Icons.search,
                            color: Colors.white,)
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMassage , textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

 Widget forecestElement(daysFromNow, abbreviation, maxTemp, minTemp) {
    var now = DateTime.now();
    var oneDayFromNow = now.add(Duration(days: daysFromNow));
    return Padding(padding: EdgeInsets.only(left: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(285, 212, 228, 8.2),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(DateFormat.E().format(oneDayFromNow),
              style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              Text(
                DateFormat.MMMd().format(oneDayFromNow),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 16),
              child: Image.network('https://www.metaweather.com/static/img/weather/png/' + abbreviation + '.png',
                width: 50,),
              ),
              Text('High ' + maxTemp.toString() + ' ℃',
              style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text('Low ' + minTemp.toString() + ' ℃',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
 }
}
