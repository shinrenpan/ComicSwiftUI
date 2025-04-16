//
//  Router.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/15.
//

import ComposableArchitecture

enum Router {
    @Reducer
    enum Navigation {
        case detailView(DetailFeature)
        case readerView(ReaderFeature)
        case remoteSearchView(RemoteSearchFeature)
    }
    
    @Reducer
    enum Sheet {
        case episodePicker(EpisodePickerFeature)
    }
}

extension Router.Navigation.State: Equatable {}
extension Router.Navigation.Action: Equatable {}
extension Router.Sheet.State: Equatable {}
extension Router.Sheet.Action: Equatable {}
