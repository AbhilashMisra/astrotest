//
//  AstroViewModel.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation
import Combine

protocol AstroFactsModalProvider {
    var data: CurrentValueSubject<[FactDataObject], Never> { get }
    
    /// Get the next date for display
    func fetchPreviousDateData() async
}

struct AstroViewModel: AstroFactsModalProvider {
    private(set) var data = CurrentValueSubject<[FactDataObject], Never>([])
    let getUsecase: GetFactUseCase
    let downloadUsecase: ImageFetchUseCase
    
    /// Get the next date for display
    func fetchPreviousDateData() async {
        do {
            let date = data.value.last?.date?.addingTimeInterval(-24*60*60) ?? Calendar.current.startOfDay(for: Date.now)
            let fact: FactDataObject?
            if NetworkMonitor.shared.isConnected {
                fact = try await getUsecase.getFactOn(date: date)
            } else {
                fact = getUsecase.getNextLocalFactAfter(date: date)
            }
            
            if let fact {
                if !downloadUsecase.isImageDownloadedFor(fact: fact) {
                    Task {
                        await downloadImageFor(fact: fact)
                    }
                }
                data.value.append(fact)
            }
        } catch {
            print("error",error)
        }
    }
    
    /// download the image for fact
    /// - Parameter fact: fact to download image for
    private func downloadImageFor(fact: FactDataObject) async {
        do {
            try await downloadUsecase.downloadImageFor(fact: fact)
            if let date = fact.date {
                let fact = try await getUsecase.getFactOn(date: date)
                if let index = data.value.firstIndex(where: {$0.date == date}) {
                    data.value[index] = fact
                    data.send(data.value)
                }
            }
        } catch {
            print("error",error)
        }
    }
    
    
}
