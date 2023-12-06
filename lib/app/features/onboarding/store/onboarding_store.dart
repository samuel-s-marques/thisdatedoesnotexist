import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/enum/database_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/models/body_type_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/occupation_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/political_view_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/relationship_goal_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/religion_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/sex_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/auth_service.dart';
import 'package:thisdatedoesnotexist/app/core/services/database_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

part 'onboarding_store.g.dart';

class OnboardingStore = OnboardingStoreBase with _$OnboardingStore;

abstract class OnboardingStoreBase with Store {
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();
  String server = const String.fromEnvironment('SERVER');
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  final Dio dio = Dio();
  final MaskTextInputFormatter heightMask = MaskTextInputFormatter(
    mask: '#,##',
    filter: {
      '#': RegExp('[0-9]'),
    },
  );
  final MaskTextInputFormatter weightMask = MaskTextInputFormatter(
    mask: '###,#',
    filter: {
      '#': RegExp('[0-9]'),
    },
  );

  @observable
  TextEditingController birthdayController = TextEditingController();

  @observable
  DateTime? birthDay;

  @action
  Future<void> selectBirthday(BuildContext context) async {
    final DateTime minDate = DateTime(DateTime.now().year - 18);
    final DateTime maxDate = DateTime(DateTime.now().year - 50);
    final DateFormat format = DateFormat('dd/MM/yyyy');

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: maxDate,
      lastDate: minDate,
    );

