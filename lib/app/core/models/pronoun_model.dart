class Pronoun {
  Pronoun({
    this.id,
    this.type,
    this.subjectPronoun,
    this.objectPronoun,
    this.possessiveAdjective,
    this.possessivePronoun,
  });

  factory Pronoun.fromMap(Map<dynamic, dynamic> map) {
    return Pronoun(
      id: map['id'] as int,
      type: map['type'] as String,
      objectPronoun: map['object_pronoun'] as String,
      possessiveAdjective: map['possessive_adjective'] as String,
      possessivePronoun: map['possessive_pronoun'] as String,
      subjectPronoun: map['subject_pronoun'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'subject_pronoun': subjectPronoun,
      'object_pronoun': objectPronoun,
      'possessive_adjective': possessiveAdjective,
      'possessive_pronoun': possessivePronoun,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is Pronoun &&
        other.id == id &&
        other.type == type &&
        other.subjectPronoun == subjectPronoun &&
        other.objectPronoun == objectPronoun &&
        other.possessiveAdjective == possessiveAdjective &&
        other.possessivePronoun == possessivePronoun;
  }

  @override
  int get hashCode => Object.hash(id, type, subjectPronoun, objectPronoun, possessiveAdjective, possessivePronoun);

  final int? id;
  final String? type;
  final String? subjectPronoun;
  final String? objectPronoun;
  final String? possessiveAdjective;
  final String? possessivePronoun;
}
