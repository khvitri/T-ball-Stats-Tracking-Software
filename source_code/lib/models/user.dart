// ignore: camel_case_types
class cUser {
  final String? uid;
  cUser({this.uid});
}

class TeacherData {
  final String? name;
  var classid;
  final bool? teacher;
  final int? numofclass;
  TeacherData({
    this.name,
    this.classid,
    this.teacher,
    this.numofclass,
  });
}

class StudentData {
  final String? name;
  var feedback;
  final double? accuracy;
  final double? speed;
  final double? effect;
  final double? distance;
  final List<Map<String, String>>? datainput;
  var classid;
  final bool? teacher;
  StudentData({
    this.name,
    this.feedback,
    this.accuracy,
    this.speed,
    this.effect,
    this.distance,
    this.datainput,
    this.classid,
    this.teacher,
  });
}

class UserRole {
  final bool? teacher;
  UserRole({this.teacher});
}
