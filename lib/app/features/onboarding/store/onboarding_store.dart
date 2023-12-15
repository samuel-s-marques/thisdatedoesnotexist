import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mobx/mobx.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/enum/database_status_enum.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/pronoun_model.dart';
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
  TextEditingController occupationController = TextEditingController();

  @observable
  TextEditingController birthdayController = TextEditingController();

  @observable
  DateTime? birthDay;

  @action
  Future<void> selectBirthday(BuildContext context) async {
    final DateTime minDate = DateTime(DateTime.now().year - 18);
    final DateTime maxDate = DateTime(DateTime.now().year - 70);
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
  RangeValues ageValues = const RangeValues(18, 70);

  @observable
  ObservableList<Hobby> selectedHobbies = ObservableList();

  @observable
  ObservableMap<String, List<Hobby>> groupedHobbies = ObservableMap();

  @observable
  ObservableList<BaseModel> relationshipGoals = ObservableList();

  @observable
  ObservableList<BaseModel> politicalViews = ObservableList();

  @observable
  ObservableList<BaseModel> bodyTypes = ObservableList();

  @observable
  ObservableList<BaseModel> religions = ObservableList();

  @observable
  ObservableList<BaseModel> occupations = ObservableList();

  @observable
  BaseModel? religion;

  @observable
  ObservableList<BaseModel> sexes = ObservableList();
  Map<String, String> pluralSexesMap = {'male': 'Men', 'female': 'Women'};
  Map<String, String> singularSexesMap = {'male': 'Man', 'female': 'Woman'};

  @observable
  ObservableList<Pronoun> pronouns = ObservableList();

  @observable
  Pronoun? selectedPronouns;

  @observable
  ObservableList<BaseModel> selectedPoliticalViewPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> selectedBodyTypePreferences = ObservableList();

  @observable
  ObservableList<BaseModel> selectedRelationshipGoalPreferences = ObservableList();

  @observable
  ObservableList<BaseModel> selectedSexPreferences = ObservableList();

  @observable
  BaseModel? selectedRelationshipGoal;

  @observable
  BaseModel? selectedPoliticalView;

  @observable
  BaseModel? occupation;

  @observable
  String selectedCountry = '';

  @observable
  BaseModel? sex;

  @observable
  ObservableList<BaseModel> selectedReligionPreferences = ObservableList();

  @observable
  XFile? profileImage;

  @action
  void selectCountry(String country) {
    selectedCountry = country;
  }

  @action
  void selectRelationshipGoal(BaseModel goal) {
    selectedRelationshipGoal = goal;
  }

  @action
  void selectPoliticalView(BaseModel view) {
    selectedPoliticalView = view;
  }

  @action
  void setAgeValues(RangeValues values) {
    ageValues = values;
  }

  @action
  void setPronouns(Pronoun pronouns) {
    selectedPronouns = pronouns;
  }

  @action
  void selectPoliticalViewPreference({
    required bool selected,
    required BaseModel view,
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
    required BaseModel sex,
  }) {
    if (selected) {
      selectedSexPreferences.add(sex);
    } else {
      selectedSexPreferences.remove(sex);
    }
  }

  @action
  void selectSex(BaseModel selectedSex) {
    sex = selectedSex;
  }

  @action
  void selectBodyTypePreference({
    required bool selected,
    required BaseModel bodyType,
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
    required BaseModel religion,
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
    required BaseModel goal,
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
  void selectReligion(BaseModel selectedReligion) {
    religion = selectedReligion;
  }

  @action
  void selectOccupation(BaseModel selectedOccupation) {
    occupation = selectedOccupation;

    if (occupation != null) {
      occupationController.text = occupation!.name!.capitalize();
    }
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
        final BaseModel goal = BaseModel.fromMap(data[index]);
        relationshipGoals.add(goal);
      }
    }
  }

  Future<void> getPoliticalViews() async {
    final Response<dynamic> response = await dio.get('$server/api/political-views');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel view = BaseModel.fromMap(data[index]);
        politicalViews.add(view);
      }
    }
  }

  Future<void> getSexes() async {
    final Response<dynamic> response = await dio.get('$server/api/sexes');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel sex = BaseModel.fromMap(data[index]);
        sexes.add(sex);
      }
    }
  }

  Future<void> getBodyTypes() async {
    final Response<dynamic> response = await dio.get('$server/api/body-types');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel bodyType = BaseModel.fromMap(data[index]);
        bodyTypes.add(bodyType);
      }
    }
  }

  Future<void> getPronouns() async {
    final Response<dynamic> response = await dio.get('$server/api/pronouns');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final Pronoun pronoun = Pronoun.fromMap(data[index]);
        pronouns.add(pronoun);
      }
    }
  }

  @action
  Future<void> getReligions() async {
    final Response<dynamic> response = await dio.get('$server/api/religions');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      for (int index = 0; index < data.length; index++) {
        final BaseModel religion = BaseModel.fromMap(data[index]);
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
        final BaseModel occupation = BaseModel.fromMap(data[index]);
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
      relationshipGoal: selectedRelationshipGoal,
      sex: sex!.name,
      occupation: occupation!.name,
      imageUrl: profileImage?.path,
      country: selectedCountry,
      pronoun: selectedPronouns,
      bio: bioController.text.trim(),
      age: DateTime.now().year - birthDay!.year,
      hobbies: selectedHobbies,
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
      if (!OneSignal.Notifications.permission) {
        await OneSignal.Notifications.requestPermission(true);
      }

      await Modular.to.pushReplacementNamed('/home/');
    } else {
      context.showSnackBarError(
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
