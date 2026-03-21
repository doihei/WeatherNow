.PHONY: bootstrap format lint

bootstrap:
	swift build --package-path Tools -c release --product swiftlint
	swift build --package-path Tools -c release --product swiftformat

format:
	Tools/.build/release/swiftformat .

lint:
	Tools/.build/release/swiftlint lint .
