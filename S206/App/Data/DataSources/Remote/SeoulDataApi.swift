//
//  GithubApi.swift
//  S206
//
//  Created by kwp-macbook-pro on 2022/07/04.
//

import Foundation
import Moya

public enum SeoulDataApi {
    case cultureEventInfo
}

extension SeoulDataApi: TargetType {
    // 1
    public var baseURL: URL {
        return URL(string: "http://openapi.seoul.go.kr:8088/")!
    }

    // 2
    public var path: String {
        switch self {
            case .cultureEventInfo:
                return "7a4f58414a7061723736646a57694a/json/culturalEventInfo/1/5/"
        }
    }

    // 3
    public var method: Moya.Method {
        switch self {
            case .cultureEventInfo: return .get
        }
    }

    // 4
    public var task: Task {
        switch self {
        case .cultureEventInfo:
            let params: [String: Any] = [:]
//            [
//                "\(CommonEntity.LATITUDE)": CommonEntity.LATITUDE_VALUE,
//                "\(CommonEntity.LONGITUDE)": CommonEntity.LONGITUDE_VALUE,
//                "\(CommonEntity.APP_ID)": CommonEntity.APP_ID_VALUE,
//                "\(CommonEntity.LANGUAGE)": CommonEntity.LANGUAGE_VALUE,
//                "\(CommonEntity.UNIT)": CommonEntity.UNIT_VALUE,
//            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }

    // 5
    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
