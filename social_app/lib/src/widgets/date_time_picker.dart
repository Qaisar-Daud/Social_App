import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers/constants.dart';

class ShowDateTimePicker {

  static Future<DateTime?> selectDate(
      BuildContext context,
      DateTime selectedDate,
      TextEditingController dateEditingController) async {

    DateTime? newSelectedDate = await showDatePicker(
      keyboardType: TextInputType.datetime,
      helpText: 'Date of Birth',
      switchToInputEntryModeIcon: const Icon(Icons.drive_file_rename_outline, size: 20),
      switchToCalendarEntryModeIcon: const Icon(Icons.calendar_month, size: 20),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.teal,
              onPrimary: Colors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (newSelectedDate != null) {
      // Set the date in yyyy-MM-dd format for validator
      final formatted = DateFormat('yyyy-MM-dd').format(newSelectedDate);

      dateEditingController
        ..text = formatted
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: formatted.length),
        );
    }

    return newSelectedDate;
  }

  static selectTime(
      BuildContext context, selectedTime, timeEditingController) async {
    final TimeOfDay? newSelectedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (context, child) {
          return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppColors.teal,
                  onPrimary: Colors.white,
                  surface: AppColors.white,
                  onSurface: AppColors.black,
                ),
                dialogTheme: DialogThemeData(backgroundColor: Colors.blue[500]),
              ),
              child: child!);
        });
    if (newSelectedTime != null) {
      selectedTime = newSelectedTime;

      // Create a DateTime object with today's date and the selected time
      DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      timeEditingController
        ..text = DateFormat('hh:mm a').format(selectedDateTime)
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: timeEditingController.text.length));
    }
  }
}
