/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Combine
import Moya

class FilmsViewController: UITableViewController {
    var films: [Film] = []
    // MARK: - Table view items
    typealias Section = TableViewSection
    typealias Item = TableViewItem
    lazy var dataSource = makeDataSource()
    
    // MARK: - Networking
    private let apiManager = APIManager()
    private lazy var movieService: MovieService = {
        return MovieService(apiManager: apiManager)
    }()
    var cancellables = Set<AnyCancellable>()

    // MARK: - Navigation action
    @IBSegueAction func showFilmDetails(_ coder: NSCoder, sender: Any?) -> FilmDetailsViewController? {
        guard
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        else {
            return nil
        }
        return FilmDetailsViewController(film: films[indexPath.row], coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        loadData()
    }
}

extension FilmsViewController {
    func loadData() {
        movieService.getMovies()
            .map(\.data.allFilms.films)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] movies in
                self?.films = movies // In order to keep the old navigation to detail page
                let items = movies.map { TableViewItem.movie($0.title) }
                let sectionModel = SectionModel(section: TableViewSection.movies, items: items)
                self?.updateDataSource(with: [sectionModel])
            }
            .store(in: &cancellables)
    }
}

// MARK: - DataSource
private extension FilmsViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Section, Item> {
        let dataSource: UITableViewDiffableDataSource<Section, Item> = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .movie(let title):
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilmCell")!
                cell.textLabel?.text = title
                return cell
            }
        }
        
        return dataSource
    }
    
    func updateDataSource(with sections: [SectionModel<Section, Item>], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        sections.forEach { sectionModel in
            snapshot.appendSections([sectionModel.section])
            snapshot.appendItems(sectionModel.items, toSection: sectionModel.section)
        }

        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: animate, completion: nil)
        }
    }
}

/// This would go to ViewModel if we had one here '-_-
extension FilmsViewController {
    enum TableViewSection: Hashable {
        case movies
    }
    
    enum TableViewItem: Hashable {
        case movie(String)
    }
}
