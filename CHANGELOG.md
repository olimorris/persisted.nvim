# Changelog

## [3.1.0](https://github.com/olimorris/persisted.nvim/compare/v3.0.0...v3.1.0) (2026-08-25)


### Features

* add `before_save` callback ([#196](https://github.com/olimorris/persisted.nvim/issues/196)) ([d205c4d](https://github.com/olimorris/persisted.nvim/commit/d205c4d78657b83e50b4a54541f58f17036e5178))
* clean orphaned sessions ([#193](https://github.com/olimorris/persisted.nvim/issues/193)) ([3beef15](https://github.com/olimorris/persisted.nvim/commit/3beef15a616dbb99bc9051140e829a716932a2ae))
* cleaner git branching ([#197](https://github.com/olimorris/persisted.nvim/issues/197)) ([e905ec1](https://github.com/olimorris/persisted.nvim/commit/e905ec1ff731518afaa834304a536c4b43722473))
* manually name sessions ([#195](https://github.com/olimorris/persisted.nvim/issues/195)) ([969a026](https://github.com/olimorris/persisted.nvim/commit/969a026af2de5c054b85ccca31b809292a47f265))

## [3.0.0](https://github.com/olimorris/persisted.nvim/compare/v2.1.1...v3.0.0) (2026-01-14)


### ⚠ BREAKING CHANGES

* feat: new command format

### Features

* feat: new command format ([#183](https://github.com/olimorris/persisted.nvim/issues/183))
* feat: can delete session in vim.ui.select ([#184](https://github.com/olimorris/persisted.nvim/issues/184))

### Tests

* tests: move from plenary to mini.test ([#185](https://github.com/olimorris/persisted.nvim/issues/185)

## [2.1.1](https://github.com/olimorris/persisted.nvim/compare/v2.1.0...v2.1.1) (2025-08-16)


### Bug Fixes

* loading of sessions via select ([#178](https://github.com/olimorris/persisted.nvim/issues/178)) ([d35efcc](https://github.com/olimorris/persisted.nvim/commit/d35efcc5c03d6d5777e0a47d2e541d9e53464392))

## [2.1.0](https://github.com/olimorris/persisted.nvim/compare/v2.0.2...v2.1.0) (2025-03-07)


### Features

* **events:** add `SelectPre` and `SelectPost` events ([#172](https://github.com/olimorris/persisted.nvim/issues/172)) ([562fe01](https://github.com/olimorris/persisted.nvim/commit/562fe01d9739b9c37b32113d4d70c3cfad3c5ec5))

## [2.0.2](https://github.com/olimorris/persisted.nvim/compare/v2.0.1...v2.0.2) (2024-12-21)


### Bug Fixes

* correct "M.config" with config ([#167](https://github.com/olimorris/persisted.nvim/issues/167)) ([1d50876](https://github.com/olimorris/persisted.nvim/commit/1d508760e74f0fdfbfb225f7c227cafc54628e51))

## [2.0.1](https://github.com/olimorris/persisted.nvim/compare/v2.0.0...v2.0.1) (2024-10-17)


### Bug Fixes

* do not autostart the plugin if nvim is passed args ([e65093d](https://github.com/olimorris/persisted.nvim/commit/e65093de393bad9e2bb13348895aaba6319b9ad1))

## [2.0.0](https://github.com/olimorris/persisted.nvim/compare/v1.1.1...v2.0.0) (2024-09-11)


### ⚠ BREAKING CHANGES

* remove support for old config

### Code Refactoring

* remove support for old config ([f0f02a9](https://github.com/olimorris/persisted.nvim/commit/f0f02a990c3df2a97dfea9636f719137867d0a52))

## [1.1.1](https://github.com/olimorris/persisted.nvim/compare/v1.1.0...v1.1.1) (2024-09-03)


### Bug Fixes

* [#146](https://github.com/olimorris/persisted.nvim/issues/146) better handling for empty tables  ([c9c11ee](https://github.com/olimorris/persisted.nvim/commit/c9c11ee71feeecfa86bc7650eda4c4d0c5505f6d))
* SessionDelete now uses native vim cmds ([#156](https://github.com/olimorris/persisted.nvim/issues/156)) ([6e9c992](https://github.com/olimorris/persisted.nvim/commit/6e9c992381765a57d29ca7dc0b912683216d59c4))

## [1.1.0](https://github.com/olimorris/persisted.nvim/compare/v1.0.0...v1.1.0) (2024-08-22)


### Features

* add `SessionSelect` command ([999b691](https://github.com/olimorris/persisted.nvim/commit/999b6918b403e3b4ffa6b60d735557ace230ad83))
