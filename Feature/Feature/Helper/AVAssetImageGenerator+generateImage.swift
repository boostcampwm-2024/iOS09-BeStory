//
//  AVAssetImageGenerator+generateImage.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import AVFoundation
import UIKit

extension AVAssetImageGenerator {
	func generateUIImage(at time: CMTime) async throws -> UIImage {
		return try await withCheckedThrowingContinuation { continutation in
			generateCGImageAsynchronously(for: time) { cgImage, _, error in
				if let error {
					continutation.resume(throwing: error)
				}
				
				guard let cgImage else { return }
				
				continutation.resume(returning: UIImage(cgImage: cgImage))
			}
		}
	}
}
