import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mobx/mobx.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/pronoun_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/data_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/services/onboarding_service.dart';

part 'onboarding_store.g.dart';

class OnboardingStore = OnboardingStoreBase with _$OnboardingStore;

abstract class OnboardingStoreBase with Store {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  OnboardingService service = Modular.get();
  DataService dataService = Modular.get();
  FlutterSecureStorage storage = const FlutterSecureStorage();
  final ImagePicker imagePicker = ImagePicker();
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
  bool? allowProfileImage;

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
  String? profileImagePath;

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
  void selectSex(BaseModel selectedSex) {
    sex = selectedSex;
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

  @action
  Future<void> selectPreference({
    required bool selected,
    required BaseModel preference,
    required List<BaseModel> list,
  }) async {
    if (selected) {
      list.add(preference);
    } else {
      list.remove(preference);
    }
  }

  @action
  Future<void> pickProfileImage(BuildContext context) async {
    final XFile? profileImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (profileImage == null) {
      allowProfileImage = null;
      profileImagePath = null;
      return;
    }

    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: profileImage.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.original,
      ],
    );

    if (croppedImage == null) {
      allowProfileImage = null;
      profileImagePath = null;
      return;
    }

    profileImagePath = croppedImage.path;

    final FormData formData = FormData.fromMap({
      'profile_image': await MultipartFile.fromFile(croppedImage.path),
    });

    try {
      final ServiceReturn response = await service.upload(formData);

      if (response.success) {
        allowProfileImage = true;
        return;
      }

      context.showSnackBarError(
        message: 'This image is not allowed. Please, choose another one.',
      );
      allowProfileImage = false;

      return;
    } catch (e) {
      context.showSnackBarError(message: 'Something went wrong. Please try again.');
    }
  }

  Future<void> getData() async {
    final Future<ServiceReturn> bodyTypesFuture = dataService.getBodyTypes();
    final Future<ServiceReturn> politicalViewsFuture = dataService.getPoliticalViews();
    final Future<ServiceReturn> relationshipGoalsFuture = dataService.getRelationshipGoals();
    final Future<ServiceReturn> religionsFuture = dataService.getReligions();
    final Future<ServiceReturn> sexesFuture = dataService.getSexes();
    final Future<ServiceReturn> hobbiesFuture = dataService.getHobbies();
    final Future<ServiceReturn> occupationsFuture = dataService.getOccupations();
    final Future<ServiceReturn> pronounsFuture = dataService.getPronouns();

    final (
      bodyTypesData,
      politicalViewsData,
      relationshipGoalsData,
      religionsData,
      sexesData,
      hobbiesData,
      occupationsData,
      pronounsData,
    ) = await (
      bodyTypesFuture,
      politicalViewsFuture,
      relationshipGoalsFuture,
      religionsFuture,
      sexesFuture,
      hobbiesFuture,
      occupationsFuture,
      pronounsFuture,
    ).wait;

    if (bodyTypesData.success) {
      final List<dynamic> data = bodyTypesData.data;
      bodyTypes.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (politicalViewsData.success) {
      final List<dynamic> data = politicalViewsData.data;
      politicalViews.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (relationshipGoalsData.success) {
      final List<dynamic> data = relationshipGoalsData.data;
      relationshipGoals.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (religionsData.success) {
      final List<dynamic> data = religionsData.data;
      religions.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (sexesData.success) {
      final List<dynamic> data = sexesData.data;
      sexes.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (hobbiesData.success) {
      final List<dynamic> data = hobbiesData.data;

      for (int index = 0; index < data.length; index++) {
        final Hobby hobby = Hobby.fromMap(data[index]);

        if (!groupedHobbies.containsKey(hobby.type)) {
          groupedHobbies[hobby.type] = [];
        }

        groupedHobbies[hobby.type]!.add(hobby);
      }
    }

    if (occupationsData.success) {
      final List<dynamic> data = occupationsData.data;
      occupations.addAll(data.map((e) => BaseModel.fromMap(e)).toList());
    }

    if (pronounsData.success) {
      final List<dynamic> data = pronounsData.data;
      pronouns.addAll(data.map((e) => Pronoun.fromMap(e)).toList());
    }
  }

  Future<void> onDone(BuildContext context) async {
    final double height = double.parse(heightController.text.replaceAll(',', '.'));
    final double weight = double.parse(weightController.text.replaceAll(',', '.'));

    user = UserModel(
      uid: await storage.read(key: 'uid') ?? '',
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      height: height,
      weight: weight,
      religion: religion!.name,
      politicalView: selectedPoliticalView!.name,
      relationshipGoal: selectedRelationshipGoal,
      sex: sex!.name,
      occupation: occupation!.name,
      imageUrl: profileImagePath,
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

    final ServiceReturn response = await service.createUser(user!);

    if (response.success) {
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
