# Release

- update the version inside 'cg.asd'.
- update changelog
- `git commit ..` and `git push`
- wait for [travis-ci](https://travis-ci.org/iamFIREcracker/cg) to finish the
  build
- `git tag $TAG` and `git push origin $TAG`
