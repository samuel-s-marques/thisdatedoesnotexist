import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/services/report_service.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/section_widget.dart';
import 'package:thisdatedoesnotexist/app/features/home/store/home_store.dart';

class CardWidget extends StatelessWidget {
  CardWidget({
    super.key,
    required this.character,
    required this.imageUrl,
    required this.homeStore,
  });

  final UserModel character;
  final String imageUrl;
  final HomeStore homeStore;
  final ReportService reportService = Modular.get();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            onPressed: () => reportService.report(characterUid: character.uid, context: context),
            iconSize: 28,
            icon: const Icon(
              Icons.report,
              color: Colors.white,
            ),
          ),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              initialChildSize: 0.09,
              minChildSize: 0.09,
              maxChildSize: 0.9,
              expand: false,
              builder: (BuildContext context, ScrollController scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(fontSize: 20),
                                  children: [
                                    TextSpan(
                                      text: '${character.name} ${character.surname}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ', ',
                                    ),
                                    TextSpan(
                                      text: character.age.toString(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(getGenderIconByName(character.sex!)),
                                  const SizedBox(width: 5),
                                  Text(
                                    replaceGender(character.sex!).capitalize(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.straighten_outlined),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${character.height!.toStringAsFixed(2)} m, ${character.weight!.toStringAsFixed(2)} kg',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.work_outline),
                                  const SizedBox(width: 5),
                                  Text(
                                    character.occupation!.name!.capitalize(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.campaign_outlined),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Uses ${character.pronoun!.subjectPronoun}/${character.pronoun!.objectPronoun} pronouns',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.home_outlined),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Lives in ${character.country!} ${countryNameToEmoji(character.country!)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SectionWidget(
                                padding: const EdgeInsets.only(top: 20, bottom: 10),
                                title: 'About me',
                                content: Text(
                                  character.bio?.trim() ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              SectionWidget(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                title: 'Hobbies & Interests',
                                content: Wrap(
                                  spacing: 5,
                                  children: character.hobbies!
                                      .map(
                                        (hobby) => Chip(
                                          padding: EdgeInsets.zero,
                                          label: Text(
                                            hobby.name.capitalize(),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              SectionWidget(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                title: 'Relationship Goal',
                                content: Text(
                                  character.relationshipGoal?.name!.capitalize() ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              SectionWidget(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                title: 'Political View',
                                content: Text(
                                  character.politicalView?.capitalize() ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              SectionWidget(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                title: 'Religion',
                                content: Text(
                                  character.religion?.capitalize() ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
