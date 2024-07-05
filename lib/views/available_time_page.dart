import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/view_models/available_time_vm.dart';
import 'package:task_management_app/view_models/me_vm.dart';
import 'package:task_management_app/models/available_time.dart';

class AvailableTimePage extends StatefulWidget {
  const AvailableTimePage({Key? key}) : super(key: key);

  @override
  _AvailableTimePageState createState() => _AvailableTimePageState();
}

class _AvailableTimePageState extends State<AvailableTimePage> {
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> times = [
    '1AM', '2AM', '3AM', '4AM', '5AM', '6AM', '7AM', '8AM', '9AM', '10AM', 
    '11AM', '12AM', '1PM', '2PM', '3PM', '4PM', '5PM', '6PM', '7PM', '8PM', 
    '9PM', '10PM', '11PM', '12PM'
  ];
  List<Color> numColors = [
    Colors.white, Colors.purple, Colors.blue, Colors.green,
    Colors.yellow, Colors.orange,
  ];
  late List<List<int>> availableData;
  late List<List<bool>> hasClicked;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    availableData = AvailableTime.createEmpty().availableData; 
    hasClicked = List.generate(times.length, (day) => List<bool>.filled(days.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MeViewModel, AvailableTimeViewModel>(
      builder: (context, meViewModel, availableTimeViewModel, child) {
        if (meViewModel.me == null || availableTimeViewModel.isInitializing
         || availableTimeViewModel.availableTime == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        availableData = availableTimeViewModel.availableTime!.availableData;
        hasClicked = meViewModel.me!.hasAvailableTime;
        isLoading = false;

        return SingleChildScrollView(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : buildContent(),
          );
        
      },
    );
  }

   Widget buildContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Available Time',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            horizontalMargin: 0,
            columnSpacing: 0,
            columns: [
              const DataColumn(label: Text('Time/Day')),
              for (String day in days) DataColumn(label: Text(day)),
            ],
            rows: List<DataRow>.generate(
              times.length,
              (day) => DataRow(
                cells: [
                  DataCell(
                    Text(times[day]),
                  ),
                  for (int t = 0; t < days.length; t++)
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          _handleCellTap(day, t);
                        },
                        child: Container(
                          constraints: const BoxConstraints.expand(),
                          decoration: BoxDecoration(
                            border: hasClicked[day][t]
                                ? Border.all(color: Colors.red, width: 3)
                                : Border.all(color: Colors.black, width: 3),
                            color: numColors[availableData[day][t].clamp(0, numColors.length - 1)],
                          ),
                          child: Center(
                            child: Text(
                              availableData[day][t].toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleCellTap(int day, int t) {
    setState(() {
      if (hasClicked[day][t]) {
        availableData[day][t]--;
      } else {
        availableData[day][t]++;
      }
      hasClicked[day][t] = !hasClicked[day][t];
      Provider.of<MeViewModel>(context, listen: false).updateAvailableTime(hasClicked);
      // Provider.of<AvailableTimeViewModel>(context, listen: false).updateAvailableTime(AvailableTime(availableData: availableData));
    });
  }

}