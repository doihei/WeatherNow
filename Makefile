.PHONY: bootstrap format lint test test-models test-network test-domain

bootstrap:
	swift build --package-path Tools -c release --product swiftlint
	swift build --package-path Tools -c release --product swiftformat

format:
	Tools/.build/release/swiftformat .

lint:
	Tools/.build/release/swiftlint lint .

test: test-models test-network test-domain

test-models:
	swift test --package-path Packages/CoreModels

test-network:
	swift test --package-path Packages/CoreNetwork

test-domain:
	swift test --package-path Packages/WeatherDomain
