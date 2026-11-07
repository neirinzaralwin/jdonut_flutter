# Deliverables checklist

## Submission
- [ ] Public GitHub/GitLab repo, small readable commits
- [ ] Release `.apk` (`flutter build apk --release`)
- [ ] Zipped iOS Simulator `.app` (`flutter build ios --simulator`)
- [ ] 2–4 min recording: register → log out → log in → Home → Product → Rewards → same in airplane mode
- [ ] No design screenshots in repo

## README must contain
- [ ] How to run (app + mock server)
- [ ] Flutter and Dart versions
- [ ] Architecture + folder map
- [ ] State management choice
- [ ] Offline strategy
- [ ] Animations built
- [ ] Fake OTP code (123456)
- [ ] Known gaps
- [ ] Time spent

## Quality gates
- [ ] `flutter analyze` clean
- [ ] Unit tests: every validator rule + use cases
- [ ] Widget tests: login + registration validation
- [ ] Integration test: Register → Home → Product detail
- [ ] Reduce Motion respected
- [ ] Text scale 1.3 no overflow; 4.7"–6.9"
- [ ] Airplane mode after first launch: Home, Product, Rewards + images
- [ ] Optional: CI (analyze + test), mock server docs
