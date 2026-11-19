import 'package:breakpoint_builder/breakpoint_builder.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: DemoPage()));

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(mobile: 1, tablet: 2, desktop: 4);
    return Scaffold(
      appBar: AppBar(
          title: Text('breakpoint_builder · ${context.screenSize.name}')),
      drawer: context.isMobile
          ? const Drawer(child: Center(child: Text('Menu')))
          : null,
      body: Row(
        children: [
          if (!context.isMobile)
            NavigationRail(
              selectedIndex: 0,
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.dashboard), label: Text('Home')),
                NavigationRailDestination(
                    icon: Icon(Icons.map), label: Text('Map')),
              ],
            ),
          Expanded(
            child: GridView.count(
              crossAxisCount: columns,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                for (var i = 1; i <= 12; i++)
                  Card(child: Center(child: Text('Card $i'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
