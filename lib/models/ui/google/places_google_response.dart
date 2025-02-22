import 'dart:convert';

class PlacesGoogleResponse {
  final List<Result> results;
  final String status;

  PlacesGoogleResponse({
    required this.results,
    required this.status,
  });

  factory PlacesGoogleResponse.fromRawJson(String str) =>
      PlacesGoogleResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PlacesGoogleResponse.fromJson(Map<String, dynamic> json) =>
      PlacesGoogleResponse(
        results: json["results"] == null
            ? []
            : List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        status: json["status"] ?? "UNKNOWN",
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "status": status,
      };
}

class Result {
  final List<AddressComponent> addressComponents;
  final String formattedAddress;
  final Geometry geometry;
  final List<NavigationPoint> navigationPoints;
  final bool? partialMatch;
  final String placeId;
  final PlusCode? plusCode;
  final List<String> types;

  Result({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.navigationPoints,
    this.partialMatch,
    required this.placeId,
    this.plusCode,
    required this.types,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        addressComponents: json["address_components"] == null
            ? []
            : List<AddressComponent>.from(json["address_components"]
                .map((x) => AddressComponent.fromJson(x))),
        formattedAddress: json["formatted_address"] ?? "Unknown address",
        geometry: Geometry.fromJson(json["geometry"] ?? {}),
        navigationPoints: json["navigation_points"] == null
            ? []
            : List<NavigationPoint>.from(json["navigation_points"]
                .map((x) => NavigationPoint.fromJson(x))),
        partialMatch: json["partial_match"] ?? false,
        placeId: json["place_id"] ?? "N/A",
        plusCode: json["plus_code"] != null
            ? PlusCode.fromJson(json["plus_code"])
            : null,
        types: json["types"] == null
            ? []
            : List<String>.from(json["types"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "address_components":
            List<dynamic>.from(addressComponents.map((x) => x.toJson())),
        "formatted_address": formattedAddress,
        "geometry": geometry.toJson(),
        "navigation_points":
            List<dynamic>.from(navigationPoints.map((x) => x.toJson())),
        "partial_match": partialMatch,
        "place_id": placeId,
        "plus_code": plusCode?.toJson(),
        "types": List<dynamic>.from(types.map((x) => x)),
      };
}

class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromRawJson(String str) =>
      AddressComponent.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      AddressComponent(
        longName: json["long_name"] ?? "No name",
        shortName: json["short_name"] ?? "N/A",
        types: json["types"] == null
            ? []
            : List<String>.from(json["types"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "long_name": longName,
        "short_name": shortName,
        "types": List<dynamic>.from(types.map((x) => x)),
      };
}

class Geometry {
  final Location location;
  final String? locationType;
  final Viewport? viewport;

  Geometry({
    required this.location,
    this.locationType,
    this.viewport,
  });

  factory Geometry.fromRawJson(String str) =>
      Geometry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        location: Location.fromJson(json["location"] ?? {}),
        locationType: json["location_type"],
        viewport: json["viewport"] != null
            ? Viewport.fromJson(json["viewport"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "location": location.toJson(),
        "location_type": locationType,
        "viewport": viewport?.toJson(),
      };
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromRawJson(String str) =>
      Location.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: (json["lat"] ?? 0.0).toDouble(),
        lng: (json["lng"] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Viewport {
  final Location northeast;
  final Location southwest;

  Viewport({
    required this.northeast,
    required this.southwest,
  });

  factory Viewport.fromRawJson(String str) =>
      Viewport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
        northeast: Location.fromJson(json["northeast"] ?? {}),
        southwest: Location.fromJson(json["southwest"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "northeast": northeast.toJson(),
        "southwest": southwest.toJson(),
      };
}

class NavigationPoint {
  final Location location;
  final List<String>? restrictedTravelModes;

  NavigationPoint({
    required this.location,
    this.restrictedTravelModes,
  });

  factory NavigationPoint.fromRawJson(String str) =>
      NavigationPoint.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NavigationPoint.fromJson(Map<String, dynamic> json) =>
      NavigationPoint(
        location: Location.fromJson(json["location"] ?? {}),
        restrictedTravelModes: json["restricted_travel_modes"] == null
            ? []
            : List<String>.from(json["restricted_travel_modes"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "location": location.toJson(),
        "restricted_travel_modes": restrictedTravelModes == null
            ? []
            : List<dynamic>.from(restrictedTravelModes!.map((x) => x)),
      };
}

class PlusCode {
  final String? compoundCode;
  final String? globalCode;

  PlusCode({
    this.compoundCode,
    this.globalCode,
  });

  factory PlusCode.fromRawJson(String str) =>
      PlusCode.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PlusCode.fromJson(Map<String, dynamic> json) => PlusCode(
        compoundCode: json["compound_code"],
        globalCode: json["global_code"],
      );

  Map<String, dynamic> toJson() => {
        "compound_code": compoundCode,
        "global_code": globalCode,
      };
}
