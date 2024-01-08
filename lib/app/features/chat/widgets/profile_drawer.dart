import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/core/widgets/section_widget.dart';
import 'package:thisdatedoesnotexist/app/features/chat/store/chat_store.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/interactive_viewer_widget.dart';

class ProfileDrawer extends StatelessWidget {
  ProfileDrawer({super.key});

  final ChatStore store = Modular.get<ChatStore>();

  @override
  Widget build(BuildContext context) {
    final String image = '${store.server}/uploads/characters/${store.character!.uid}.png';

    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.9,
                width: MediaQuery.of(context).size.width,
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(
                      width: 0.5,
                      color: Colors.black26,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => Modular.to.push(
                      MaterialPageRoute(
                        builder: (_) => InteractiveViewerWidget(
                          imageUrl: image,
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${store.character!.name} ${store.character!.surname}',
                    ),
                    const TextSpan(
                      text: ', ',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: store.character!.age.toString(),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (store.character!.status != 'normal')
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: store.character!.status == 'banned' ? Colors.red : Colors.yellow,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'This character was ${store.character!.status} for ${store.character!.statusReason}.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: store.character!.status == 'banned' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              Wrap(
                runSpacing: 5,
                children: [
                  Row(
                    children: [
                      Icon(getGenderIconByName(store.character!.sex!)),
                      const SizedBox(width: 5),
                      Text(
                        replaceGender(store.character!.sex!).capitalize(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.straighten_outlined),
                      const SizedBox(width: 5),
                      Text(
                        '${store.character!.height!.toStringAsFixed(2)} m, ${store.character!.weight!.toStringAsFixed(2)} kg',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.work_outline),
                      const SizedBox(width: 5),
                      Text(
                        store.character!.occupation!.capitalize(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.campaign_outlined),
                      const SizedBox(width: 5),
                      Text(
                        'Uses ${store.character!.pronoun!.subjectPronoun}/${store.character!.pronoun!.objectPronoun} pronouns',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.home_outlined),
                      const SizedBox(width: 5),
                      Text(
                        'Lives in ${store.character!.country!} ${countryNameToEmoji(store.character!.country!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SectionWidget(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                title: 'About me',
                content: Text(
                  store.character!.bio?.trim() ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              SectionWidget(
                padding: const EdgeInsets.symmetric(vertical: 10),
                title: 'Hobbies & Interests',
                content: Wrap(
                  spacing: 5,
                  children: store.character!.hobbies!
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
                  store.character!.relationshipGoal?.name!.capitalize() ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              SectionWidget(
                padding: const EdgeInsets.symmetric(vertical: 10),
                title: 'Political View',
                content: Text(
                  store.character!.politicalView?.capitalize() ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              SectionWidget(
                padding: const EdgeInsets.symmetric(vertical: 10),
                title: 'Religion',
                content: Text(
                  store.character!.religion?.capitalize() ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
