import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:gestione_domotica/models/timer/timer.dart';
import 'package:gestione_domotica/models/timer/timers.dart';

class TimeSlider extends StatefulWidget {
  TimeSlider({Key? key, required this.timers, this.child}) : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  Widget? child;
  Timers timers;

  @override
  _TimeSliderState createState() => _TimeSliderState();
}

class _TimeSliderState extends State<TimeSlider> {
  final baseColor = Color.fromRGBO(255, 255, 255, 0.3);

  int initTime = 0;
  int endTime = 12;

  int inBedTime = 0;
  int outBedTime = 12;
  int days = 0;

  Widget? doubleCircularSliderRosso;
  Widget? doubleCircularSliderGiallo;

  @override
  void initState() {
    super.initState();
    List<String> labels = [];
    for (int i = 0; i < 8; i++) {
      labels.add((i * 3).toString());
    }
    doubleCircularSliderRosso = DoubleCircularSlider(
      24 * 12,
      widget.timers.timers[0].getTimer()[0],
      widget.timers.timers[0].getTimer()[1],
      key: UniqueKey(),
      height: 250.0,
      width: 250.0,
      primarySectors: 24,
      secondarySectors: 24 * 6,
      baseColor: Colors.black12,
      gridColor: Colors.black,
      selectionColor: Colors.red[700],
      handlerColor: Colors.black54,
      handlerOutterRadius: 12.0,
      //onSelectionChange: _updateLabels,
      onSelectionEnd: (a, b, c) => _onSelectionEnd(a, b, 0),
      sliderStrokeWidth: 12.0,
      pointerLabel: (a) {
        return _formatTime(a);
      },
      shouldCountLaps: false,
    );

    doubleCircularSliderGiallo = DoubleCircularSlider(
      24 * 12,
      widget.timers.timers[1].getTimer()[0],
      widget.timers.timers[1].getTimer()[1],
      key: UniqueKey(),
      height: 320.0,
      width: 320.0,
      primarySectors: 24,
      secondarySectors: 24 * 6,
      baseColor: Colors.black12,
      gridColor: Colors.black,
      selectionColor: Colors.yellow[700],
      handlerColor: Colors.black54,
      handlerOutterRadius: 12.0,
      //onSelectionChange: _updateLabels,
      onSelectionEnd: (a, b, c) => _onSelectionEnd(a, b, 1),
      sliderStrokeWidth: 12.0,
      labels: labels,
      //child: widget.child,
      pointerLabel: (a) {
        return _formatTime(a);
      },
      shouldCountLaps: false,
    );
    //_shuffle();
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
    int num_timers = widget.timers.timers.length;
    List<Widget> circularSlider = [];
    if (num_timers > 0 &&
        doubleCircularSliderRosso != null &&
        widget.timers.timers[0].isActivated) {
      circularSlider.add(doubleCircularSliderRosso!);
    }
    if (num_timers > 1 &&
        doubleCircularSliderGiallo != null &&
        widget.timers.timers[1].isActivated) {
      circularSlider.add(doubleCircularSliderGiallo!);
    }
    if (widget.child != null) {
      circularSlider.add(widget.child!);
    }
    return Stack(
      children: circularSlider,
      alignment: Alignment.center,
    );
  }

  void _onSelectionEnd(int a, int b, int mode) {
    widget.timers.timers[mode].setTimer(a, b);
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
}
