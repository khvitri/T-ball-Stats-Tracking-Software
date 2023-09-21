import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstballprogram/models/classroom.dart';
import 'package:cstballprogram/models/user.dart';

class DatabaseService {
  String? uid;
  String? classId;

  DatabaseService({this.uid, this.classId});

  DatabaseService.teacherId(String? uid) {
    this.uid = uid;
  }

  late final DocumentReference users =
      FirebaseFirestore.instance.collection('users').doc(uid);

  final CollectionReference collectionUsers =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference classCollection =
      FirebaseFirestore.instance.collection('classrooms');

  //create
  Future createNewStudentData(
    String name,
    var feedback,
    var accuracylist,
    var speedList,
    var effectList,
    var distanceList,
    double accuracy,
    double speed,
    double effect,
    double distance,
    var datainput,
    var classid,
    bool teacher,
  ) async {
    return await users.set({
      'name': name,
      'feedback': feedback,
      'accList': accuracylist,
      'speedList': speedList,
      'effectList': effectList,
      'distanceList': distanceList,
      'acc': accuracy,
      'speed': speed,
      'effectiveness': effect,
      'distance': distance,
      'datainput': datainput,
      'classid': classid,
      'teacher': teacher,
    });
  }

  Future updateStudentStatsFromInput(
    var newaccuracy,
    var newspeed,
    var neweffect,
    var newdistance,
    double avgaccuracy,
    double avgspeed,
    double avgeffect,
    double avgdistance,
    var datainput,
  ) async {
    return await users.update({
      'accList': newaccuracy,
      'speedList': newspeed,
      'effectList': neweffect,
      'distanceList': newdistance,
      'acc': avgaccuracy,
      'speed': avgspeed,
      'effectiveness': avgeffect,
      'distance': avgdistance,
      'datainput': datainput,
    });
  }

  Future adddeleteFeedback(var feedback) async {
    return await users.update({'feedback': feedback});
  }

  //Adds joined classroom's id into student's list
  Future addSNewClass(String id) async {
    return await users.update({
      'classid': FieldValue.arrayUnion([id]),
    });
  }

  //Creates new teacher
  Future createNewTeacherData(
      String name, var classid, bool teacher, int numofclass) async {
    return await users.set({
      'name': name,
      'classid': classid,
      'teacher': teacher,
      'numofclass': numofclass
    });
  }

  //Creates new classrooms
  Future createClassroomData(String? teachername, String id, String classname,
      Map<String, String> studentid, String teacherId) async {
    return await classCollection.doc(id).set({
      'teachername': teachername,
      'id': id,
      'classname': classname,
      'studentid': studentid,
      'teacherId': teacherId
    });
  }

  //Adds newly created classroom's id into teacher's list of classroom
  Future addTNewClass(String id, int? numofclass) async {
    return await users.update({
      'classid': FieldValue.arrayUnion([id]),
      'numofclass': FieldValue.increment(1),
    });
  }

  //Add new student into classroom
  Future addNewStudent(String? studentname) async {
    return await classCollection.doc(classId).update({
      'studentid': FieldValue.arrayUnion([
        {uid: studentname}
      ])
    });
  }

  //Delete clasroom's ID from student's list and teacher's list
  Future deleteCIDfromUserCList(String classID) async {
    return await users.update({
      'classid': FieldValue.arrayRemove([classID])
    });
  }

  //Delete classroom's document
  Future deleteClassroomDocument(String classID) async {
    return await classCollection.doc(classID).delete();
  }

  //Delete student from classroom's student list
  Future deleteStudentFromClassroomList(
      String studentid, String studentname) async {
    return await classCollection.doc(classId).update({
      'studentid': FieldValue.arrayRemove([
        {studentid: studentname}
      ])
    });
  }

  //Delete data input
  Future deleteDataInput(var accList, var effectList, var speedList,
      var distanceList, var datainput) async {
    return await users.update({
      'accList': accList,
      'effectList': effectList,
      'speedList': speedList,
      'distanceList': distanceList,
      'datainput': datainput,
    });
  }

  //teacher data from snapshot
  TeacherData _teacherDataFromSnapshot(DocumentSnapshot snapshot) {
    return TeacherData(
      name: snapshot.get('name'),
      classid: snapshot.get('classid'),
      teacher: snapshot.get('teacher'),
      numofclass: snapshot.get('numofclass'),
    );
  }

  Stream<TeacherData> get teacherdata {
    return users.snapshots().map(_teacherDataFromSnapshot);
  }

  UserRole? _userRole(DocumentSnapshot snapshot) {
    return UserRole(teacher: snapshot.get('teacher'));
  }

  Stream<UserRole?> get userrole {
    return users.snapshots().map(_userRole);
  }

  Stream<QuerySnapshot> get classroomCollectionData {
    return classCollection.snapshots();
  }

  Future<List<ClassDocData>> getClassList() async {
    List<ClassDocData> results = [];
    final classListQuery =
        await classCollection.where("teacherId", isEqualTo: uid).get();
    print("Successfull query for class list in Database() line 195");
    for (var classDocSnapshot in classListQuery.docs) {
      results.add(_classroomDocumentDataFromSnapshot(classDocSnapshot));
    }
    return results;
  }

  ClassDocData _classroomDocumentDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, String> convertedStudentId = {};
    snapshot.get('studentid').forEach((key, value) {
      convertedStudentId[key.toString()] = value.toString();
    });

    return ClassDocData(
        classname: snapshot.get('classname'),
        id: snapshot.get('id'),
        studentid: convertedStudentId,
        teachername: snapshot.get('teachername'),
        teacherId: snapshot.get('teacherId'));
  }

  Stream<ClassDocData> get classroomDocumentData {
    return classCollection
        .doc(classId)
        .snapshots()
        .map(_classroomDocumentDataFromSnapshot);
  }

  StudentData _studentDataFromSnapshot(DocumentSnapshot snapshot) {
    return StudentData(
      name: snapshot.get('name'),
      feedback: snapshot.get('feedback'),
      accList: snapshot.get('accList'),
      effectList: snapshot.get('effectList'),
      speedList: snapshot.get('speedList'),
      distanceList: snapshot.get('distanceList'),
      accuracy: snapshot.get('acc'),
      speed: snapshot.get('speed'),
      effect: snapshot.get('effectiveness'),
      distance: snapshot.get('distance'),
      datainput: snapshot.get('datainput'),
      classid: snapshot.get('classid'),
      teacher: snapshot.get('teacher'),
    );
  }

  Stream<StudentData> get studentdata {
    return users.snapshots().map(_studentDataFromSnapshot);
  }
}
