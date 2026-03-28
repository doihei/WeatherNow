import CoreModels
import Dependencies
import Foundation
import Testing
@testable import WeatherFeatureMVVM

@MainActor
struct CitySearchViewModelTests {
    private func makeSUT(
        repository: StubWeatherRepository = StubWeatherRepository()
    ) -> (vm: CitySearchViewModel, cityListVM: CityListViewModel) {
        withDependencies {
            $0.weatherRepository = repository
            $0.cityListService = StubCityListService()
        } operation: {
            let cityListVM = CityListViewModel()
            let vm = CitySearchViewModel(cityListViewModel: cityListVM)
            return (vm, cityListVM)
        }
    }

    // MARK: - updateQuery

    @Test("updateQuery に空文字を渡すと results がクリアされる")
    func emptyQueryClearsResults() {
        let (vm, _) = makeSUT()
        vm.updateQuery("")
        #expect(vm.results.isEmpty)
        #expect(!vm.isSearching)
    }

    @Test("updateQuery に空白のみを渡すと results がクリアされる")
    func whitespaceOnlyQueryClearsResults() {
        let (vm, _) = makeSUT()
        vm.updateQuery("   ")
        #expect(vm.results.isEmpty)
    }

    @Test("updateQuery に空文字を渡すと errorMessage がクリアされる")
    func emptyQueryClearsErrorMessage() {
        let (vm, _) = makeSUT()
        // 先に errorMessage を持たせるために空白→実クエリの順でセット
        vm.updateQuery("")
        #expect(vm.errorMessage == nil)
    }

    @Test("updateQuery で query が更新される")
    func queryIsUpdated() {
        let (vm, _) = makeSUT()
        vm.updateQuery("東京")
        #expect(vm.query == "東京")
    }

    // MARK: - isCityAdded

    @Test("isCityAdded は cityListViewModel に委譲し登録済みで true を返す")
    func isCityAddedDelegatesToCityList() {
        let (vm, cityListVM) = makeSUT()
        let result = GeocodingResult.stub(id: 1)
        cityListVM.add(result)
        #expect(vm.isCityAdded(result))
    }

    @Test("isCityAdded は未登録で false を返す")
    func isCityNotAddedReturnsFalse() {
        let (vm, _) = makeSUT()
        #expect(!vm.isCityAdded(.stub(id: 99)))
    }

    // MARK: - addCity

    @Test("addCity は cityListViewModel に都市を追加する")
    func addCityDelegatesToCityList() {
        let (vm, cityListVM) = makeSUT()
        vm.addCity(.stub(id: 5))
        #expect(cityListVM.cities.count == 1)
        #expect(cityListVM.cities[0].id == 5)
    }
}
