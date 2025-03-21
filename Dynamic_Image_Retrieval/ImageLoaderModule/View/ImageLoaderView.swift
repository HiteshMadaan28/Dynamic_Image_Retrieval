//
//  ImageLoaderView.swift
//  Dynamic_Image_Retrieval
//
//  Created by Hitesh Madaan on 21/03/25.
//

import SwiftUI

struct ImageLoaderView: View {
    // MARK: - ViewModel
    @StateObject private var viewModel = ImageLoaderViewModel()
    
    // MARK: - Constants
    private let cornerRadius: CGFloat = 12
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Header
                    Text("Async Image Loader")
                        .font(.title)
                        .bold()
                        .padding(.top)
                    
                    // MARK: - URL Input
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Image URL")
                            .font(.headline)
                        
                        TextField("Enter Image URL...", text: $viewModel.imageUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Load Button
                    Button(action: {
                        viewModel.validateAndFetchImage()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                            }
                            Text(viewModel.isLoading ? "Loading..." : "Load Image")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(cornerRadius)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Load Image Button")
                    
                    // MARK: - Status Indicator
                    HStack(spacing: 10) {
                        Circle()
                            .fill(viewModel.statusColor)
                            .frame(width: 16, height: 16)
                        
                        Text(viewModel.statusText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    
                    // MARK: - Grayscale Toggle
                    Toggle("Apply Grayscale", isOn: $viewModel.grayscaleOn)
                        .padding(.horizontal)
                        .animation(.easeInOut, value: viewModel.grayscaleOn)
                        .accessibilityLabel("Toggle Grayscale Filter")
                    
                    // MARK: - Image Display Area
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .cornerRadius(cornerRadius)
                        
                        if let image = viewModel.loadedImage {
                            Image(uiImage: viewModel.applyGrayscaleIfNeeded(to: image))
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(cornerRadius)
                                .transition(.opacity)
                                .animation(.easeInOut, value: viewModel.loadedImage)
                        } else if !viewModel.isLoading {
                            VStack(spacing: 10) {
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray.opacity(0.6))
                                Text("No Image Loaded")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                        }
                    }
                    .padding()
                    
                    // MARK: - Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                            .animation(.easeInOut, value: viewModel.errorMessage)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ImageLoaderView()
}
