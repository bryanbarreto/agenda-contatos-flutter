import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact editedContact;
  bool userEdited = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final phoneFocus = FocusNode();
  final nameFocus = FocusNode();

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    return pickedFile;
  }

  Future<bool> requestPop() {
    if (userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Atenção"),
              content: Text(
                  "As informações não foram salvas. Deseja realmente sair?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text(
                    "Continuar",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      editedContact = Contact();
    } else {
      editedContact = Contact.fromMap(widget.contact.toMap());
      nameController.text = editedContact.name;
      emailController.text = editedContact.email;
      phoneController.text = editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
          onPressed: () {
            if (editedContact.phone != null &&
                editedContact.phone.isNotEmpty &&
                editedContact.name != null &&
                editedContact.name.isNotEmpty) {
              Navigator.pop(context, editedContact);
            } else if (editedContact.phone == null ||
                editedContact.phone.isEmpty) {
              FocusScope.of(context).requestFocus(phoneFocus);
            } else if (editedContact.name == null ||
                editedContact.name.isEmpty) {
              FocusScope.of(context).requestFocus(nameFocus);
            }
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  getImage().then((file) {
                    setState(() {
                      editedContact.img = file.path;
                    });
                  });
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: editedContact.img != null
                          ? FileImage(File(editedContact.img))
                          : AssetImage("images/person.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text) {
                  userEdited = true;
                  setState(() {
                    editedContact.name = text;
                  });
                },
                focusNode: nameFocus,
              ),
              TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Telefone"),
                  onChanged: (text) {
                    editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                  focusNode: phoneFocus),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