    if (pickedDate != null && pickedDate != birthDay) {
      birthDay = pickedDate;
      birthdayController.text = format.format(birthDay!);
    }
  }

  @observable
  UserModel? user;

  @observable
  RangeValues ageValues = const RangeValues(18, 50);

  @observable
  ObservableList<Hobby> selectedHobbies = ObservableList();

  @observable
  ObservableMap<String, List<Hobby>> groupedHobbies = ObservableMap();

  @observable
  ObservableList<RelationshipGoal> relationshipGoals = ObservableList();

  @observable
  ObservableList<PoliticalView> politicalViews = ObservableList();

  @observable
  ObservableList<BodyType> bodyTypes = ObservableList();

  @observable
  ObservableList<Religion> religions = ObservableList();

  @observable
  ObservableList<Occupation> occupations = ObservableList();

  @observable
  Religion? religion;

  @observable
  ObservableList<Sex> sexes = ObservableList();
  Map<String, String> pluralSexesMap = {'male': 'Men', 'female': 'Women'};
  Map<String, String> singularSexesMap = {'male': 'Man', 'female': 'Woman'};

  @observable
  ObservableList<PoliticalView> selectedPoliticalViewPreferences = ObservableList();

  @observable
  ObservableList<BodyType> selectedBodyTypePreferences = ObservableList();

  @observable
  ObservableList<RelationshipGoal> selectedRelationshipGoalPreferences = ObservableList();

  @observable
  ObservableList<Sex> selectedSexPreferences = ObservableList();

  @observable
  RelationshipGoal? selectedRelationshipGoal;

  @observable
  PoliticalView? selectedPoliticalView;

  @observable
  Occupation? occupation;

  @observable
  String selectedCountry = '';

  @observable
  Sex? sex;

  @observable
  ObservableList<Religion> selectedReligionPreferences = ObservableList();

  @observable
  XFile? profileImage;

  @action
  void selectCountry(String country) {
    selectedCountry = country;
  }

  @action
  void selectRelationshipGoal(RelationshipGoal goal) {
    selectedRelationshipGoal = goal;
  }

  @action
  void selectPoliticalView(PoliticalView view) {
    selectedPoliticalView = view;
  }

  @action
  void setAgeValues(RangeValues values) {
    ageValues = values;
  }

  @action
  void selectPoliticalViewPreference({
    required bool selected,
    required PoliticalView view,
  }) {
    if (selected) {
      selectedPoliticalViewPreferences.add(view);
    } else {
      selectedPoliticalViewPreferences.remove(view);
    }
  }

  @action
  void selectSexPreference({
    required bool selected,
    required Sex sex,
  }) {
    if (selected) {
      selectedSexPreferences.add(sex);
    } else {
      selectedSexPreferences.remove(sex);
    }
  }

  @action
  void selectSex(Sex selectedSex) {
    sex = selectedSex;
  }

  @action
  void selectBodyTypePreference({
    required bool selected,
    required BodyType bodyType,
  }) {
    if (selected) {
      selectedBodyTypePreferences.add(bodyType);
    } else {
      selectedBodyTypePreferences.remove(bodyType);
    }
  }

  @action
  void selectReligionPreference({
    required bool selected,
    required Religion religion,
  }) {
    if (selected) {
      selectedReligionPreferences.add(religion);
    } else {
      selectedReligionPreferences.remove(religion);
    }
  }

  @action
  void selectRelationshipGoalPreference({
    required bool selected,
    required RelationshipGoal goal,
  }) {
    if (selected) {
      selectedRelationshipGoalPreferences.add(goal);
    } else {
      selectedRelationshipGoalPreferences.remove(goal);
    }
  }

  @action
  void selectHobby({
    required bool selected,
    required Hobby hobby,
    required BuildContext context,
  }) {
    if (selected) {
      if (selectedHobbies.length < 4) {
        selectedHobbies.add(hobby);
      } else {
        context.showSnackBarError(
          message: 'You can only select up to 4 hobbies.',
        );
      }
    } else {
      selectedHobbies.remove(hobby);
    }
  }

  @action
  void selectReligion(Religion selectedReligion) {
    religion = selectedReligion;
  }

  @action
  void selectOccupation(Occupation selectedOccupation) {
    occupation = selectedOccupation;
  }

  Future<void> getHobbies() async {
    final Response<dynamic> response = await dio.get('$server/api/hobbies');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Hobby hobby = Hobby.fromMap(data[index]);

        if (!groupedHobbies.containsKey(hobby.type)) {
          groupedHobbies[hobby.type] = [];
        }

        groupedHobbies[hobby.type]!.add(hobby);
      }
    }
  }

  Future<void> getRelationshipGoals() async {
    final Response<dynamic> response = await dio.get('$server/api/relationship-goals');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final RelationshipGoal goal = RelationshipGoal.fromMap(data[index]);
        relationshipGoals.add(goal);
      }
    }
  }

  Future<void> getPoliticalViews() async {
    final Response<dynamic> response = await dio.get('$server/api/political-views');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final PoliticalView view = PoliticalView.fromMap(data[index]);
        politicalViews.add(view);
      }
    }
  }

  Future<void> getSexes() async {
    final Response<dynamic> response = await dio.get('$server/api/sexes');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Sex sex = Sex.fromMap(data[index]);
        sexes.add(sex);
      }
    }
  }

  Future<void> getBodyTypes() async {
    final Response<dynamic> response = await dio.get('$server/api/body-types');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BodyType bodyType = BodyType.fromMap(data[index]);
        bodyTypes.add(bodyType);
      }
    }
  }

  @action
  Future<void> getReligions() async {
    final Response<dynamic> response = await dio.get('$server/api/religions');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Religion religion = Religion.fromMap(data[index]);
        religions.add(religion);
      }
    }
  }

  @action
  Future<void> getOccupations() async {
    final Response<dynamic> response = await dio.get('$server/api/occupations');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Occupation occupation = Occupation.fromMap(data[index]);
        occupations.add(occupation);
      }
    }
  }

  @action
  Future<void> pickProfileImage() async {
    profileImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
  }

  Future<void> onDone(BuildContext context) async {
    final double height = double.parse(heightController.text.replaceAll(',', '.'));
    final double weight = double.parse(weightController.text.replaceAll(',', '.'));

    user = UserModel(
      uid: authService.getUser().uid,
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      height: height,
      weight: weight,
      religion: religion!.name,
      politicalView: selectedPoliticalView!.name,
      relationshipGoal: selectedRelationshipGoal!.name,
      sex: sex!.name,
      occupation: occupation!.name,
      imageUrl: profileImage?.path,
      country: selectedCountry,
      bio: bioController.text.trim(),
      age: DateTime.now().year - birthDay!.year,
      birthdayDate: birthDay,
      hobbies: selectedHobbies,
      swipes: 20,
      active: true,
      preferences: Preferences(
        sexes: selectedSexPreferences,
        relationshipGoals: selectedRelationshipGoalPreferences,
        politicalViews: selectedPoliticalViewPreferences,
        bodyTypes: selectedBodyTypePreferences,
        religions: selectedReligionPreferences,
        minAge: ageValues.start,
        maxAge: ageValues.end,
      ),
    );

    if (await databaseService.createUser(user!) == DatabaseStatus.successful) {
      await Modular.to.pushReplacementNamed('/home/');
    } else {
      context.showSnackBarError(
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
