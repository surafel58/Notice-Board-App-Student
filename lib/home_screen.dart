import 'package:digital_notice_board/screen_arguments.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ListResult> futureFiles;
  Map<int, double> downloadProgress = {};

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseStorage.instance.ref('/Registrar files').listAll();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    Permission.storage.request();

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.logout),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Signed in as:    ${user.email!}"),
              const SizedBox(
                height: 4,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        leading: Text(Departments[index]),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/detailscreen',
                          arguments: ScreenArguments(
                              filePath: '/${Departments[index]}'),
                        ),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  FutureBuilder<ListResult> buildFileList(Future<ListResult> futureFiles) {
    return FutureBuilder<ListResult>(
        future: futureFiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final files = snapshot.data!.items;

            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  //get specific file
                  final file = files[index];

                  double? progress = downloadProgress[index];

                  return ListTile(
                    title: Text(file.name),
                    subtitle: progress != null
                        ? LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.black,
                          )
                        : null,
                    trailing: IconButton(
                      onPressed: () => downloadFile(index, file),
                      icon: const Icon(Icons.download),
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            return const Center(child: Text("An Error has occurred"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  downloadFile(int index, Reference file) async {
    final url = await file.getDownloadURL();
    final path = '/storage/emulated/0/Download/${file.name}';
    await Dio().download(url, path, onReceiveProgress: (received, total) {
      double progress = received / total;
      setState(() {
        downloadProgress[index] = progress;
      });
    });

    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains('.jpg')) {
      await GallerySaver.saveImage(path, toDcim: true);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloaded ${file.name}')),
    );
  }
}
