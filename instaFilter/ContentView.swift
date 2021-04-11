//
//  ContentView.swift
//  instaFilter
//
//  Created by Kristoffer Eriksson on 2021-04-08.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    //Sliders challenge 3
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var showingFilterSheet = false
    
    @State private var showingSaveAlert = false
    @State private var changeFilterTitle = "Change filter"
    
    @State private var processedImage: UIImage?
    
    @State var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        
        let intensity = Binding<Double> (
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        let radius = Binding<Double> (
            get: {
                self.filterRadius
            },
            set: {
                self.filterRadius = $0 * 200
                self.applyProcessing()
            }
        )
        
        let scale = Binding<Double> (
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0 * 10
                self.applyProcessing()
            }
        )
        
        return NavigationView{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(Color.secondary)
                    
                    //display image
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    //select image
                    self.showingImagePicker = true
                }
                
                HStack{
                    VStack{
                        Text("Intensity")
                        Slider(value: intensity)
                    }
                    VStack{
                        Text("Radius")
                        Slider(value: radius)
                    }
                    VStack{
                        Text("Scale")
                        Slider(value: scale)
                    }
                }
                .padding(.vertical)
                
                HStack{
                    Button(changeFilterTitle){
                        //change filter
                        self.showingFilterSheet = true
                    }
                    Spacer()
                    Button("Save"){
                        //save picture
                        if self.image == nil {
                            print("no image selected")
                            self.showingSaveAlert = true
                            return
                        }
                        guard let processedImage = self.processedImage else {return}
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Sucess")
                        }
                        imageSaver.errorHandler = {
                            print("Oops, error : \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                    
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("InstaFilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage){
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet){
                //actionsheet here
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")){
                        self.setFilter(CIFilter.crystallize())
                        self.changeFilterTitle = "Crystallize"
                        
                    },
                    .default(Text("Edges")){
                        self.setFilter(CIFilter.edges())
                        self.changeFilterTitle = "Edges"
                    },
                    .default(Text("Gaussian blur")){
                        self.setFilter(CIFilter.gaussianBlur())
                        self.changeFilterTitle = "Gaussian blur"
                    },
                    .default(Text("Pixelate")){
                        self.setFilter(CIFilter.pixellate())
                        self.changeFilterTitle = "Pixelate"
                    },
                    .default(Text("SepiaTOne")){
                        self.setFilter(CIFilter.sepiaTone())
                        self.changeFilterTitle = "SepiaTone"
                    },
                    .default(Text("Vignette")){
                        self.setFilter(CIFilter.vignette())
                        self.changeFilterTitle = "Vignette"
                    },
                    .default(Text("Unsharp mask")){
                        self.setFilter(CIFilter.unsharpMask())
                        self.changeFilterTitle = "Unsharp mask"
                    },
                    .cancel()
                ])
            }
            .alert(isPresented: $showingSaveAlert){
                Alert(title: Text("Error"), message: Text("no image selected"), dismissButton: .default(Text("ok")))
            }
        }
    }
    
    func loadImage(){
        guard let inputImage = inputImage else {return}
        //image = Image(uiImage: inputImage)
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing(){
        //currentFilter.intensity = Float(filterIntensity)
        //currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            //currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            //currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
            currentFilter.setValue(filterScale, forKey: kCIInputRadiusKey)
        }
        
        guard let outputImage = currentFilter.outputImage else {return}
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgImage)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter){
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
