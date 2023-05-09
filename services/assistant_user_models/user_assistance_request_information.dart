import 'package:latlong2/latlong.dart';

class BlindUserAssistanceRequestInformation
{
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? assistanceRequestId;
  String? userName;
  String? userPhone;

  BlindUserAssistanceRequestInformation({
    this.originLatLng,
    this.destinationLatLng,
    this.originAddress,
    this.destinationAddress,
    this.assistanceRequestId,
    this.userName,
    this.userPhone,
  });
}