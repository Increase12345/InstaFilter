//
//  ContentView.swift
//  Instafilter
//
//  Created by Nick Pavlov on 3/4/23.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var fileringIntensity = 0.5
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("-InstaFilter-")
                    .foregroundColor(.white)
                    .font(.largeTitle.bold())
                    .padding(.top)
                    .shadow(radius: 3)
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                        .cornerRadius(10)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                VStack {
                    Text("\(currentFilter.name)".dropFirst(2))
                        .padding(.top)
                        .foregroundColor(.secondary)
                        .bold()
                    Slider(value: $fileringIntensity)
                        .padding([.bottom, .horizontal])
                        .onChange(of: fileringIntensity) { _ in applyProcessing() }
                    
                    
                    HStack {
                        Button("Change Filter") {
                            showingFilterSheet = true
                        }
                        .bold()
                        
                        Spacer()
                        
                        Button("Save", action: save)
                            .foregroundColor(inputImage == nil ? .secondary: .red)
                            .bold()
                            .disabled(inputImage == nil ? true: false)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(10)
                }
                .background(.thinMaterial)
                .cornerRadius(10)
            }
            .padding([.horizontal, .bottom])
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
            .background(LinearGradient(gradient: Gradient(colors: [.pink, .white, .green]), startPoint: .top, endPoint: .bottom).opacity(0.9))
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Seccess!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(fileringIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(fileringIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(fileringIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
