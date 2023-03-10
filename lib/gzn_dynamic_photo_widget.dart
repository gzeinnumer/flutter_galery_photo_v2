// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DynamicPhoto {
  final String path;
  final String base64;

  DynamicPhoto(
    this.path,
    this.base64,
  );
}

/*
DynamicPhotoWidget(
  (res) {
    this.res = res;
    // print("zein_${this.res.length}");
    for (int i = 0; i < res.length; i++) {
      print("zein_" + res[i].path);
    }
  },
  centerWidget: true,
  // max: 3,
  max: this.res.length,
  askBeforeDelete: true,
  showDebug: true,
  displayOnly: true,
  resLastData: res,
  labelPhotoPicker: "",
  labelChangePicture: "",
  labelSubmit: "",
  labelOk: "",
  labelCancel: "",
  enableCamera: false,
  enableGalery: false,
),

 */

class DynamicPhotoWidget extends StatefulWidget {
  Function(List<DynamicPhoto> res) res;
  List<DynamicPhoto> resLastData;
  int max;
  bool askBeforeDelete;
  bool centerWidget;

  bool enableCamera;
  bool enableGalery;

  // String path;

  String labelPhotoPicker;
  String labelSubmit;
  String labelCancel;
  String labelOk;
  String labelChangePicture;

  bool showDebug;
  bool displayOnly;

  DynamicPhotoWidget(
    this.res, {
    Key? key,
    this.max = -1,
    this.askBeforeDelete = false,
    this.centerWidget = false,
    this.enableCamera = true,
    this.enableGalery = true,
    // this.path = "",
    this.labelPhotoPicker = 'Photo Picker',
    this.labelSubmit = 'Submit',
    this.labelCancel = 'Cancel',
    this.labelOk = 'Ok',
    this.labelChangePicture = 'Change Picture?',
    this.showDebug = false,
    this.displayOnly = false,
    this.resLastData = const [],
  }) : super(key: key);

  @override
  State<DynamicPhotoWidget> createState() => _DynamicPhotoWidgetState();
}

class _DynamicPhotoWidgetState extends State<DynamicPhotoWidget> {
  List<DynamicPhoto> path = <DynamicPhoto>[];

