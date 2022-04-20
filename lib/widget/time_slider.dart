import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:multi_flutter_circular_slider/multi_flutter_circular_slider.dart';
import 'package:gestione_domotica/models/stati/stati_layer.dart';
import 'package:gestione_domotica/models/timer/timer_attivazione.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';

class TimeSlider extends StatefulWidget {
  TimeSlider({Key? key, required this.stato, this.child}) : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  Widget? child;
  StatoModel stato;

  @override
  _TimeSliderState createState() => _TimeSliderState();
}

class _TimeSliderState extends State<TimeSlider> {
  final baseColor = Color.fromRGBO(255, 255, 255, 0.3);

  int initTime = 0;
  int endTime = 12;
  int numTimers = 0;

  late Timer _timer;
  late DateTime dateTime;

  int inBedTime = 0;
  int outBedTime = 12;
  int days = 0;

  // final doubleCircularSliderRossoKey = GlobalKey<DoubleCircularSliderState>();
  // final doubleCircularSliderGialloKey = GlobalKey<DoubleCircularSliderState>();
  // Color? subColorSliderRosso = Colors.red[700];
  // Color? subColorSliderGiallo = Colors.yellow[700];

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 10), setTime);

    //_shuffle();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void setTime(Timer timer) {
    setState(() {
      dateTime = DateTime.now();
      // if (numTimers > 0 &&
      //     doubleCircularSliderRosso != null &&
      //     widget.timerAttivazioni.timers[0].isActivated) {
      //   doubleCircularSliderRossoKey.currentState
      //       ?.setSubDivider(currentDividerTime(dateTime, 24 * 12));
      // }
    });
  }

  // void _shuffle() {
  //   setState(() {
  //     initTime = widget.timers.timers[0].getTimer()[0];
  //     endTime = widget.timer.getTimer()[1];
  //     inBedTime = initTime;
  //     outBedTime = endTime;
  //   });
  // }

  // void _updateLabels(int init, int end, int laps) {
  //   setState(() {
  //     inBedTime = init;
  //     outBedTime = end;
  //     days = laps;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    int dividers = 24 * 12;
    return MultiFlutterCircularSlider(
      dividers,
      widget.stato.timers!.timersArray,
      widget.stato.timers!.activationArray,
      size: [Size(320.0, 320.0), Size(250.0, 250.0)],
      primarySectors: 24,
      secondarySectors: 24 * 6,
      baseColor: Colors.black12,
      gridColor: Colors.black,
      selectionColor: [
        Colors.yellow[700] ?? Colors.black54,
        Colors.red[700] ?? Colors.black54
      ],
      handlerColor: Colors.black54,
      handlerOutterRadius: 12.0,
      //onSelectionChange: _updateLabels,
      onSelectionEnd: (a, b, d) => _onSelectionEnd(a, b, d),
      sliderStrokeWidth: 12.0,
      timerDivider: currentDividerTime(dateTime, dividers),
      subDividerColor: Colors.black,
      pointerLabel: (a) {
        return _formatTime(a);
      },
      shouldCountLaps: false,
    );

    // numTimers = widget.stato.timers!.timers.length;
    // List<Widget> circularSlider = [];
    // int dividers = 24 * 12;
    // List<String> labels = [];
    // bool dividerGiallo = false;
    // for (int i = 0; i < 8; i++) {
    //   labels.add((i * 3).toString());
    // }

    // if (numTimers > 1 && widget.stato.timers!.timers[1].isActivated) {
    //   if (currentDividerTime(dateTime, dividers) >
    //           widget.stato.timers!.timers[1].getTimer()[0] &&
    //       currentDividerTime(dateTime, dividers) <
    //           widget.stato.timers!.timers[1].getTimer()[1]) {
    //     dividerGiallo = true;
    //   }

    //   circularSlider.add(DoubleCircularSlider(
    //     dividers,
    //     [widget.stato.timers!.timers[1].getTimer()[0]],
    //     [widget.stato.timers!.timers[1].getTimer()[1]],
    //     key: doubleCircularSliderGialloKey,
    //     height: 320.0,
    //     width: 320.0,
    //     primarySectors: 24,
    //     secondarySectors: 24 * 6,
    //     baseColor: Colors.black12,
    //     gridColor: Colors.black,
    //     selectionColor: Colors.yellow[700],
    //     handlerColor: Colors.black54,
    //     handlerOutterRadius: 12.0,
    //     //onSelectionChange: _updateLabels,
    //     onSelectionEnd: (a, b, c, d) => _onSelectionEnd(a, b, c, d),
    //     sliderStrokeWidth: 12.0,
    //     labels: labels,
    //     //child: widget.child,
    //     subDivider: [currentDividerTime(dateTime, dividers)],
    //     subDividerColor: widget.stato.colore,
    //     pointerLabel: (a) {
    //       return _formatTime(a);
    //     },
    //     shouldCountLaps: false,
    //   ));
    // }
    // if (numTimers > 0 && widget.stato.timers!.timers[0].isActivated) {
    //   Color? subColorSliderRosso =
    //       dividerGiallo ? Colors.red[700] : widget.stato.colore;
    //   circularSlider.add(DoubleCircularSlider(
    //     dividers,
    //     [widget.stato.timers!.timers[0].getTimer()[0]],
    //     [widget.stato.timers!.timers[0].getTimer()[1]],
    //     key: doubleCircularSliderRossoKey,
    //     height: 250.0,
    //     width: 250.0,
    //     primarySectors: 24,
    //     secondarySectors: 24 * 6,
    //     baseColor: Colors.black12,
    //     gridColor: Colors.black,
    //     selectionColor: Colors.red[700],
    //     handlerColor: Colors.black54,
    //     handlerOutterRadius: 12.0,
    //     //onSelectionChange: _updateLabels,
    //     onSelectionEnd: (a, b, c, d) => _onSelectionEnd(a, b, 0, d),
    //     sliderStrokeWidth: 12.0,
    //     timerDivider: currentDividerTime(dateTime, dividers),
    //     subDivider: [currentDividerTime(dateTime, dividers)],
    //     subDividerColor: subColorSliderRosso,
    //     pointerLabel: (a) {
    //       return _formatTime(a);
    //     },
    //     shouldCountLaps: false,
    //   ));
    // }
    // if (widget.child != null) {
    //   circularSlider.add(widget.child!);
    // }
    // return Stack(
    //   children: circularSlider,
    //   alignment: Alignment.center,
    // );
  }

  void _onSelectionEnd(List<int> a, int b, List<int> index) {
    widget.stato.setTimer(a, index);

    //widget.timers.saveTimers();
  }

  // Widget _formatBedTime(String pre, int time) {
  //   return Column(
  //     children: [
  //       Text(pre, style: TextStyle(color: baseColor)),
  //       Text('BED AT', style: TextStyle(color: baseColor)),
  //       Text(
  //         '${_formatTime(time)}',
  //         style: TextStyle(color: Colors.white),
  //       )
  //     ],
  //   );
  // }

  // String _formatDays(int days) {
  //   return days > 0 ? ' (+$days)' : '';
  // }

  String _formatTime(int time) {
    if (time == 0 || time == null) {
      return '00:00';
    }
    var hours = time ~/ 12;
    var minutes = (time % 12) * 5;
    return '$hours:$minutes';
  }

  // String _formatIntervalTime(int init, int end) {
  //   var sleepTime = end > init ? end - init : 288 - init + end;
  //   var hours = sleepTime ~/ 12;
  //   var minutes = (sleepTime % 12) * 5;
  //   return '${hours}h${minutes}m';
  // }

  int _generateRandomTime() => Random().nextInt(288);

  /// the current time, in “seconds since the epoch”
  static int currentDividerTime(DateTime dateTime, int dividers) {
    double div =
        (dateTime.hour * 3600 + dateTime.minute * 60 + dateTime.second) *
            (dividers / (24 * 3600));
    return div.round();
  }
}
