//
//  DataStructures.swift
//  Paradigm
//
//  Created by Ridwan Chowdhury on 2/13/21.
//  Copyright © 2021 team5. All rights reserved.
//

import Foundation

struct Analysis: Decodable {
    let sentiment: Sentiment
    let phrases: Phrases
    let entities: Entities
}

struct Sentiment: Decodable {
    let Sentiment: String
    let SentimentScore: SentimentEmotions
    let ResponseMetadata: ResponseMetadata
}

struct SentimentEmotions: Decodable {
    let Positive: Double
    let Negative: Double
    let Neutral: Double
    let Mixed: Double
}

struct Phrases: Decodable {
    let KeyPhrases: [KeyPhrase]
    let ResponseMetadata: ResponseMetadata
}

struct KeyPhrase: Decodable {
    let Score: Double
    let Text: String
    let BeginOffset: Int
    let EndOffset: Int
}

struct Entities: Decodable {
    let Entities: [Entity]
    let ResponseMetadata: ResponseMetadata
}

struct Entity: Decodable {
    let Score: Double
    let `Type`: String
    let Text: String
    let BeginOffset: Int
    let EndOffset: Int
}

struct ResponseMetadata: Decodable {
    let RequestId: String
    let HTTPStatusCode: Int
    let HTTPHeaders: HTTPHeaders
    let RetryAttempts: Int
}

struct HTTPHeaders: Decodable {
    let x_amzn_requestid: String
    let content_type: String
    let content_length: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case x_amzn_requestid = "x-amzn-requestid"
        case content_type = "content-type"
        case content_length = "content-length"
        case date
    }
    
}

struct RetJournal: Decodable {
    let jourID: String
    let userID: String
    let entry: String
    let created: String
    let hidden: String
    let sentiment: String
    let sentScore: String
    let rating: String
    let lastEdited: String
    let topics: String
    let positive: String
    let negative: String
    let mixed: String
    let neutral: String
}

struct ConJournal: Decodable {
    let jourID: Int
    let userID: Int
    let entry: String
    let created: String
    let hidden: Int
    let sentiment: String
    let sentScore: Double
    let rating: Int
    let lastEdited: String
    let topics: String
    let positive: Double
    let negative: Double
    let mixed: Double
    let neutral: Double
}
