import 'dart:convert';

class PlacesResponse {
  final String type;
  final List<Feature> features;
  final String attribution;

  PlacesResponse({
    required this.type,
    required this.features,
    required this.attribution,
  });

  factory PlacesResponse.fromRawJson(String str) =>
      PlacesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PlacesResponse.fromJson(Map<String, dynamic> json) => PlacesResponse(
        type: json["type"] ?? "Unknown",
        features: (json["features"] as List?)
                ?.map((x) => Feature.fromJson(x))
                .toList() ??
            [],
        attribution: json["attribution"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "features": features.map((x) => x.toJson()).toList(),
        "attribution": attribution,
      };
}

class Feature {
  final String type;
  final String id;
  final Geometry geometry;
  final Properties properties;

  Feature({
    required this.type,
    required this.id,
    required this.geometry,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"] ?? "Unknown",
        id: json["id"] ?? "Unknown",
        geometry: Geometry.fromJson(json["geometry"] ?? {}),
        properties: Properties.fromJson(json["properties"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "geometry": geometry.toJson(),
        "properties": properties.toJson(),
      };
}

class Geometry {
  final String type;
  final List<double> coordinates;

  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"] ?? "Point",
        coordinates: (json["coordinates"] as List?)
                ?.map((x) => (x as num?)?.toDouble() ?? 0.0)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates,
      };
}

class Properties {
  final String mapboxId;
  final String featureType;
  final String? fullAddress;
  final String name;
  final String? namePreferred;
  final Coordinates coordinates;
  final String? placeFormatted;
  final Context? context;

  Properties({
    required this.mapboxId,
    required this.featureType,
    this.fullAddress,
    required this.name,
    this.namePreferred,
    required this.coordinates,
    this.placeFormatted,
    this.context,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mapboxId: json["mapbox_id"] ?? "Unknown",
        featureType: json["feature_type"] ?? "Unknown",
        fullAddress: json["full_address"],
        name: json["name"] ?? "Unknown",
        namePreferred: json["name_preferred"],
        coordinates: Coordinates.fromJson(json["coordinates"] ?? {}),
        placeFormatted: json["place_formatted"],
        context:
            json["context"] != null ? Context.fromJson(json["context"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "feature_type": featureType,
        "full_address": fullAddress,
        "name": name,
        "name_preferred": namePreferred,
        "coordinates": coordinates.toJson(),
        "place_formatted": placeFormatted,
        "context": context?.toJson(),
      };
}

class Context {
  final Postcode? street;
  final Postcode? postcode;
  final Place? place;
  final Region? region;
  final Country? country;

  Context({
    this.street,
    this.postcode,
    this.place,
    this.region,
    this.country,
  });

  factory Context.fromJson(Map<String, dynamic> json) => Context(
        street:
            json["street"] != null ? Postcode.fromJson(json["street"]) : null,
        postcode: json["postcode"] != null
            ? Postcode.fromJson(json["postcode"])
            : null,
        place: json["place"] != null ? Place.fromJson(json["place"]) : null,
        region: json["region"] != null ? Region.fromJson(json["region"]) : null,
        country:
            json["country"] != null ? Country.fromJson(json["country"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "street": street?.toJson(),
        "postcode": postcode?.toJson(),
        "place": place?.toJson(),
        "region": region?.toJson(),
        "country": country?.toJson(),
      };
}

class Country {
  final String mapboxId;
  final String name;
  final String? wikidataId;
  final String? countryCode;
  final String? countryCodeAlpha3;

  Country({
    required this.mapboxId,
    required this.name,
    this.wikidataId,
    this.countryCode,
    this.countryCodeAlpha3,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        mapboxId: json["mapbox_id"] ?? "Unknown",
        name: json["name"] ?? "Unknown",
        wikidataId: json["wikidata_id"],
        countryCode: json["country_code"],
        countryCodeAlpha3: json["country_code_alpha_3"],
      );

  Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
        "wikidata_id": wikidataId,
        "country_code": countryCode,
        "country_code_alpha_3": countryCodeAlpha3,
      };
}

class Place {
  final String mapboxId;
  final String name;

  Place({
    required this.mapboxId,
    required this.name,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        mapboxId: json["mapbox_id"] ?? "Unknown",
        name: json["name"] ?? "Unknown",
      );

  Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
      };
}

class Postcode {
  final String mapboxId;
  final String name;

  Postcode({
    required this.mapboxId,
    required this.name,
  });

  factory Postcode.fromJson(Map<String, dynamic> json) => Postcode(
        mapboxId: json["mapbox_id"] ?? "Unknown",
        name: json["name"] ?? "Unknown",
      );

  Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
      };
}

class Region {
  final String mapboxId;
  final String name;
  final String? wikidataId;

  Region({
    required this.mapboxId,
    required this.name,
    this.wikidataId,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        mapboxId: json["mapbox_id"] ?? "Unknown",
        name: json["name"] ?? "Unknown",
        wikidataId: json["wikidata_id"],
      );

  Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
        "wikidata_id": wikidataId,
      };
}

class Coordinates {
  final double longitude;
  final double latitude;

  Coordinates({
    required this.longitude,
    required this.latitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
        latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "longitude": longitude,
        "latitude": latitude,
      };
}
