//
//  ViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UIScrollViewDelegate {
	
	let disposeBag = DisposeBag()
	
	let viewModel = ViewModel()
	let searchVC = SearchViewController()
	
	let detailView: DetailView = {
		let view = DetailView()
		view.backgroundColor = UIColor(named: "viewColor")
		return view
	}()
	
	let errorView: EmptyView = {
		let view = EmptyView()
		return view
	}()
	
	var resultName: String?
	var selectedAPI = ""
	
	var cellData = [CollectionCellData]()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(detailView)
		setupViews()
		
		detailView.collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.description())
		viewModel.getCollectionViewData(for: resultName!) { [weak self] response in
			self?.cellData = response
			self?.detailView.spinner.performSelector(onMainThread: #selector(UIActivityIndicatorView.stopAnimating), with: nil, waitUntilDone: false)
			if self!.cellData.isEmpty {
				DispatchQueue.main.async {
					self?.detailView.collectionView.isHidden = true
					self?.errorView.isHidden = false
				}
			}
		}
		title = resultName
		
		detailView.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
		bindToCollectionView()
	}
}

extension ViewController {
	func setupViews() {
		detailView.collectionView.isHidden = false
		
		errorView.translatesAutoresizingMaskIntoConstraints = false
		detailView.spinner.startAnimating()
		
		view.addSubview(detailView)
		detailView.addSubview(errorView)
		errorView.isHidden = true
		
		NSLayoutConstraint.activate([
			detailView.topAnchor.constraint(equalTo: view.topAnchor),
			detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			errorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			errorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
			
			errorView.widthAnchor.constraint(equalToConstant: 300),
			errorView.heightAnchor.constraint(equalToConstant: 95)
		])
	}
	
	func bindToCollectionView() {
		
		detailView.collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.description())
		
		viewModel.subject.asObserver().bind(to: self.detailView.collectionView.rx.items(cellIdentifier: AlbumCell.description(), cellType: AlbumCell.self)) { row, _, cell in
			cell.updateCell(album: self.cellData[row])
		}.disposed(by: disposeBag)
	}
}
