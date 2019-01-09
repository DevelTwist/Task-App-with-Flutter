import 'package:flutter/material.dart';
import 'package:task_app/models/note.dart';
import 'package:task_app/util/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  
  final Note note;
  final String appBarTitle;
  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note ,this.appBarTitle);
  }


}

class NoteDetailState extends State<NoteDetail> {

  static var _priorities = ["High","Medium","Low"];


  DbHelper helper = DbHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String appBarTitle;
  Note note;
  NoteDetailState(this.note,this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

      onWillPop: (){
        moveToLastScreen();
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(
            Icons.arrow_back),
            onPressed: (){
              moveToLastScreen();
            },
          ),
      ),

      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[

            ListTile(
              title: DropdownButton(
                items: _priorities.map( (String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                style: textStyle,
                value: getPriorityAsString(note.priority),
                onChanged: (value){
                  setState(() {
                      debugPrint('User selected $value');
                      updatePriorityAsInt(value);
                      });
                },
              ),
              leading: Icon(Icons.priority_high, color: Colors.teal,),
              subtitle: Text('Select Priority'),
            ),


            //Second Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in Title Text Field');
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter Title',
                  hintStyle: Theme.of(context).textTheme.body1,
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),


            // Third Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in Title Text Field');
                  updateDescription();
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter Description',
                  hintStyle: Theme.of(context).textTheme.body1,
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),

            // Fourth Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Save',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: (){
                        setState(() {
                                    debugPrint("Save button clicked");   
                                    _save();           
                              });
                      },
                    ),
                  ),

                  Container(width: 5.0,),

                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Delete',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: (){
                        setState(() {
                                    debugPrint("Delete button clicked"); 
                                    _delete();             
                              });
                      },
                    ),
                  ),


                ],
              ),
            ),


          ],
        ),
      ),
    ));
  }

   void moveToLastScreen(){
      Navigator.pop(context, true);
    }

    void updatePriorityAsInt(String value){
      switch(value){
        case 'High':
          note.priority = 1;
          break;
        case 'Medium':
          note.priority = 2;
          break;
        case 'Low':
          note.priority = 3;
          break;
      }
    }

    void _delete() async {

      moveToLastScreen();

      if(note.id == null){
        _showAlertDialog('Status', 'No Task was deleted');
        return;
      }
      int result = await helper.deleteNote(note.id);
      if(result != 0 ){
        _showAlertDialog('Status', 'Task Deleted Successfully');
      }else{
        _showAlertDialog('Status', 'Error Occured while DEleting Task');
      }
    }

    String getPriorityAsString(int value){
      String priority;
      switch(value) {
        case 1:
          priority = _priorities[0];
          break;
        case 2:
          priority = _priorities[1];
          break;
        case 3:
          priority = _priorities[2];
          break;
      }
      return priority;
    }

    void updateTitle(){
      note.title = titleController.text;
    }

    void updateDescription(){
      note.description = descriptionController.text;
    }

    void _save() async {

      moveToLastScreen();
      note.date =  DateFormat.yMMMd().format(DateTime.now());

      int result;
      if(note.id != null){
        result = await helper.updateNote(note);
      }else{
        result = await helper.insertNote(note);
      }

      if(result != 0){
        _showAlertDialog('Status','Note Saved Successfully');
      }else {
        _showAlertDialog('Status','Problem Saving Note');
      }
    }

    void _showAlertDialog(String title, String message){

      AlertDialog alertDialog = AlertDialog(
        title: Text(title),
        content: Text(message),
      );
      showDialog(
        context: context,
        builder: (_) => alertDialog
      );

    }


}