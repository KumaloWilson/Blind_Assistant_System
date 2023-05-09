import 'dart:async';
import 'package:arti_eyes/services/assistant_user_models/assistant_user_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../services/assistant_user_models/assistant_data.dart';
import '../services/assistant_user_models/direction_details_info.dart';
import '../services/assistant_user_models/directions.dart';
import '../services/blind_user_models/blind_user_model.dart';

//Blind person global variables
BlindUserModel? blindUserModelCurrentInfo;
List assistantUserList = []; // assistantKeyInfo List
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenAssistantId = "";
String cloudMessagingServerToken = "key=AAAA8day938:APA91bEpUfvY5rZmrRTIjv5E-s_b9C5JCQxetG9SQJ_O9Fm8yYFGGqHqCpmmgxUwmqIs7nG_goR8WTK9rUiY-lQDoRk6JlwqmKtrSOUaafBrVOeK2aaxXhGIw9iPIRR-xPuCMLLeYZtP";
String blindUserDropOffAddress = "";
String blindUserCurrentAddress = "";
String assistantCarDetails = "";
String assistantName = "";
String assistantPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";
int countTotalTrips = 0;
List<String> historyTripsKeysList = [];





//Assistant global variables
String assistantStatusText = "Now Offline";
StreamSubscription<LocationData>? streamSubscriptionPosition;
StreamSubscription<LocationData>? streamSubscriptionAssistantLivePosition;
LocationData? assistantCurrentPosition;
AssistantData onlineAssistantUserData = AssistantData();
AssistantUserModel? assistantUserModelCurrentInfo;
String? assistantAvatarType = "";
bool isAssistantUserActive = false;





//Overall app global variable
var location = Location();
enum UserType{blindPerson, assistant}
UserType? userType;
String? asUser;
bool assistantMode = false;
bool blindMode = false;
bool isAssistantActive = false;
Directions? userPickUpLocation, userDropOffLocation;
String userName = "";
String userEmail = "";
String userPhone = "";
FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
LatLng? myPosition = LatLng(0, 0);