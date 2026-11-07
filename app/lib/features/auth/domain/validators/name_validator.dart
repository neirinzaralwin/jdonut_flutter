import 'package:jdonut/core/constants/app_constants.dart';

/// Name rules (brief Task 1): 1–50 characters after trimming; letters and
/// spaces, Myanmar script included (letters + combining marks); no digits.
enum NameError { required, tooLong, invalidCharacters }

// \p{L} letters (incl. Myanmar consonants), \p{M} marks (Myanmar vowel signs).
// Digits — Latin or Myanmar (\p{Nd}) — are not matched.
final RegExp _lettersAndSpaces = RegExp(r'^[\p{L}\p{M} ]+$', unicode: true);

NameError? validateFirstName(String input) {
  final name = input.trim();
  if (name.isEmpty) return NameError.required;
  return _validateCharacters(name);
}

/// Optional — many Myanmar names have no family name.
NameError? validateLastName(String input) {
  final name = input.trim();
  return name.isEmpty ? null : _validateCharacters(name);
}

NameError? _validateCharacters(String name) {
  if (name.length > AppConstants.nameMaxLength) return NameError.tooLong;
  return _lettersAndSpaces.hasMatch(name) ? null : NameError.invalidCharacters;
}
