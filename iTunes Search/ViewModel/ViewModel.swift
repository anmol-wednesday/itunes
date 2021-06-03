//
//  ViewModel.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 24/05/21.
//

import Foundation
import UIKit.UICollectionView
import RxSwift
import RxCocoa

class ViewModel {
    public var albums = [Album]()
    public var cellData = [CollectionCellData]()
    public var napsterAlbums = [NapsterAlbums]()
	
	public var subject = PublishSubject<[CollectionCellData]>()
    
    func getCollectionViewData(for value: String, completion: @escaping ([CollectionCellData]) -> Void) {
        if SearchViewController.selectedAPI == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let search = value
                SearchManager.instance.getAlbum(searchRequest: search) { [weak self] (requestedAlbums) in
                    self?.albums = requestedAlbums
                    self?.cellData = self!.albums.map {
                        CollectionCellData(image: $0.artwork, artistName: $0.artistName, trackName: $0.songName, collectionName: $0.collectionName)
                    }
					self?.subject.onNext(self!.cellData)
                    completion(self!.cellData) // remove
                }
            }
        } else if SearchViewController.selectedAPI == API.Napster.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterAlbums(string: value) { [weak self] (request) in
                    self?.napsterAlbums = request
                    self?.cellData = self!.napsterAlbums[0].albumID.map {
                        CollectionCellData(image: $0, artistName: value, trackName: $0, collectionName: $0)
                    }
					self?.subject.onNext(self!.cellData)
                    completion(self?.cellData ?? []) // remove
                }
            }
        }
    }
}
