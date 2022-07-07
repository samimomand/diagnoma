class Result {
  String id;
  String dateTime;
  List<Probability> probabilities;

  Result({this.id, this.dateTime, this.probabilities});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateTime = json['dateTime'];
    if (json['probabilities'] != null) {
      probabilities = new List<Probability>();
      json['probabilities'].forEach((v) {
        probabilities.add(new Probability.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['dateTime'] = this.dateTime;
    if (this.probabilities != null) {
      data['probabilities'] =
          this.probabilities.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Probability {
  double confidence;
  int index;
  String label;

  Probability({this.confidence, this.index, this.label});

  Probability.fromJson(Map<String, dynamic> json) {
    confidence = json['confidence'];
    index = json['index'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['confidence'] = this.confidence;
    data['index'] = this.index;
    data['label'] = this.label;
    return data;
  }
}
