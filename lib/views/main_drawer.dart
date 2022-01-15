import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/drawer/main_drawer_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

// import '../../assets/drawer_list.dart';
import 'page_layer.dart';

/// Main Drawer Widget
class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
// Widget _mainDrawer(String origPageName, BuildContext context) {
    return Consumer<MainDrawerProvider>(builder: (BuildContext context,
        MainDrawerProvider mainDrawerProvider, Widget? child) {
      mainDrawerProvider.getMenu();
      return Drawer(
          child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Header',
                // style: textTheme.headline6,
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            // ListView(
            for (final drawerItem in mainDrawerProvider.drawerTree)
              ListTile(
                // leading: Icon(Icons.favorite),
                title: Text(drawerItem['drawerItem'] ?? ''),
                // selected: _selectedDestination == drawerItem['num'],
                onTap: () {
                  mainDrawerProvider.pageName = drawerItem['pageName'];
                  //mainDrawerProvider.getMenu();
                  _selectDestination(drawerItem['num'], context);
                },
              )

            //]
            //),
          ]));
    });
  }

  void _selectDestination(String? index, BuildContext context) {
    log('data: $index');
    if (index == null) return;
    switch (index) {
      case '0':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
        break;
      case '1':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
        break;
    }
  }
}
