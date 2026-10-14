import 'dart:math';

import 'package:exif_reader/exif_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('PUBLISHABLE_KEY'),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home:Scaffold(
            body:imageSelecter()
        )
    );
  }
}
class imageSelecter extends StatefulWidget {
  const imageSelecter({super.key});

  @override
  State<imageSelecter> createState() => _imageSelecterState();
}

class _imageSelecterState extends State<imageSelecter> {
  @override
  double lat=0;
  double lon=0;
  String text='';
  final picker=ImagePicker();
  late XFile image;
  gmaps.GoogleMapController? _googleMapController;
  double printableToNumber(String printable){
    final list=printable
        .substring(1,printable.length-1)
        .split(',')
        .map((e){
      final sp=e.split('/');
      late final a,b;
      if(sp.length==1){
        a=sp[0];
        b='1';
      }else{
        [a,b]=sp;
      }

      return int.parse(a)/int.parse(b);
    })
        .toList();
    return list[0]+list[1]/60+list[2]/3600;
  }
  void _onUpload() async {
    final imageOrNull=await picker.pickImage(source: ImageSource.gallery);
    if(imageOrNull!=null){
      image=imageOrNull;
      final bytes=await image.readAsBytes();
      final exif=await readExifFromBytes(bytes);
      final latRef=exif.tags['GPS GPSLatitudeRef'];
      final lat=exif.tags['GPS GPSLatitude'];
      final lonRef=exif.tags['GPS GPSLongitudeRef'];
      final lon=exif.tags['GPS GPSLongitude'];
      if(lat !=null && lon!=null){
        text='$latRef ${printableToNumber(lat.printable)}\n$lonRef ${printableToNumber(lon.printable)}';
        this.lat=(latRef=='S'?-printableToNumber(lat.printable):printableToNumber(lat.printable));
        this.lon=(lonRef=='W'?-printableToNumber(lon.printable):printableToNumber(lon.printable));
        _googleMapController?.animateCamera(gmaps.CameraUpdate.newLatLng(gmaps.LatLng(this.lat, this.lon)));
      }else{
        text='I don\'t know';
      }
      setState(() {
      });
    }

  }
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextButton(
              onPressed: _onUpload,
              child: Text('uplooad')
          ),
          Text(text),
          SizedBox(
            width:500,
            height: 500,
            child: gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                  target: gmaps.LatLng(lat, lon),
                  zoom:16
              ),
              mapType: gmaps.MapType.hybrid,
              onMapCreated: (c){
                _googleMapController=c;
              },
            ),
          )
        ],
      ),
    );
  }
}


