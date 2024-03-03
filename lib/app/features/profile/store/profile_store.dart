import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mobx/mobx.dart';
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/hobby_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/pronoun_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/data_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/onboarding/services/onboarding_service.dart';
import 'package:thisdatedoesnotexist/app/features/profile/services/profile_service.dart';

part 'profile_store.g.dart';

class ProfileStore = ProfileStoreBase with _$ProfileStore;

abstract class ProfileStoreBase with Store {
  final ProfileService service = Modular.get();
  final String server = Env.server;
  DataService dataService = Modular.get();
  OnboardingService onboardingService = Modular.get();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
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
  bool readyToEdit = false;

  @observable
  bool? allowProfileImage;

  @observable
  TextEditingController occupationController = TextEditingController();

  @observable
  ObservableList<Hobby> selectedHobbies = ObservableList();

  @observable
  ObservableMap<String, List<Hobby>> groupedHobbies = ObservableMap();

  @observable
  ObservableList<BaseModel> relationshipGoals = ObservableList();

  @observable
  ObservableList<BaseModel> politicalViews = ObservableList();

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
  BaseModel? selectedRelationshipGoal;

  @observable
  BaseModel? selectedPoliticalView;

  @observable
  BaseModel? occupation;

  @observable
  DateTime? birthDay;

  @observable
  String selectedCountry = '';

  @observable
  BaseModel? sex;

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
      final ServiceReturn response = await onboardingService.upload(formData);

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
    final Future<ServiceReturn> politicalViewsFuture = dataService.getPoliticalViews();
    final Future<ServiceReturn> relationshipGoalsFuture = dataService.getRelationshipGoals();
    final Future<ServiceReturn> religionsFuture = dataService.getReligions();
    final Future<ServiceReturn> sexesFuture = dataService.getSexes();
    final Future<ServiceReturn> hobbiesFuture = dataService.getHobbies();
    final Future<ServiceReturn> occupationsFuture = dataService.getOccupations();
    final Future<ServiceReturn> pronounsFuture = dataService.getPronouns();

    final (
      politicalViewsData,
      relationshipGoalsData,
      religionsData,
      sexesData,
      hobbiesData,
      occupationsData,
      pronounsData,
    ) = await (
      politicalViewsFuture,
      relationshipGoalsFuture,
      religionsFuture,
      sexesFuture,
      hobbiesFuture,
      occupationsFuture,
      pronounsFuture,
    ).wait;

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

  @action
  Future<UserModel?> getUser() => service.getUser();

  @action
  Future<void> updateUser(UserModel user) => service.updateUser(user);
}
