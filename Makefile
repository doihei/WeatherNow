.PHONY: bootstrap format lint

bootstrap:
	swift build --package-path Tools -c release --product swiftlint
	swift build --package-path Tools -c release --product swiftformat

format:
	swift run -c release --package-path Tools swiftformat .

lint:
	swift run -c release --package-path Tools swiftlint lint .
