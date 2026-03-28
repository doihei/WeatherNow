import CoreModels
import Foundation
import Testing
@testable import WeatherFeatureMVVM

@MainActor
struct CityListViewModelTests {
    private func makeFreshViewModel(
        repository: StubWeatherRepository = StubWeatherRepository(),
        cityListService: StubCityListService = StubCityListService()
    ) -> CityListViewModel {
        CityListViewModel(repository: repository, cityListService: cityListService)
    }

    // MARK: - add

    @Test("add で都市が1件追加される")
    func addCity() {
        let vm = makeFreshViewModel()
        vm.add(.stub(id: 1))
        #expect(vm.cities.count == 1)
        #expect(vm.cities[0].id == 1)
    }

    @Test("add で同じ id の都市は重複追加されない")
    func addDuplicateCityIgnored() {
        let vm = makeFreshViewModel()
        vm.add(.stub(id: 1))
        vm.add(.stub(id: 1))
        #expect(vm.cities.count == 1)
    }

    @Test("add で id が異なれば別の都市として追加される")
    func addDifferentCities() {
        let vm = makeFreshViewModel()
        vm.add(.stub(id: 1))
        vm.add(.stub(id: 2))
        #expect(vm.cities.count == 2)
    }

    @Test("add で10件上限に達すると errorMessage が設定され都市は増えない")
    func addExceedsLimit() {
        let vm = makeFreshViewModel()
        for i in 0 ..< 10 {
            vm.add(.stub(id: i))
        }
        #expect(vm.errorMessage == nil)

        vm.add(.stub(id: 10))
        #expect(vm.cities.count == 10)
        #expect(vm.errorMessage != nil)
    }

    @Test("add で都市追加時に cityListService.save が呼ばれる")
    func addPersistsCities() {
        let service = StubCityListService()
        let vm = makeFreshViewModel(cityListService: service)
        vm.add(.stub(id: 1))
        #expect(service.savedCities?.count == 1)
    }

    // MARK: - remove

    @Test("remove で指定 IndexSet の都市が削除される")
    func removeCity() {
        let vm = makeFreshViewModel()
        vm.add(.stub(id: 1))
        vm.add(.stub(id: 2))
        vm.remove(at: IndexSet(integer: 0))
        #expect(vm.cities.count == 1)
        #expect(vm.cities[0].id == 2)
    }

    @Test("remove で都市削除時に cityListService.save が呼ばれる")
    func removePersistsCities() {
        let service = StubCityListService()
        let vm = makeFreshViewModel(cityListService: service)
        vm.add(.stub(id: 1))
        vm.remove(at: IndexSet(integer: 0))
        #expect(service.savedCities?.isEmpty == true)
    }

    // MARK: - move

    @Test("move で都市の並び順が変わる")
    func moveCities() {
        let vm = makeFreshViewModel()
        vm.add(.stub(id: 1))
        vm.add(.stub(id: 2))
        vm.add(.stub(id: 3))
        // index 0 を末尾へ: [1,2,3] → [2,3,1]
        vm.move(from: IndexSet(integer: 0), to: 3)
        #expect(vm.cities.map(\.id) == [2, 3, 1])
    }

    // MARK: - isCityAdded

    @Test("isCityAdded は登録済みの都市で true を返す")
    func isCityAddedTrue() {
        let vm = makeFreshViewModel()
        let result = GeocodingResult.stub(id: 1)
        vm.add(result)
        #expect(vm.isCityAdded(result))
    }

    @Test("isCityAdded は未登録の都市で false を返す")
    func isCityAddedFalse() {
        let vm = makeFreshViewModel()
        #expect(!vm.isCityAdded(.stub(id: 99)))
    }

    // MARK: - 初期ロード

    @Test("init で cityListService.load の結果が cities に反映される")
    func initLoadsCitiesFromService() {
        let city = GeocodingResult.stub(id: 42).toCity()
        let service = StubCityListService(cities: [city])
        let vm = makeFreshViewModel(cityListService: service)
        #expect(vm.cities.count == 1)
        #expect(vm.cities[0].id == 42)
    }

    // MARK: - loadAllWeather

    @Test("loadAllWeather で登録都市の天気が citiesWeather に格納される")
    func loadAllWeatherPopulatesCitiesWeather() async throws {
        let stub = Weather.stub(temperature: 25.0)
        var repo = StubWeatherRepository()
        repo.weatherStub = stub
        let vm = makeFreshViewModel(repository: repo)
        vm.add(.stub(id: 1, latitude: 35.68, longitude: 139.69))
        vm.add(.stub(id: 2, latitude: 34.69, longitude: 135.50))

        vm.loadAllWeather()
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.citiesWeather[1] == stub)
        #expect(vm.citiesWeather[2] == stub)
    }

    @Test("loadAllWeather で都市が0件のとき citiesWeather は空のまま")
    func loadAllWeatherEmptyCities() async throws {
        let vm = makeFreshViewModel()
        vm.loadAllWeather()
        try await Task.sleep(for: .milliseconds(50))
        #expect(vm.citiesWeather.isEmpty)
    }
}
