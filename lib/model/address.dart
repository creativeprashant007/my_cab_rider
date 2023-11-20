class Address {
  String placeName;
  double latitude;
  double longitude;
  String placeId;
  String placeFormattedAddress;

  Address({
    required this.latitude,
    required this.longitude,
    required this.placeFormattedAddress,
    required this.placeId,
    required this.placeName,
  });
}
