//
//  main.swift
//  yolov7
//
//  Created by sam on 6/17/23.
//

import Foundation
import CoreML
import ImageIO
import CoreImage
import VisionKit
import Vision

extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}


var path = UserDefaults.standard.string(forKey: "path").unsafelyUnwrapped

if(path.hasPrefix("./")){
    path = path.replacingOccurrences(of: "./", with: "")
    path = "file://" + FileManager.default.currentDirectoryPath + "/" + path
}

if(!path.hasPrefix("/") && !path.hasPrefix("file://") && !path.hasPrefix("http://") && !path.hasPrefix("https://")){
    path = "file://" + FileManager.default.currentDirectoryPath + "/" + path
}

if(!path.hasPrefix("file://") && !path.hasPrefix("http://") && !path.hasPrefix("https://")){
    path = "file://" + path
}

var objects: [PredictedObject] = []

let mlmodel = try yolov7(contentsOf: yolov7.urlOfModelInThisBundle)


let visionModel = try VNCoreMLModel(for: mlmodel.model)

// Create an image classification request with an image classifier model.
let handler = VNImageRequestHandler(cgImage: loadImage(name: path), orientation: CGImagePropertyOrientation.up)


let imageClassificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
    
    let results = request.results.unsafelyUnwrapped
    
    for case let foundObject as VNRecognizedObjectObservation in results {
        let bestLabel = foundObject.labels.first! // Label with highest confidence

        let confidence = foundObject.confidence // Confidence for the predicted class
        
        objects.append(PredictedObject(name: bestLabel.identifier, confidence: Double(confidence), class_id: Int(foundObject.classCode), coordinates: Coordinates(x: Int(foundObject.boundingBox.minX * 640), y: Int(foundObject.boundingBox.minY * 640), width: Int(foundObject.boundingBox.width * 640), height: Int(foundObject.boundingBox.height * 640))))

    }
})


imageClassificationRequest.imageCropAndScaleOption = .centerCrop

let requests: [VNRequest] = [imageClassificationRequest]
try handler.perform(requests)

let jsonEncoder = JSONEncoder()
let jsonData = try jsonEncoder.encode(ResultsWrapper(objects: objects))
let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)

print(jsonString!)


struct ResultsWrapper: Codable {
    var objects: [PredictedObject] = []
}

struct PredictedObject: Codable {
  var name = ""
    var confidence = 0.0
  var class_id = 0
  var coordinates = Coordinates(x: 0, y: 0, width: 0, height: 0)
}

struct Coordinates: Codable {
    var x = 0
    var y = 0
    var width = 0
    var height = 0
}

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}

func loadImage(name: String) -> CGImage {
    let url = URL(string: name).unsafelyUnwrapped

    let sourceImage = CIImage(contentsOf: url)
    let resizeFilter = CIFilter(name:"CILanczosScaleTransform")!

    // Desired output size
    let targetSize = NSSize(width:640, height:640)

    // Compute scale and corrective aspect ratio
    let scale = targetSize.height / (sourceImage?.extent.height)!
    let aspectRatio = targetSize.width/((sourceImage?.extent.width)! * scale)

    // Apply resizing
    resizeFilter.setValue(sourceImage, forKey: kCIInputImageKey)
    resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
    resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
    let ciimage = resizeFilter.outputImage
    
    return convertCIImageToCGImage(inputImage: ciimage.unsafelyUnwrapped).unsafelyUnwrapped
}
