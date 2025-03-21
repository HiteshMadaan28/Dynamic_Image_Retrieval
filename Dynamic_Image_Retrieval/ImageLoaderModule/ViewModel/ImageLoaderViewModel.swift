//
//  ImageLoaderViewModel.swift
//  Dynamic_Image_Retrieval
//
//  Created by Hitesh Madaan on 21/03/25.
//
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - ViewModel
@MainActor
final class ImageLoaderViewModel: ObservableObject {
    // MARK: - Published Properties (State)
    @Published var imageUrl: String = ""
    @Published var loadedImage: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var grayscaleOn: Bool = false
    @Published var loadStatus: LoadStatus = .initial
    
    // MARK: - Constants
    private let context = CIContext()
    
    enum LoadStatus {
        case initial
        case loading
        case success
        case failure
    }
    
    // MARK: - Validate & Fetch Image
    func validateAndFetchImage() {
        // Trim and check if URL is empty
        let trimmedUrl = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUrl.isEmpty else {
            handleError("URL cannot be empty.")
            return
        }
        
        // Validate URL format
        guard let url = URL(string: trimmedUrl), url.scheme != nil else {
            handleError("Invalid URL format.")
            return
        }
        
        // Begin loading state and fetch image
        resetStateForLoading()
        downloadImage(from: url)
    }
    
    private func resetStateForLoading() {
        errorMessage = nil
        isLoading = true
        loadStatus = .loading
        loadedImage = nil
    }
    
    private func handleError(_ message: String) {
        errorMessage = message
        loadStatus = .failure
        loadedImage = nil
        isLoading = false
    }
    
    // MARK: - Download Image (Async/Await Version)
    private func downloadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let uiImage = UIImage(data: data) else {
                    handleError("Unable to decode image data.")
                    return
                }
                
                loadedImage = uiImage
                loadStatus = .success
                isLoading = false
            } catch {
                handleError("Failed to load image: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Grayscale Application
    func applyGrayscaleIfNeeded(to image: UIImage) -> UIImage {
        guard grayscaleOn else { return image }
        
        let ciImage = CIImage(image: image)
        let grayscaleFilter = CIFilter.photoEffectMono()
        grayscaleFilter.inputImage = ciImage
        
        guard let outputImage = grayscaleFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Status Properties
    var statusColor: Color {
        switch loadStatus {
        case .initial: return Color.gray
        case .loading: return Color.gray
        case .success: return Color.green
        case .failure: return Color.red
        }
    }
    
    var statusText: String {
        switch loadStatus {
        case .initial: return "Idle"
        case .loading: return "Loading..."
        case .success: return "Success"
        case .failure: return "Failed"
        }
    }
}