  void _pickPhoto() {
    showDialog(
      context: context,
      builder: (context) => _PhotoPickerDialog(
        enableCamera: widget.enableCamera,
        enableGalery: widget.enableGalery,
        // path: widget.path,
        labelPhotoPicker: widget.labelPhotoPicker,
        labelSubmit: widget.labelSubmit,
        labelCancel: widget.labelCancel,
        labelOk: widget.labelOk,
        labelChangePicture: widget.labelChangePicture,
        showDebug: widget.showDebug,
        enableDelete: widget.displayOnly,
      ),
    ).then((value) {
      if (value == null) return;
      setState(() {
        String base64 = "data:image/png;base64,${base64Encode(File(value).readAsBytesSync())}";
        path.insert(0, DynamicPhoto(value, base64));
        List<DynamicPhoto> res = List.from(path);
        res.removeLast();
        widget.res(res);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resLastData.isNotEmpty) {
      path = List.from(widget.resLastData);
    }
    if(widget.displayOnly == false){
      path.add(DynamicPhoto("", ""));
    }
    return SizedBox(
      height: 58,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: path.length,
        shrinkWrap: widget.centerWidget,
        itemBuilder: (BuildContext context, int index) {
          if (index == path.length - 1 && widget.displayOnly == false) {
            if (path.length - 1 == widget.max) {
              return Container();
            }
            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              margin: const EdgeInsets.all(4),
              width: 50,
              height: 50,
              child: InkWell(
                onTap: _pickPhoto,
                child: const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            margin: const EdgeInsets.all(4),
            width: 50,
            height: 50,
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => _PreviewImageDialog(
                        path[index],
                        showDebug: widget.showDebug,
                      ),
                    );
                  },
                  child: path[index].path.contains("http")
                      ? ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: Image.network(
                            path[index].path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: Image.file(
                            File(path[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
                if (widget.displayOnly == false)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(23, 23),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (widget.askBeforeDelete) {
                          showDialog(
                            context: context,
                            builder: (context) => const _ConfirmDeletePhotoDialog(),
                          ).then((value) {
                            if (value == null) return;
                            if (value) {
                              deleteItem(index);
                            }
                          });
                        } else {
                          deleteItem(index);
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void deleteItem(int index) {
    path.removeAt(index);
    List<DynamicPhoto> res = List.from(path);
    res.removeLast();
    widget.res(res);
    setState(() {});
  }
}

class _PhotoPickerDialog extends StatefulWidget {
  bool enableCamera;
  bool enableGalery;
  File? _image;
  String path;

  String labelPhotoPicker;
  String labelSubmit;
  String labelCancel;
  String labelOk;
  String labelChangePicture;
  bool showDebug;
  bool enableDelete;

  _PhotoPickerDialog({
    Key? key,
    this.enableCamera = true,
    this.enableGalery = true,
    this.path = "",
    required this.labelPhotoPicker,
    required this.labelSubmit,
    required this.labelCancel,
    required this.labelOk,
    required this.labelChangePicture,
    required this.showDebug,
    required this.enableDelete,
  }) : super(key: key);

  @override
  State<_PhotoPickerDialog> createState() => _PhotoPickerDialogState();
}

class _PhotoPickerDialogState extends State<_PhotoPickerDialog> {
  Future pickImageGalery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        widget._image = imageTemp;
        widget.path = imageTemp.path;
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to pick image : $e"),
      ));
    }
  }

  Future pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        widget._image = imageTemp;
        widget.path = imageTemp.path;
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to pick image : $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      elevation: 0.0,
      content: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    children: [
                      Text(widget.labelPhotoPicker),
                      if (widget.showDebug) Text(widget.path),
                      widget._image != null
                          ? widget.path.toString().contains("http")
                              ? Container(margin: const EdgeInsets.only(top: 16), child: Image.network(widget.path))
                              : Container(margin: const EdgeInsets.only(top: 16), child: Image.file(widget._image!))
                          : Container(),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.enableCamera
                                ? InkWell(
                                    onTap: () {
                                      widget.path.isEmpty ? pickImageCamera() : confirmChangePhoto(1);
                                    },
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Container(),
                            widget.enableCamera && widget.enableGalery ? const SizedBox(width: 16) : Container(),
                            widget.enableGalery
                                ? InkWell(
                                    onTap: () {
                                      widget.path.isEmpty ? pickImageGalery() : confirmChangePhoto(2);
                                    },
                                    child: Icon(
                                      Icons.photo_library_rounded,
                                      size: 40,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Container(),
                            if (widget.path.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 16.0),
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context, widget.path);
                                  },
                                  child: Text(widget.labelSubmit),
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.only(left: 16.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context, null);
                                },
                                child: Text(widget.labelCancel),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  confirmChangePhoto(int type) {
    //1 -> CAMERA
    //2 -> GALERY
    showDialog(
      context: context,
      builder: (context) => _ConfirmUpdatePhotoDialog(
        labelChangePicture: widget.labelChangePicture,
        labelOk: widget.labelOk,
        labelCancel: widget.labelCancel,
      ),
    ).then((value) {
      if (value == null) return;
      if (value == 1) {
        if (type == 1) {
          pickImageCamera();
        } else if (type == 2) {
          pickImageGalery();
        }
      }
    });
  }
}

class _PreviewImageDialog extends StatelessWidget {
  DynamicPhoto data;
  bool showDebug;

  _PreviewImageDialog(
    this.data, {
    Key? key,
    required this.showDebug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      elevation: 0.0,
      content: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(
                width: width * 0.9,
                height: height * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(23, 23),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: data.path.contains("http")
                          ? Image.network(
                              data.path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.file(
                              File(data.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                    if (showDebug) const SizedBox(height: 10),
                    if (showDebug)
                      Text(
                        data.path,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    if (showDebug) const SizedBox(height: 10),
                    if (showDebug)
                      Text(
                        data.base64.substring(0, 60),
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _ConfirmDeletePhotoDialog extends StatelessWidget {
  const _ConfirmDeletePhotoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      elevation: 0.0,
      content: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            children: [
              const Text(
                'Warning',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Delete photo?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class _ConfirmUpdatePhotoDialog extends StatelessWidget {
  String labelChangePicture;
  String labelOk;
  String labelCancel;

  _ConfirmUpdatePhotoDialog({
    Key? key,
    required this.labelChangePicture,
    required this.labelOk,
    required this.labelCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      elevation: 0.0,
      content: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Column(
                      children: [
                        Text(labelChangePicture),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 0);
                                },
                                child: Text(labelCancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 1);
                                },
                                child: Text(labelOk),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
