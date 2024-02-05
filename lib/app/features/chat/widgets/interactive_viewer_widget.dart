import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gal/gal.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

class InteractiveViewerWidget extends StatelessWidget {
  const InteractiveViewerWidget({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              if (!await Gal.hasAccess()) {
                await Gal.requestAccess();
              }

              try {
                final Repository repository = Modular.get();
                final String path = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.png';

                await repository.download(imageUrl, path);
                await Gal.putImage(path);

                context.showSnackBarSuccess(message: 'Image downloaded successfully!');
              } on GalException catch (e) {
                if (kDebugMode) {
                  print(e);
                }
                context.showSnackBarError(message: 'Error downloading image! ${e.type.message}');
              } catch (e) {
                if (kDebugMode) {
                  print(e);
                }
                context.showSnackBarError(message: 'Error downloading image!');
              }
            },
          )
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
