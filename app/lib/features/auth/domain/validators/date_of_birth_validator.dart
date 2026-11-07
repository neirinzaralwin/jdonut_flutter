import 'package:jdonut/core/constants/app_constants.dart';

/// Date of birth rules (brief Task 1): a real calendar date, not in the
/// future, and at least [AppConstants.minimumAgeYears] years old.
enum DateOfBirthError { invalidDate, inFuture, tooYoung }

const int _earliestBirthYear = 1900;

DateOfBirthError? validateDateOfBirth({
  required int? year,
  required int? month,
  required int? day,
  required DateTime today,
  int minimumAgeYears = AppConstants.minimumAgeYears,
}) {
  final date = calendarDate(year: year, month: month, day: day);
  if (date == null) return DateOfBirthError.invalidDate;
  if (date.isAfter(_dateOnly(today))) return DateOfBirthError.inFuture;
  return ageInYears(date, today) < minimumAgeYears
      ? DateOfBirthError.tooYoung
      : null;
}

/// The date, or `null` when it doesn't exist (31 April, or 29 Feb in a
/// common year).
DateTime? calendarDate({int? year, int? month, int? day}) {
  if (year == null || month == null || day == null) return null;
  if (year < _earliestBirthYear) return null;
  final date = DateTime(year, month, day);
  final isReal = date.year == year && date.month == month && date.day == day;
  return isReal ? date : null;
}

int ageInYears(DateTime birthDate, DateTime today) {
  final hadBirthdayThisYear =
      today.month > birthDate.month ||
      (today.month == birthDate.month && today.day >= birthDate.day);
  return today.year - birthDate.year - (hadBirthdayThisYear ? 0 : 1);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
