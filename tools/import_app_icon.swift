#!/usr/bin/env swift
// Reproduce the Android adaptive icon on iOS's opaque square canvas.
// Android uses a 108dp foreground; its central 72dp is the visible viewport.
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import CryptoKit
let script = URL(fileURLWithPath: #filePath).standardizedFileURL
let project = script.deletingLastPathComponent().deletingLastPathComponent()
let root = project.deletingLastPathComponent().deletingLastPathComponent()
let source = root.appendingPathComponent("android/Math_Tricks/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.webp")
let output = project.appendingPathComponent("Math_Tricks/Assets.xcassets/AppIcon.appiconset")
guard let reader = CGImageSourceCreateWithURL(source as CFURL,nil), let original = CGImageSourceCreateImageAtIndex(reader,0,nil),
      let context = CGContext(data:nil,width:1024,height:1024,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue) else { fatalError("Cannot decode original Android icon") }
context.setFillColor(CGColor(gray:1,alpha:1));context.fill(CGRect(x:0,y:0,width:1024,height:1024))
context.interpolationQuality = .high
context.draw(original,in:CGRect(x:-256,y:-256,width:1536,height:1536))
let target = output.appendingPathComponent("AppIcon.png")
guard let image = context.makeImage(),let writer = CGImageDestinationCreateWithURL(target as CFURL,UTType.png.identifier as CFString,1,nil) else { fatalError("Cannot encode app icon") }
CGImageDestinationAddImage(writer,image,nil)
guard CGImageDestinationFinalize(writer) else { fatalError("Cannot write app icon") }
let contents:[String:Any] = ["images":[["filename":"AppIcon.png","idiom":"universal","platform":"ios","size":"1024x1024"]],"info":["author":"xcode","version":1]]
try JSONSerialization.data(withJSONObject:contents,options:[.prettyPrinted,.sortedKeys]).write(to:output.appendingPathComponent("Contents.json"),options:.atomic)
let sourceHash = SHA256.hash(data:try Data(contentsOf:source)).map{String(format:"%02x",$0)}.joined()
let provenance:[String:Any] = ["source":"android/Math_Tricks/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.webp","sha256":sourceHash,"canvas":"1024x1024 opaque white","androidViewport":"central 72/108; iOS applies its own mask"]
try JSONSerialization.data(withJSONObject:provenance,options:[.prettyPrinted,.sortedKeys]).write(to:project.appendingPathComponent("docs/APP_ICON_SOURCE.json"),options:.atomic)
