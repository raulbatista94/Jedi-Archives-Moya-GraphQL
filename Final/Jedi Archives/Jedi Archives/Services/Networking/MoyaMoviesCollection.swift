/// Copyright (c) 2022 Razeware LLC
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

import Foundation
import Moya

enum MoyaMoviesCollection {
    case film
}

extension MoyaMoviesCollection: TargetType {
    var baseURL: URL {
        return URL(string: "http://localhost:64428")!
    }
    
    var path: String {
        switch self {
        case .film:
            return ""
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        var body: Data!
        switch self {
        case .film:
            body = GraphQLQueryBuilder.build(.film)
        }
        
        return .requestData(body)
    }
    
    var headers: [String : String]? {
        switch self {
        case .film:
            return ["Content-Type": "application/json"]
        }
    }
}


private struct GraphQLQueryBuilder {
    static func build(_ type: MoyaMoviesCollection) -> Data? {
        switch type {
        case .film:
            let resultObject = [
                "query": """
                    query AllFilms {
                      allFilms {
                        __typename
                        films {
                          __typename
                          id
                          director
                          episodeID
                          title
                          releaseDate
                          characterConnection(first: 10) {
                            __typename
                            characters {
                              __typename
                              id
                              name
                              birthYear
                              eyeColor
                              hairColor
                              homeworld {
                                __typename
                                name
                              }
                            }
                          }
                        }
                      }
                    }
                """.trimmingCharacters(in: .whitespacesAndNewlines)
            ] as [String: Any]
            
            return try? JSONSerialization.data(withJSONObject: resultObject, options: .prettyPrinted)
        }
    }
}
