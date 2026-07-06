bool platformCheck(bool Function() block) {
  try {
    return block();
  } catch (e) {
    // Ignored
  }
  return false;
}

bool platformCheckIsWeb() => platformCheck(() => true);
