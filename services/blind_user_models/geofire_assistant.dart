
import 'package:arti_eyes/services/blind_user_models/active_nearby_available_assistants.dart';

class GeoFireAssistant
{
  static List<ActiveNearByAvailableAssistants> activeNearByAvailableAssistantsList = [];

  static void deleteOfflineAssistantFromList(String assistantId)
  {
    int indexNumber = activeNearByAvailableAssistantsList.indexWhere((element) => element.assistantId == assistantId);
    activeNearByAvailableAssistantsList.removeAt(indexNumber);
  }

  static void updateActiveNearByAvailableAssistantLocation(ActiveNearByAvailableAssistants assistantWhoMove)
  {
    int indexNumber = activeNearByAvailableAssistantsList.indexWhere((element) => element.assistantId == assistantWhoMove.assistantId);
    activeNearByAvailableAssistantsList[indexNumber].locationLatitude = assistantWhoMove.locationLatitude;
    activeNearByAvailableAssistantsList[indexNumber].locationLongitude = assistantWhoMove.locationLongitude;
  }
}