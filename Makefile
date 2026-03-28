.PHONY: bootstrap format lint test test-models test-network test-domain test-feature test-feature-mvvm test-feature-tca

bootstrap:
	swift build --package-path Tools -c release --product swiftlint
	swift build --package-path Tools -c release --product swiftformat

format:
	Tools/.build/release/swiftformat .

lint:
	Tools/.build/release/swiftlint lint .

test: test-models test-network test-domain test-feature

test-models:
	swift test --package-path Packages/CoreModels

test-network:
	swift test --package-path Packages/CoreNetwork

test-domain:
	swift test --package-path Packages/WeatherDomain

test-feature: test-feature-mvvm test-feature-tca

test-feature-mvvm:
	swift test --package-path Packages/WeatherFeature --filter WeatherFeatureMVVMTests

test-feature-tca:
	swift test --package-path Packages/WeatherFeature --filter WeatherFeatureTCATests
