import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class ReportedCharactersPage extends StatelessWidget {
  ReportedCharactersPage({super.key});

  final SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Characters'),
      ),
      body: FutureBuilder(
        future: store.getReportedCharacters(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                ListView.builder(
                  itemCount: snapshot.data.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> data = snapshot.data['data'][index];
                    final String type = data['type'];
                    final UserModel character = UserModel.fromMap(data['character']);

                    return ListTile(
                      title: Text('${character.name} ${character.surname}'),
                      subtitle: Text('Reported for $type'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider('${store.server}/uploads/characters/${character.uid}.png'),
                          )
                        ],
                      ),
                      onTap: () {},
                    );
                  },
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
