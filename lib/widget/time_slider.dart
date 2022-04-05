import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:gestione_domotica/models/timer/timer_attivazione.dart';
import 'package:gestione_domotica/models/timer/timers_attivazione.dart';

class TimeSlider extends StatefulWidget {
  TimeSlider(
      {Key? key,
      required this.timerAttivazioni,
      this.subDividerColor,
      this.child})
      : super(key: key) {
    // MultiMessageProvider multiMessageProvider = MultiMessageProvider();
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
  }

  Widget? child;
  TimerAttivazioni timerAttivazioni;
  Color? subDividerColor;

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

  final doubleCircularSliderRossoKey = GlobalKey<DoubleCircularSliderState>();
  final doubleCircularSliderGialloKey = GlobalKey<DoubleCircularSliderState>();
  // Color? subColorSliderRosso = Colors.red[700];
  // Color? subColorSliderGiallo = Colors.yellow[700];

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), setTime);

    //_shuffle();
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
    numTimers = widget.timerAttivazioni.timers.length;
    List<Widget> circularSlider = [];
    int dividers = 24 * 12;
    List<String> labels = [];
    bool dividerGiallo = false;
    for (int i = 0; i < 8; i++) {
      labels.add((i * 3).toString());
    }

    if (numTimers > 1 && widget.timerAttivazioni.timers[1].isActivated) {
      if (currentDividerTime(dateTime, dividers) >
              widget.timerAttivazioni.timers[1].getTimer()[0] &&
          currentDividerTime(dateTime, dividers) <
              widget.timerAttivazioni.timers[1].getTimer()[1]) {
        dividerGiallo = true;
      }

      circularSlider.add(DoubleCircularSlider(
        dividers,
        widget.timerAttivazioni.timers[1].getTimer()[0],
        widget.timerAttivazioni.timers[1].getTimer()[1],
        key: doubleCircularSliderGialloKey,
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
        subDivider: currentDividerTime(dateTime, dividers),
        subDividerColor: widget.subDividerColor,
        pointerLabel: (a) {
          return _formatTime(a);
        },
        shouldCountLaps: false,
      ));
    }
    if (numTimers > 0 && widget.timerAttivazioni.timers[0].isActivated) {
      Color? subColorSliderRosso =
          dividerGiallo ? Colors.red[700] : widget.subDividerColor;
      circularSlider.add(DoubleCircularSlider(
        dividers,
        widget.timerAttivazioni.timers[0].getTimer()[0],
        widget.timerAttivazioni.timers[0].getTimer()[1],
        key: doubleCircularSliderRossoKey,
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
        subDivider: currentDividerTime(dateTime, dividers),
        subDividerColor: subColorSliderRosso,
        pointerLabel: (a) {
          return _formatTime(a);
        },
        shouldCountLaps: false,
      ));
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
    widget.timerAttivazioni.timers[mode].setTimer(a, b);
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
